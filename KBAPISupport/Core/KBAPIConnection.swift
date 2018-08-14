//
//  KBAPIConnection.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/18/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

import Foundation

public protocol KBAPIConnectionProtocol: AnyObject {
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
	
	private var queue: DispatchQueue {
		return KBAPIConnectionQueue;
	}
	
	private var taskWrapper: SessionTaskWrapper;
	
	open class func withRequest (_ request: Request) -> KBAPIConnection {
		return KBAPIConnection (request: request);
	}
	
	public init (request: Request, session: URLSession = .shared) {
		self.taskWrapper = SessionTaskWrapper (session: session, request: request);
	}

	public func start () {
		self.queue.async {
			self.start (completion: EmptyCompletionWrapper ());
		}
	}

	public func start (completion: @escaping (Result <ResponseType>) -> ()) {
		self.queue.async {
			self.start (completion: CompletionBlockWrapper (completion));
		}
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
				log.info ("Encoded response: \(data.map { $0.debugLogDescription } ?? "nil")");
				try completion.call (with: self.request.responseSerializer.decode (from: data, response: response));
			} else {
				log.fault ("Invalid state: URL response and error are both nil");
			}
		} catch {
			completion.call (with: error);
		}
	}
}

extension KBAPIConnection: KBAPIConnectionProtocol {
	open func cancel () {
		self.task.cancel ();
	}
}

fileprivate extension KBAPIConnection {
	private struct SessionTaskWrapper {
		fileprivate let request: Request;
		
		fileprivate var task: URLSessionTask {
			guard self.taskPointer != 0 else {
				log.fault ("URL session task is not created yet");
				return URLSessionTask ();
			}
			return unsafeBitCast (self.taskPointer, to: URLSessionTask.self);
		}
		
		private unowned let session: URLSession;
		private var taskPointer = 0;
		
		fileprivate init (session: URLSession, request: Request) {
			self.session = session;
			self.request = request;
		}
		
		fileprivate mutating func makeTask <C> (for connection: KBAPIConnection, completion: C) throws -> URLSessionTask where C: CompletionWrapper, C.ResponseType == ResponseType {
			let serializedRequest = try self.request.serializer.serializeRequest (self.request);
			let task = self.session.dataTask (with: serializedRequest, completionHandler: { data, response, error in
				connection.queue.safeSync {
					connection.taskDidFinish (data: data, response: response, error: error, completion: completion);
				};
			});
			self.taskPointer = Int (bitPattern: Unmanaged.passUnretained (task).toOpaque ());
			return task;
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
		
		fileprivate init (_ block: @escaping (Result <ResponseType>) -> ()) {
			self.block = block;
		}
		
		fileprivate func call (with result: Result <ResponseType>) {
			DispatchQueue.main.safeSync {
				self.block (result);
			}
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
	open func connection <R> (with request: R) -> KBAPIConnection <R> where R: KBAPIRequest {
		return KBAPIConnection (request: request, session: self);
	}
}

private let KBAPIConnectionQueue = DispatchQueue (label: "KBAPISupport", qos: .userInitiated, attributes: .concurrent);
private let log = KBLoggerWrapper ();