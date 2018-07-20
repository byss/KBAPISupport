//
//  KBAPIRequestSerializer.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/19/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

import Foundation

public protocol KBAPIEncoder {
	func encode <T> (_ parameters: T) throws -> Data where T: Encodable;
}

public protocol KBAPIRequestSerializerProtocol {
	func shouldSerializeRequestParametersAsBodyData <R> (for request: R) -> Bool where R: KBAPIRequest;
	func serializeRequest <R> (_ request: R) throws -> URLRequest where R: KBAPIRequest;
	func serializeParameters <P> (_ parameters: P, asBodyData: Bool, into request: inout URLRequest) throws where P: Encodable;
}

public extension KBAPIRequestSerializerProtocol {
	public func shouldSerializeRequestParametersAsBodyData <R> (for request: R) -> Bool where R: KBAPIRequest {
		switch (request.httpMethod) {
		case .get, .delete:
			return false;
		default:
			return true;
		}
	}
	
	public func serializeRequest <R> (_ req: R) throws -> URLRequest where R: KBAPIRequest {
		var result = URLRequest (url: req.url);
		result.httpMethod = req.httpMethod.rawValue;
		result.allHTTPHeaderFields = req.httpHeaders;
		try self.serializeParameters (req.parameters, asBodyData: self.shouldSerializeRequestParametersAsBodyData (for: req), into: &result);
		return result;
	}
}

open class KBAPIURLEncodingSerializer: KBAPIRequestSerializerProtocol {
	open var urlEncoder: KBAPIURLEncoder;
	
	public init (urlEncoder: KBAPIURLEncoder = URLEncoder ()) {
		self.urlEncoder = urlEncoder;
	}
	
	open func serializeParameters <P> (_ parameters: P, asBodyData: Bool, into request: inout URLRequest) throws where P: Encodable {
		request.addValue ("application/json", forHTTPHeaderField: "Accept");
		request.addValue ("gzip, deflate", forHTTPHeaderField: "Accept-Encoding");
		if let acceptLanguageHeaderValue = Bundle.main.preferredLocalizationsHTTPHeader {
			request.addValue (acceptLanguageHeaderValue, forHTTPHeaderField: "Accept-Language");
		}
		
		guard !asBodyData else {
			request.addValue ("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type");
			return request.httpBody = try self.urlEncoder.encode (parameters);
		}
		
		guard var urlComponents = request.url.flatMap ({ URLComponents (url: $0, resolvingAgainstBaseURL: false) }) else {
			fatalError ("Request URL is not set or is invalid");
		}
		
		let encodedParameters = try self.urlEncoder.encode (parameters) as [URLQueryItem];
		urlComponents.queryItems = urlComponents.queryItems.map { $0 + encodedParameters } ?? encodedParameters;
		guard let resultURL = urlComponents.url else {
			fatalError ("\(self.urlEncoder) did return invalid url query items");
		}
		request.url = resultURL;
	}
}

open class KBAPIJSONSerializer: KBAPIURLEncodingSerializer {
	open let jsonEncoder: KBAPIJSONEncoderProtocol;

	public init (urlEncoder: KBAPIURLEncoder? = nil, jsonEncoder: KBAPIJSONEncoderProtocol = JSONEncoder.defaultForRequestSerialization) {
		self.jsonEncoder = jsonEncoder;
		if let urlEncoder = urlEncoder {
			super.init (urlEncoder: urlEncoder);
		} else {
			super.init ();
		}
	}
	
	open override func serializeParameters <P> (_ parameters: P, asBodyData: Bool, into request: inout URLRequest) throws where P: Encodable {
		guard asBodyData else {
			return try super.serializeParameters (parameters, asBodyData: asBodyData, into: &request);
		}
		request.addValue ("application/json", forHTTPHeaderField: "Content-Type");
		request.httpBody = try self.jsonEncoder.encode (parameters);
	}
}

fileprivate extension Bundle {
	fileprivate var preferredLocalizationsHTTPHeader: String? {
		let preferredLocalizations = self.preferredLocalizations.prefix (6);
		guard !preferredLocalizations.isEmpty else {
			return nil;
		}
		return preferredLocalizations.enumerated ().map { "\($0.element); q=\(String (format: "%.1f", 1.0 / Double (1 << $0.offset)))" }.joined (separator: ", ");
	}
}
