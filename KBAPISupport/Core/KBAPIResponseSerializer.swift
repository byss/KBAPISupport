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
	
	open let jsonDecoder: KBAPIJSONDecoderProtocol;
	
	public init (jsonDecoder: KBAPIJSONDecoderProtocol = JSONDecoder.defaultForResponseSerialization) {
		self.jsonDecoder = jsonDecoder;
	}

	open func decode (from data: Data) throws -> Response {
		return try self.jsonDecoder.decode (from: data);
	}
}
