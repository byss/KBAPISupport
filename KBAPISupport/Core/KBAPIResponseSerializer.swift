//
//  KBAPIResponseSerializer.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/19/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

import Foundation

public protocol KBAPIDecoder {
	func decode <T> (from data: Data) throws -> T where T: Decodable;
}

public protocol KBAPIResponseSerializerProtocol {
	associatedtype ResponseType where ResponseType: Decodable;
	
	func decode (from data: Data) throws -> ResponseType;
}

open class KBAPIJSONResponseSerializer <Response>: KBAPIResponseSerializerProtocol where Response: Decodable {
	public typealias ResponseType = Response;
	
	open let jsonDecoder: KBAPIJSONDecoder;
	
	public init (jsonDecoder: KBAPIJSONDecoder = JSONDecoder.defaultForResponseSerialization) {
		self.jsonDecoder = jsonDecoder;
	}

	open func decode (from data: Data) throws -> Response {
		return try self.jsonDecoder.decode (from: data);
	}
}

public protocol KBAPIJSONDecoder: KBAPIDecoder {
	var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get set }
	var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get set }
	var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy { get set }
	var nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy { get set }
}

extension JSONDecoder: KBAPIJSONDecoder {
	public func decode <T> (from data: Data) throws -> T where T: Decodable {
		return try self.decode (T.self, from: data);
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
