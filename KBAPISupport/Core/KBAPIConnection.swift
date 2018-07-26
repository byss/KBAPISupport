//
//  KBAPIConnection.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/18/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

import Foundation

private let KBAPIConnectionQueue = DispatchQueue (label: "KBAPISupport", qos: .userInitiated, attributes: .concurrent);

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

open class KBAPIConnection <Request> where Request: KBAPIRequest {
	public typealias RequestType = Request;
	public typealias ResponseType = Request.ResponseType;
	
	private var queue: DispatchQueue {
		return KBAPIConnectionQueue;
	}
	
	private let taskWrapper: SessionTaskWrapper;
	
	private var request: Request {
		return self.taskWrapper.request;
	}

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
				throw error;
			}
			try completion.call (with: self.request.responseSerializer.decode (from: data ?? Data ()));
		} catch {
			completion.call (with: error);
		}
	}
}

fileprivate extension KBAPIConnection {
	private struct SessionTaskWrapper {
		fileprivate let request: Request;
		
		private unowned let session: URLSession;

		fileprivate private (set) lazy var task: URLSessionTask = {
			fatalError ("URL session task is not created yet");
		} ();
		
		fileprivate init (session: URLSession, request: Request) {
			self.session = session;
			self.request = request;
		}
		
		fileprivate func makeTask <C> (for connection: KBAPIConnection, completion: C) throws -> URLSessionTask where C: CompletionWrapper, C.ResponseType == ResponseType {
			let serializedRequest = try self.request.serializer.serializeRequest (self.request);
			return self.session.dataTask (with: serializedRequest, completionHandler: { data, response, error in
				connection.queue.safeSync {
					connection.taskDidFinish (data: data, response: response, error: error, completion: completion);
				};
			});
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

extension URLSession {
	open func connection <R> (with request: R) -> KBAPIConnection <R> where R: KBAPIRequest {
		return KBAPIConnection (request: request, session: self);
	}
}
