//
//  KBAPIRequestSerializersBridge.swift
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

extension __KBAPIRequestSerializer: KBAPIRequestSerializerProtocol {
	open func shouldSerializeRequestParametersAsBodyData <R>  (for request: R) -> Bool where R: KBAPIRequest {
		guard let request = request as? __KBAPIRequest else {
			return false;
		}
		return self.shouldSerializeRequestParametersAsBodyData (for: request);
	}
	
	open func serializeRequest <R> (_ req: R) throws -> URLRequest where R: KBAPIRequest {
		guard let request = req as? __KBAPIRequest else {
			throw EncodingError.invalidValue (req, EncodingError.Context (codingPath: [], debugDescription: "Cannot convert to \(__KBAPIRequest.self)"));
		}
		return try self.serializeRequest (request);
		
	}
	
	open func serializeParameters <P> (_ params: P, asBodyData: Bool, into request: inout URLRequest) throws where P: Encodable {
		guard let parameters = params as? [String: Any] else {
			throw EncodingError.invalidValue (params, EncodingError.Context (codingPath: [], debugDescription: "Cannot convert to \([String: Any].self)"));
		}
		let mutableRequest = (request as NSURLRequest).mutableCopy () as! NSMutableURLRequest;
		try self.serializeParameters (parameters, asBodyData: asBodyData, into: mutableRequest);
		request = mutableRequest as URLRequest;
	}
}
