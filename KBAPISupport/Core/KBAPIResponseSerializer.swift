//
//  KBAPIResponseSerializer.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/19/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

import Foundation

public extension CodingUserInfoKey {
	public static let urlResponseKey = CodingUserInfoKey (rawValue: "urlResponse")!;
}

public protocol KBAPIDecoder: KBAPICoder {
	func decode <T> (from data: Data) throws -> T where T: Decodable;
	func decode <T> (from data: Data?) throws -> T where T: Decodable;
	func decode <T> (from data: Data?, response: URLResponse) throws -> T where T: Decodable;
}

public protocol KBAPIResponseSerializerProtocol: KBAPICoder {
	associatedtype ResponseType;
	
	func decode (from data: Data) throws -> ResponseType;
	func decode (from data: Data?) throws -> ResponseType;
	func decode (from data: Data?, response: URLResponse) throws -> ResponseType;
}

public extension KBAPIDecoder {
	public func decode <T> (from data: Data) throws -> T where T: Decodable {
		return try self.decode (from: nil);
	}
	
	public func decode <T> (from data: Data?) throws -> T where T: Decodable {
		guard let data = data else {
			throw DecodingError.dataCorrupted (DecodingError.Context (codingPath: [], debugDescription: "No data supplied"));
		}
		return try self.decode (from: data);
	}

	public func decode <T> (from data: Data?, response: URLResponse) throws -> T where T: Decodable {
		return try self.decode (from: data);
	}
}

public extension KBAPIResponseSerializerProtocol {
	public func decode (from data: Data) throws -> ResponseType {
		return try self.decode (from: nil);
	}
	
	public func decode (from data: Data?) throws -> ResponseType {
		guard let data = data else {
			throw DecodingError.dataCorrupted (DecodingError.Context (codingPath: [], debugDescription: "No data supplied"));
		}
		return try self.decode (from: data);
	}

	public func decode (from data: Data?, response: URLResponse) throws -> ResponseType {
		return try self.decode (from: data);
	}
}

open class KBAPIRawResponseSerializer: KBAPIResponseSerializerProtocol {
	public typealias ResponseType = Data;
	
	open var userInfo = [CodingUserInfoKey: Any] ();
	
	public init () {}

	public func decode (from data: Data) throws -> Data {
		return data;
	}
	
	open func decode (from data: Data?, response: URLResponse) throws -> Data {
		return try self.decode (from: data);
	}
}

open class KBAPIRawJSONResponseSerializer: KBAPIResponseSerializerProtocol {
	public typealias ResponseType = Any;
	
	open var userInfo = [CodingUserInfoKey: Any] ();
	open var options: JSONSerialization.ReadingOptions;
	
	public init (options: JSONSerialization.ReadingOptions = .allowFragments) {
		self.options = options;
	}

	open func decode (from data: Data) throws -> Any {
		do {
			let result = try JSONSerialization.jsonObject (with: data, options: self.options);
			log.info ("Decoded value: \(result)");
			return result;
		} catch {
			log.warning ("Decoding error: \(error)");
			throw error;
		}
	}

	open func decode (from data: Data?, response: URLResponse) throws -> Any {
		return try self.decode (from: data);
	}
}

open class KBAPIJSONResponseSerializer <Response>: KBAPIResponseSerializerProtocol where Response: Decodable {
	public typealias ResponseType = Response;
	
	open var jsonDecoder: KBAPIJSONDecoderProtocol;
	open var userInfo: [CodingUserInfoKey: Any] {
		get { return self.jsonDecoder.userInfo }
		set { self.jsonDecoder.userInfo = newValue }
	}
	
	public init (jsonDecoder: KBAPIJSONDecoderProtocol = JSONDecoder.defaultForResponseSerialization) {
		self.jsonDecoder = jsonDecoder;
	}

	open func decode (from data: Data?, response: URLResponse) throws -> Response {
		do {
			let result: Response = try self.jsonDecoder.decode (from: data, response: response);
			log.info ("Result: \(type (of: result)) instance");
			return result;
		} catch {
			log.warning ("Decoding error: \(error)");
			throw error;
		}
	}
}

private let log = KBLoggerWrapper ();
