//
//  KBImage+KBAPISupport.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 8/3/18.
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

#if os (iOS) || os (macOS) || os (tvOS)

import Foundation

public extension KBImage {
	@discardableResult
	public static func withURL (_ url: URL, completion: @escaping (Result <KBImage>) -> ()) -> KBAPIConnectionProtocol {
		return self.withRequest (URLRequest (url: url), completion: completion);
	}
	
	@discardableResult
	public static func withRequest (_ request: URLRequest, completion: @escaping (Result <KBImage>) -> ()) -> KBAPIConnectionProtocol {
		return self.withRequest (KBImageRequest (request), completion: completion);
	}
	
	@discardableResult
	public static func withRequest <R> (_ request: R, completion: @escaping (Result <KBImage>) -> ()) -> KBAPIConnectionProtocol where R: KBAPIRequest, R.ResponseType == KBImage {
		let result = KBAPIConnection.withRequest (request);
		defer {
			result.start (completion: completion);
		}
		return result;
	}
}

private struct KBImageRequest: KBAPIRequest {
	fileprivate typealias SerializerType = Serializer;
	fileprivate typealias ResponseType = KBImage;
	fileprivate typealias ResponseSerializerType = ResponseSerializer;
	

	fileprivate struct Serializer: RequestSerializer {
		private struct InternalError: Error {}
		
		fileprivate typealias RequestType = KBImageRequest;
		
		fileprivate var userInfo = [CodingUserInfoKey: Any] ();

		fileprivate func serializeRequest (_ request: KBImageRequest) throws -> URLRequest {
			return request.wrapped;
		}
		
		fileprivate func serializeRequest <R> (_ request: R) throws -> URLRequest where R: KBAPIRequest {
			guard let request = request as? KBImageRequest else {
				throw InternalError ();
			}
			return try self.serializeRequest (request);
		}
	}
	
	fileprivate struct ResponseSerializer: KBAPIResponseSerializerProtocol {
		fileprivate typealias ResponseType = KBImage;
		
		fileprivate var userInfo = [CodingUserInfoKey: Any] ();
		
		fileprivate func decode (from data: Data) throws -> KBImage {
			log.info ("Encoded response: \(data.description)");
			guard let result = KBImage (data: data) else {
				log.warning ("Cannot decode image from response data");
				throw CocoaError.error (.coderReadCorrupt);
			}
			log.info ("Decoded value: \(result)");
			return result;
		}
	}
	
	fileprivate let serializer: RequestSerializer = Serializer ();
	fileprivate let responseSerializer = ResponseSerializer ();

	private let wrapped: URLRequest;

	fileprivate init (_ wrapped: URLRequest) {
		self.wrapped = wrapped;
	}
}

private let log = KBLoggerWrapper ();

#endif
