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
	associatedtype ResponseType;
	
	func decode (from data: Data) throws -> ResponseType;
}

open class KBAPIRawResponseSerializer: KBAPIResponseSerializerProtocol {
	public typealias ResponseType = Data;
	
	public init () {}

	open func decode (from data: Data) throws -> Data {
		return data;
	}
}

open class KBAPIRawJSONResponseSerializer: KBAPIResponseSerializerProtocol {
	public typealias ResponseType = Any;
	
	open var options: JSONSerialization.ReadingOptions;
	
	public init (options: JSONSerialization.ReadingOptions = .allowFragments) {
		self.options = options;
	}

	open func decode (from data: Data) throws -> Any {
		return try JSONSerialization.jsonObject (with: data, options: self.options);
	}
}

open class KBAPIJSONResponseSerializer <Response>: KBAPIResponseSerializerProtocol where Response: Decodable {
	public typealias ResponseType = Response;
	
	open let jsonDecoder: KBAPIJSONDecoderProtocol;
	
	public init (jsonDecoder: KBAPIJSONDecoderProtocol = JSONDecoder.defaultForResponseSerialization) {
		self.jsonDecoder = jsonDecoder;
	}

	open func decode (from data: Data) throws -> Response {
		return try self.jsonDecoder.decode (from: data);
	}
}
