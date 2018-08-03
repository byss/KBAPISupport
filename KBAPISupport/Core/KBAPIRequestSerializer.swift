//
//  KBAPIRequestSerializer.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/19/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

import Foundation

public protocol KBAPIEncoder: KBAPICoder {
	func encode <T> (_ parameters: T) throws -> Data where T: Encodable;
}

public protocol KBAPIRequestSerializerProtocol: KBAPICoder {
	func shouldSerializeRequestParametersAsBodyData <R> (for request: R) -> Bool where R: KBAPIRequest;
	func serializeRequest <R> (_ request: R) throws -> URLRequest where R: KBAPIRequest;
	func serializeParameters <P> (_ parameters: P, asBodyData: Bool, into request: inout URLRequest) throws where P: Encodable;
}

private let KBAPIRequestCommonHeaders = [
	"Accept": "application/json",
	"Accept-Encoding": "gzip, deflate",
];

public extension KBAPIRequestSerializerProtocol {
	private var commonHeaders: [String: String] {
		return KBAPIRequestCommonHeaders;
	}
	
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
		result.allHTTPHeaderFields = req.httpHeaders.merging (self.commonHeaders) { a, b in a };
		log.info ("Request: \(req.httpMethod.rawValue) \(req.url.absoluteString)");
		let parameters = req.parameters;
		log.info ("Parameters: \(parameters)");
		do {
			try self.serializeParameters (parameters, asBodyData: self.shouldSerializeRequestParametersAsBodyData (for: req), into: &result);
		} catch {
			log.warning ("Encoding error: \(error)");
			throw error;
		}
		result.allHTTPHeaderFields.map { headers in log.info ("Headers: [\(headers.map { "\($0.key): \($0.value)" }.joined (separator: ", "))]") };
		log.debug ("Serialized: \(result.makeCurlCommand ())");
		return result;
	}
}

open class KBAPIURLEncodingSerializer: KBAPIRequestSerializerProtocol {
	open var urlEncoder: KBAPIURLEncoderProtocol;
	open var userInfo: [CodingUserInfoKey: Any] {
		get { return self.urlEncoder.userInfo }
		set { self.urlEncoder.userInfo = newValue }
	}
	
	public init (urlEncoder: KBAPIURLEncoderProtocol = URLEncoder ()) {
		self.urlEncoder = urlEncoder;
	}
	
	open func serializeParameters <P> (_ parameters: P, asBodyData: Bool, into request: inout URLRequest) throws where P: Encodable {
		if let acceptLanguageHeaderValue = Bundle.main.preferredLocalizationsHTTPHeader {
			request.addValue (acceptLanguageHeaderValue, forHTTPHeaderField: "Accept-Language");
		}
		
		guard !asBodyData else {
			request.addValue ("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type");
			let encodedParameters: Data = try self.urlEncoder.encode (parameters);
			log.debug ("Encoded parameters: \(encodedParameters.debugLogDescription)");
			return request.httpBody = encodedParameters;
		}
		
		guard var urlComponents = request.url.flatMap ({ URLComponents (url: $0, resolvingAgainstBaseURL: false) }) else {
			log.fault ("Request URL is not set or is invalid");
			return;
		}
		
		let encodedParameters = try self.urlEncoder.encode (parameters) as [URLQueryItem];
		log.debug ("Encoded parameters: \(encodedParameters.debugLogDescription)");
		urlComponents.queryItems = urlComponents.queryItems.map { $0 + encodedParameters } ?? encodedParameters;
		guard let resultURL = urlComponents.url else {
			log.fault ("\(self.urlEncoder) did return invalid url query items");
			return;
		}
		request.url = resultURL;
	}
}

open class KBAPIJSONSerializer: KBAPIURLEncodingSerializer {
	open var jsonEncoder: KBAPIJSONEncoderProtocol;
	open override var userInfo: [CodingUserInfoKey: Any] {
		get { return super.userInfo }
		set {
			super.userInfo = newValue;
			self.jsonEncoder.userInfo = newValue;
		}
	}

	public init (urlEncoder: KBAPIURLEncoderProtocol? = nil, jsonEncoder: KBAPIJSONEncoderProtocol = JSONEncoder.defaultForRequestSerialization) {
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
		let encodedParameters: Data = try self.jsonEncoder.encode (parameters);
		log.debug ("Encoded parameters: \(encodedParameters.debugLogDescription)");
		request.httpBody = encodedParameters;
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

private let log = KBLoggerWrapper ();
