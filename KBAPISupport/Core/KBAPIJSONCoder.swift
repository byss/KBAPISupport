//
//  KBAPIEncoder.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/20/18.
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

public protocol KBAPIJSONEncoderProtocol: KBAPIEncoder {
	var outputFormatting: JSONEncoder.OutputFormatting { get set }
	var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy { get set }
	var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get set }
	var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy { get set }
	var nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy { get set }
}

public protocol KBAPIJSONDecoderProtocol: KBAPIDecoder {
	var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get set }
	var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get set }
	var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy { get set }
	var nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy { get set }
}

extension JSONEncoder: KBAPIJSONEncoderProtocol {
	public static var defaultForRequestSerialization: JSONEncoder {
		let result = JSONEncoder ();
#if DEBUG
		if #available(iOS 11.0, macOS 10.13, tvOS 11.0, *) {
			result.outputFormatting = [.prettyPrinted, .sortedKeys];
		} else {
			result.outputFormatting = [.prettyPrinted];
		}
#endif
		result.keyEncodingStrategy = .convertToSnakeCase;
		result.dateEncodingStrategy = .secondsSince1970;
		result.dataEncodingStrategy = .base64;
		result.nonConformingFloatEncodingStrategy = .convertToString (positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan");
		return result;
	}
}

extension JSONDecoder: KBAPIJSONDecoderProtocol {
	open func decode <T> (from data: Data) throws -> T where T: Decodable {
		return try self.decode (T.self, from: data);
	}
	
	open func decode <T> (from data: Data?, response: URLResponse) throws -> T where T: Decodable {
		self.userInfo [.urlResponseKey] = response;
		return try self.decode (from: data);
	}
	
	public static var defaultForResponseSerialization: JSONDecoder {
		let result = JSONDecoder ();
		result.keyDecodingStrategy = .convertFromSnakeCase;
		result.dateDecodingStrategy = .secondsSince1970;
		result.dataDecodingStrategy = .base64;
		result.nonConformingFloatDecodingStrategy = .convertFromString (positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan");
		return result;
	}
}
