//
//  KBAPIConnection.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/18/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public protocol KBAPIConnectionProtocol: AnyObject {
	var isCancelled: Bool { get }
	
	func cancel ();
}

open class KBAPIConnection <Request> where Request: KBAPIRequest {
	public typealias RequestType = Request;
	public typealias ResponseType = Request.ResponseType;
	
	public var request: Request {
		return self.taskWrapper.request;
	}
	
	private var task: URLSessionTask {
		return self.taskWrapper.task;
	}
	
	private var taskWasCancelled = false;
	private var taskWrapper: SessionTaskWrapper;
	
	open class func withRequest (_ request: Request) -> KBAPIConnection {
		return KBAPIConnection (request: request);
	}
	
	public init (request: Request, session: URLSession = .shared) {
		self.taskWrapper = SessionTaskWrapper (session: session, request: request);
	}

	public func start () {
		DispatchQueue.defaultConcurrent.async { self.start (completion: EmptyCompletionWrapper ()) };
	}

	public func start (callbackQueue: DispatchQueue = .main, completion: @escaping (Result <ResponseType>) -> ()) {
		DispatchQueue.defaultConcurrent.async { self.start (completion: CompletionBlockWrapper (completion, callbackQueue: callbackQueue)) };
	}
	
	private func start <C> (completion: C) where C: CompletionWrapper, C.ResponseType == ResponseType {
		do {
			try self.taskWrapper.makeTask (for: self, completion: completion).resume ();
		} catch {
			completion.call (with: error);
		}
	}
	
	private func taskDidFinish <C> (data: Data?, response: URLResponse?, error: Error?, completion: C) where C: CompletionWrapper, C.ResponseType == ResponseType {
		do {
			if let error = error {
				log.warning ("Networking error: \(error)");
				throw error;
			} else if let response = response {
				log.info ("URL response: \(response)");
				log.info ("Encoded response: \(data.debugLogDescription)");
				try completion.call (with: self.request.responseSerializer.decode (from: data, response: response));
			} else {
				log.fault ("Invalid state: URL response and error are both nil");
			}
		} catch {
			completion.call (with: error);
		}
		self.taskWrapper.invalidateTask ();
	}
}

extension KBAPIConnection: KBAPIConnectionProtocol {
	open var isCancelled: Bool {
		return self.taskWasCancelled || (self.taskWrapper.isTaskValid && (self.task.state == .canceling));
	}
	
	open func cancel () {
		guard !self.isCancelled else {
			return;
		}
		self.taskWasCancelled = true;
		self.task.cancel ();
	}
}

fileprivate extension KBAPIConnection {
	private struct SessionTaskWrapper {
		fileprivate let request: Request;
		
		fileprivate var task: URLSessionTask {
			guard let taskPointer = self.taskPointer else {
				log.fault ("URL session task is not created yet");
				return URLSessionTask ();
			}
			return taskPointer.pointee;
		}
		
		fileprivate var isTaskValid: Bool {
			return self.taskPointer != nil;
		}
		
		private unowned let session: URLSession;
		private var taskPointer: UnsafePointer <URLSessionTask>?;
		
		fileprivate init (session: URLSession, request: Request) {
			self.session = session;
			self.request = request;
		}
		
		fileprivate mutating func makeTask <C> (for connection: KBAPIConnection, completion: C) throws -> URLSessionTask where C: CompletionWrapper, C.ResponseType == ResponseType {
			let serializedRequest = try self.request.serializer.serializeRequest (self.request);
#if DEBUG
			log.debug ("Serialized: \(serializedRequest.makeCurlCommand (targetSession: self.session))");
#else
			log.debug ("Serialized: \(result)");
#endif
			let task = self.session.dataTask (with: serializedRequest, completionHandler: { data, response, error in
				DispatchQueue.defaultConcurrent.async {
					connection.taskDidFinish (data: data, response: response, error: error, completion: completion);
				};
			});
			self.taskPointer = UnsafePointer (Unmanaged.passUnretained (task).toOpaque ().assumingMemoryBound (to: URLSessionTask.self));
			return task;
		}
		
		fileprivate mutating func invalidateTask () {
			self.taskPointer = nil;
		}
	}
}

fileprivate extension KBAPIConnection {
	private struct EmptyCompletionWrapper: CompletionWrapper {
		fileprivate func call (with response: ResponseType) {}
		fileprivate func call (with error: Error) {}
		fileprivate func call (with result: Result <ResponseType>) {}
	}
	
	private struct CompletionBlockWrapper: CompletionWrapper {
		fileprivate typealias ResponseType = KBAPIConnection.ResponseType;
		
		private let block: (Result <ResponseType>) -> ();
		private let callbackQueue: DispatchQueue;
		
		fileprivate init (_ block: @escaping (Result <ResponseType>) -> (), callbackQueue: DispatchQueue) {
			self.block = block;
			self.callbackQueue = callbackQueue;
		}
		
		fileprivate func call (with result: Result <ResponseType>) {
			self.callbackQueue.sync { self.block (result) };
		}
	}
}

private protocol CompletionWrapper {
	associatedtype ResponseType;
	
	func call (with response: ResponseType);
	func call (with error: Error);
	func call (with result: Result <ResponseType>);
}

extension CompletionWrapper {
	fileprivate func call (with response: ResponseType) {
		self.call (with: .success (response));
	}
	
	fileprivate func call (with error: Error) {
		self.call (with: .failure (error));
	}
}

extension URLSession {
	public convenience init (apiConfiguration configuration: URLSessionConfiguration) {
		self.init (configuration: configuration, delegate: nil, delegateQueue: .defaultSerial);
	}
	
	open func connection <R> (with request: R) -> KBAPIConnection <R> where R: KBAPIRequest {
		return KBAPIConnection (request: request, session: self);
	}
}

fileprivate extension OperationQueue {
	fileprivate static let defaultSerial = OperationQueue (underlying: .defaultSerial);

	private convenience init (underlying: DispatchQueue) {
		self.init ();
		self.name = underlying.label;
		self.underlyingQueue = underlying;
	}
}

fileprivate extension DispatchQueue {
	fileprivate static let defaultSerial = DispatchQueue (label: "KBAPISupport.serial", qos: .userInitiated);
	fileprivate static let defaultConcurrent = DispatchQueue (label: "KBAPISupport.concurrent", qos: .userInitiated, attributes: .concurrent);
}

private let log = KBLoggerWrapper ();
