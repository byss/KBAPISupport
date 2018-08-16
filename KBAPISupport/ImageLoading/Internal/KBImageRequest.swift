//
//  KBImageRequest.swift
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

internal struct KBImageRequest: KBAPIRequest {
	internal typealias ResponseType = KBImage;
	internal typealias ResponseSerializerType = ResponseSerializer;
	internal typealias SerializerType = Serializer;

	internal struct Serializer: RequestSerializer {
		private struct InternalError: Error {}
		
		fileprivate typealias RequestType = KBImageRequest;
		
		internal var userInfo = [CodingUserInfoKey: Any] ();

		fileprivate func serializeRequest (_ request: KBImageRequest) throws -> URLRequest {
			return request.wrapped;
		}
		
		internal func serializeRequest <R> (_ request: R) throws -> URLRequest where R: KBAPIRequest {
			guard let request = request as? KBImageRequest else {
				throw InternalError ();
			}
			return try self.serializeRequest (request);
		}
	}
	
	internal struct ResponseSerializer: KBAPIResponseSerializerProtocol {
		internal typealias ResponseType = KBImage;
		
		internal var userInfo = [CodingUserInfoKey: Any] ();
		
		internal func decode (from data: Data) throws -> KBImage {
			log.info ("Encoded response: \(data.description)");
			guard let result = KBImage (data: data) else {
				log.warning ("Cannot decode image from response data");
				throw CocoaError.error (.coderReadCorrupt);
			}
			log.info ("Decoded value: \(result)");
			return result;
		}
	}
	
	internal let serializer: RequestSerializer = Serializer ();
	internal let responseSerializer = ResponseSerializer ();

	private let wrapped: URLRequest;

	internal init (_ wrapped: URLRequest) {
		self.wrapped = wrapped;
	}
}

private let log = KBLoggerWrapper ();

#endif
