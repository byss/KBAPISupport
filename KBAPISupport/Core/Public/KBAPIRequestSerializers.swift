//
//  KBAPIRequestSerializers.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/19/18.
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
import MobileCoreServices

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
#if DEBUG
		log.debug ("Serialized: \(result.makeCurlCommand ())");
#else
		log.debug ("Serialized: \(result)");
#endif
		return result;
	}

	public func serializeParameters <P> (_ parameters: P, asBodyData: Bool, into request: inout URLRequest) throws where P: Encodable {
		log.fault ("\(Self.self) does not implement \(#function)");
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

	public init (jsonEncoder: KBAPIJSONEncoderProtocol = JSONEncoder.defaultForRequestSerialization) {
		self.jsonEncoder = jsonEncoder;
		super.init ();
	}
	
	public init (urlEncoder: KBAPIURLEncoderProtocol, jsonEncoder: KBAPIJSONEncoderProtocol = JSONEncoder.defaultForRequestSerialization) {
		self.jsonEncoder = jsonEncoder;
		super.init (urlEncoder: urlEncoder);
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

open class KBAPIMultipartFormDataRequestSerializer: KBAPIURLEncodingSerializer {
	open var multipartFormDataEncoder: KBAPIMultipartFormDataEncoderProtocol;
	
	open override var userInfo: [CodingUserInfoKey: Any] {
		get { return super.userInfo }
		set {
			var userInfo = newValue;
			userInfo [.multipartFormBoundary] = self.boundary;
			super.userInfo = userInfo;
		}
	}
	
	private var boundary: String {
		return self.multipartFormDataEncoder.boundary;
	}

	public init () {
		let boundary = "KBAPISupport_boundary_hi_there_who_reads_this_\(String (UInt64 ((arc4random ()) << 32) | UInt64 (arc4random ()), radix: 16, uppercase: true))";
		self.multipartFormDataEncoder = KBAPIMultipartFormDataEncoder (boundary: boundary);
		super.init ();
	}

	open override func serializeParameters <P> (_ parameters: P, asBodyData: Bool, into request: inout URLRequest) throws where P: Encodable {
		guard asBodyData else {
			return try super.serializeParameters (parameters, asBodyData: asBodyData, into: &request);
		}
		request.addValue ("multipart/form-data; boundary=\(self.boundary)", forHTTPHeaderField: "Content-Type");
		let streamedParameters: InputStream? = try self.multipartFormDataEncoder.encode (parameters);
		log.debug ("Encoded parameters: \(streamedParameters.debugLogDescription)");
		request.httpBodyStream = streamedParameters;
	}
}

public extension CodingUserInfoKey {
	public static let multipartFormBoundary = CodingUserInfoKey (rawValue: "multipartFormBoundary")!;
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

private let KBAPIRequestCommonHeaders = [
	"Accept": "application/json",
	"Accept-Encoding": "gzip, deflate",
];

private let log = KBLoggerWrapper ();
