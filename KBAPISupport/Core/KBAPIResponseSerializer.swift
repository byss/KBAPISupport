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
		log.debug ("Encoded response: \(data.debugLogDescription)");
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
		log.debug ("Encoded response: \(data.debugLogDescription)");
		do {
			let result = try JSONSerialization.jsonObject (with: data, options: self.options);
			log.info ("Decoded value: \(result)");
			return result;
		} catch {
			log.warning ("Decoding error: \(error)");
			throw error;
		}
		
	}
}

open class KBAPIJSONResponseSerializer <Response>: KBAPIResponseSerializerProtocol where Response: Decodable {
	public typealias ResponseType = Response;
	
	open let jsonDecoder: KBAPIJSONDecoderProtocol;
	
	public init (jsonDecoder: KBAPIJSONDecoderProtocol = JSONDecoder.defaultForResponseSerialization) {
		self.jsonDecoder = jsonDecoder;
	}

	open func decode (from data: Data) throws -> Response {
		log.debug ("Encoded response: \(data.debugLogDescription)");
		do {
			let result: Response = try self.jsonDecoder.decode (from: data);
			log.info ("Result: \(type (of: result)) instance");
			return result;
		} catch {
			log.warning ("Decoding error: \(error)");
			throw error;
		}
	}
}

private let log = KBLoggerWrapper ();
