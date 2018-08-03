//
//  KBAPIRequest.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/18/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

import Foundation

public protocol KBAPICoder {
	var userInfo: [CodingUserInfoKey: Any] { get set }
}

public struct KBAPIRequestVoidParameters: Encodable, CustomStringConvertible {
	public static let instance = KBAPIRequestVoidParameters ();
	
	public var description: String {
		return "none";
	}
	
	private init () {}
}

public struct KBAPIRequestHTTPMethod: Hashable {
	public let rawValue: String;
	
	private init (_ value: String) {
		self.rawValue = value;
	}
}

public protocol KBAPIRequest {
	typealias HTTPMethod = KBAPIRequestHTTPMethod;
	typealias VoidParameters = KBAPIRequestVoidParameters;
	typealias RequestSerializer = KBAPIRequestSerializerProtocol;
	typealias ResponseSerializer = KBAPIResponseSerializerProtocol;
	
	typealias JSONSerializer = KBAPIJSONSerializer;
	typealias URLEncodingSerializer = KBAPIURLEncodingSerializer;
	typealias JSONResponseSerializer = KBAPIJSONResponseSerializer;
	
	associatedtype Parameters = VoidParameters where Parameters: Encodable;
	associatedtype ResponseType;
	associatedtype ResponseSerializerType where ResponseSerializerType: ResponseSerializer, ResponseSerializerType.ResponseType == ResponseType;
	
	var httpMethod: HTTPMethod { get }
	var httpHeaders: [String: String] { get }
	var baseURL: URL { get }
	var path: String { get }
	var url: URL { get }
	var parameters: Parameters { get }

	var serializer: RequestSerializer { get }
	var responseSerializer: ResponseSerializerType { get }
}

public extension KBAPIRequestHTTPMethod {
	public static let head = KBAPIRequestHTTPMethod (__KBAPIRequestHTTPMethod.HEAD.rawValue);
	public static let get = KBAPIRequestHTTPMethod (__KBAPIRequestHTTPMethod.GET.rawValue);
	public static let post = KBAPIRequestHTTPMethod (__KBAPIRequestHTTPMethod.POST.rawValue);
	public static let put = KBAPIRequestHTTPMethod (__KBAPIRequestHTTPMethod.PUT.rawValue);
	public static let patch = KBAPIRequestHTTPMethod (__KBAPIRequestHTTPMethod.PATCH.rawValue);
	public static let delete = KBAPIRequestHTTPMethod (__KBAPIRequestHTTPMethod.DELETE.rawValue);
}

extension KBAPIRequestHTTPMethod: ExpressibleByStringLiteral {
	public typealias StringLiteralType = String;
	
	public init (stringLiteral: String) {
		self.init (stringLiteral);
	}
}

extension KBAPIRequestHTTPMethod: RawRepresentable {
	public typealias RawValue = String;

	public init (rawValue value: String) {
		self.init (value);
	}
}

extension KBAPIRequestHTTPMethod: CustomStringConvertible {
	public var description: String {
		return self.rawValue;
	}
}

public extension KBAPIRequest {
	public var httpMethod: HTTPMethod {
		return .get;
	}
	
	public var httpHeaders: [String: String] {
		return [:];
	}

	public var baseURL: URL {
		return .none;
	}
	
	public var path: String {
		return "";
	}
	
	public var url: URL {
		guard let url = URL (string: self.path, relativeTo: self.baseURL) else {
			log.fault ("Cannot construct URL for \(self)");
			return NSURL () as URL;
		}
		return url;
	}
}

public extension KBAPIRequest where Parameters == VoidParameters {
	public var parameters: Parameters {
		return VoidParameters.instance;
	}
}

public extension KBAPIRequest where Parameters: ExpressibleByNilLiteral {
	public var parameters: Parameters {
		return nil;
	}
}

public extension KBAPIRequest where Parameters: ExpressibleByArrayLiteral {
	public var parameters: Parameters {
		return [];
	}
}

public extension KBAPIRequest where Parameters: ExpressibleByDictionaryLiteral {
	public var parameters: Parameters {
		return [:];
	}
}

fileprivate extension URL {
	fileprivate static let none = URL (string: "")!;
}

private let log = KBLoggerWrapper ();
