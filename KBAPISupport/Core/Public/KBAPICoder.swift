//
//  KBAPIAPICoder.swift
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

public protocol KBAPICoder {
	var userInfo: [CodingUserInfoKey: Any] { get set }
}

public protocol KBAPIEncoder: KBAPICoder {
	func encode <T> (_ parameters: T) throws -> Data where T: Encodable;
}

public protocol KBAPIDecoder: KBAPICoder {
	func decode <T> (from data: Data) throws -> T where T: Decodable;
	func decode <T> (from data: Data?) throws -> T where T: Decodable;
	func decode <T> (from data: Data?, response: URLResponse) throws -> T where T: Decodable;
}

public protocol KBAPIRequestSerializerProtocol: KBAPICoder {
	func shouldSerializeRequestParametersAsBodyData <R> (for request: R) -> Bool where R: KBAPIRequest;
	func serializeRequest <R> (_ request: R) throws -> URLRequest where R: KBAPIRequest;
	func serializeParameters <P> (_ parameters: P, asBodyData: Bool, into request: inout URLRequest) throws where P: Encodable;
}

public protocol KBAPIResponseSerializerProtocol: KBAPICoder {
	associatedtype ResponseType;
	
	func decode (from data: Data) throws -> ResponseType;
	func decode (from data: Data?) throws -> ResponseType;
	func decode (from data: Data?, response: URLResponse) throws -> ResponseType;
}
