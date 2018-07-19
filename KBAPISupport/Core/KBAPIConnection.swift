//
//  KBAPIConnection.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/18/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

import Foundation

private let KBAPIConnectionQueue = DispatchQueue (label: "KBAPISupport", qos: .userInitiated, attributes: .concurrent);

open class KBAPIConnection <Request> where Request: KBAPIRequest {
	public typealias RequestType = Request;
	public typealias ResponseType = Request.ResponseType;
	
	private static var queue: DispatchQueue {
		return KBAPIConnectionQueue;
	}
	
	open class func withRequest (_ request: Request) -> KBAPIConnection {
		return KBAPIConnection (request: request);
	}
	
	public init (request: Request, session: URLSession = .shared) {
		self.request = request;
		self.session = session;
	}

	public func start () {
		self.start (completion: nil);
	}

	public func start (completion: @escaping (Result <ResponseType>) -> ()) {
		self.start (completion: .some (completion));
	}
	
	private func start (completion: ((Result <ResponseType>) -> ())? = nil) {
		KBAPIConnection.queue.async {
			let serializedRequest: URLRequest;
			do {
				try serializedRequest = self.request.serializer.serializeRequest (self.request);
			} catch {
				return completion.map {
					self.connectionDidFinish (error: error, completion: $0);
				} ?? ();
			}
			
			self.session.dataTask (with: serializedRequest) { data, _, error in
				if let error = error {
					return completion.map {
						self.connectionDidFinish (error: error, completion: $0);
					} ?? ();
				}
				
				KBAPIConnection.queue.async {
					let result: Result <ResponseType>;
					do {
						try result = .success (self.request.responseSerializer.decode (from: data ?? Data ()));
					} catch {
						result = .failure (error);
					}
					completion.map {
						self.connectionDidFinish (result: result, completion: $0);
					}
				};
			}.resume ();
		};
	}
	
	private func connectionDidFinish (error: Error, completion: (Result <ResponseType>) -> ()) {
		self.connectionDidFinish (result: .failure (error), completion: completion);
	}
	
	private func connectionDidFinish (response: Request.ResponseType, completion: (Result <ResponseType>) -> ()) {
		self.connectionDidFinish (result: .success (response), completion: completion);
	}

	private func connectionDidFinish (result: Result <ResponseType>, completion: (Result <ResponseType>) -> ()) {
		DispatchQueue.main.safeSync {
			completion (result);
		};
	}
	

	private unowned let session: URLSession;
	private let request: Request;
}

extension URLSession {
	open func connection <R> (with request: R) -> KBAPIConnection <R> where R: KBAPIRequest {
		return KBAPIConnection (request: request, session: self);
	}
}
