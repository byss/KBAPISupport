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

// According to nearly any sane person (including me 30s ago), this extension must reside in same file as
// KBAPIRequestSerializerProtocol's declaration, but when you'd have a second look you will definitely find
// that the extension in question is definitely a superclass definition in protocol's disguise and contains
// very same amount of executable statements vs. various declarations declarations. So, here we are.
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
		log.info ("Request: \(req.httpMethod.rawValue) \(req.url.absoluteString)");

		result.allHTTPHeaderFields = req.httpHeaders.merging (KBAPIRequestDefaultHeaders) { a, b in a };
		result.allHTTPHeaderFields.map { headers in log.info ("Headers: [\(headers.map { "\($0.key): \($0.value)" }.joined (separator: ", "))]") };
		
		let parameters = req.parameters;
		log.info ("Parameters: \(parameters)");
		do {
			try self.serializeParameters (parameters, asBodyData: self.shouldSerializeRequestParametersAsBodyData (for: req), into: &result);
		} catch {
			log.warning ("Encoding error: \(error)");
			throw error;
		}
		return result;
	}

	public func serializeParameters <P> (_ parameters: P, asBodyData: Bool, into request: inout URLRequest) throws where P: Encodable {
		log.fault ("\(Self.self) does not implement \(#function)");
	}
}

/// Basic www-form url serializer implementation.
///
/// Got it? Got it? Huh? Shame on you. It's the least sofisticated one AND is theirs superclass at the same time!
///
/// This serializer does perform the following request modifications:
///  * Sets Accept-Language header (up to 6 preferred languages with weights of 1.0, 0.5, 0.25 etc.)
///  * Declares "application/x-www-form-urlencoded" Content-Type.
///  * Performs well-known "percent-encoded" serialization when `asBodyData` is `false`, and slightly more optimized
///    version of the same algorithm for `true`. Refer to the [KBAPIURLEncoder] docs/source for encoding specifics.
///
/// [KBAPIURLEncoder]: file:///Users/byss/Repos/KBAPISupport/KBAPISupport/Core/Public/KBAPIURLEncoder.swift
open class KBAPIURLEncodingSerializer: KBAPIRequestSerializerProtocol {
	/// Encoder utilized by this serializer instance
	open var urlEncoder: KBAPIURLEncoderProtocol;
	open var userInfo: [CodingUserInfoKey: Any] {
		get { return self.urlEncoder.userInfo }
		set { self.urlEncoder.userInfo = newValue }
	}
	
	/// Creates an instance of URL-encoded request serializer object.
	///
	/// - Parameter urlEncoder: URL encoder to use for all encoding operations, defaulting to KBAPIURLEncoder instance.
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

/// Basic JSON request serializer implementation.
///
/// It inherits from `KBAPIURLEncodingSerializer` and exhibits identical behaviour for `GET`/`DELETE`
/// requests. For all other requests the modifications of the request include:
///  * All `KBAPIURLEncodingSerializer`s modifications.
///  * Content-Type is then overwritten to "application/json".
///  * Parameters are dumped into request body using current `jsonEncoder` settings.
///
/// See also:
/// 	[JSONEncoder.OutputFormatting](https://developer.apple.com/documentation/foundation/jsonencoder/outputformatting),
///   [JSONEncoder.KeyEncodingStrategy](https://developer.apple.com/documentation/foundation/jsonencoder/keyencodingstrategy),
///   [JSONEncoder.DateEncodingStrategy](https://developer.apple.com/documentation/foundation/jsonencoder/dateencodingstrategy),
///   [JSONEncoder.DataEncodingStrategy](https://developer.apple.com/documentation/foundation/jsonencoder/dataencodingstrategy),
///   [JSONEncoder.NonConformingFloatEncodingStrategy](https://developer.apple.com/documentation/foundation/jsonencoder/nonconformingfloatencodingstrategy)
///
open class KBAPIJSONSerializer: KBAPIURLEncodingSerializer {
	/// This encoder performs all JSON output according to its settings.
	open var jsonEncoder: KBAPIJSONEncoderProtocol;
	open override var userInfo: [CodingUserInfoKey: Any] {
		get { return super.userInfo }
		set {
			super.userInfo = newValue;
			self.jsonEncoder.userInfo = newValue;
		}
	}

	/// Creates an instance of JSON/URL-encoded request serializer object.
	///
	/// - Parameters
	///   - jsonEncoder: JSON encoder to use when encoding JSON, defaults to `JSONEncoder.defaultForRequestSerialization`.
	public init (jsonEncoder: KBAPIJSONEncoderProtocol = JSONEncoder.defaultForRequestSerialization) {
		self.jsonEncoder = jsonEncoder;
		super.init ();
	}
	
	/// Creates an instance of JSON/URL-encoded request serializer object.
	///
	/// - Parameters
	///   - urlEncoder: URL encoder to use for all encoding operations, defaulting to `KBAPIURLEncoder` instance.
	///   - jsonEncoder: JSON encoder to use when encoding JSON, defaults to `JSONEncoder.defaultForRequestSerialization`.
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

/// This serializer performs  multipart/form-data serialization.
///
/// It inherits from `KBAPIURLEncodingSerializer` and exhibits identical behaviour for `GET`/`DELETE`
/// requests. For all other requests the modifications of the request include:
///  * All `KBAPIURLEncodingSerializer`s modifications.
///  * Content-Type is then overwritten to "multipart/form-data" with a unique boundary string.
///  * An instance of [KBAPIMultipartFormDataEncoder] is used to encode parameters as per
///    [RFC2388](https://tools.ietf.org/html/rfc2388) and then merge resulting pieces
///    into a single [InputStream].
///
/// For more detais and encoding specifics pleease refer to the [KBAPIMultipartFormDataEncoder] docs/source
///.
/// [InputStream]: https://developer.apple.com/documentation/foundation/inputstream
///
/// [KBAPIMultipartFormDataEncoder]: file:///Users/byss/Repos/KBAPISupport/KBAPISupport/Core/Public/KBAPIMultipartFormDataEncoder.swift
///
open class KBAPIMultipartFormDataRequestSerializer: KBAPIURLEncodingSerializer {
	/// Multipart/form-data encoder used by this serializer.
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

	/// Creates an instance of multipart request serializer object.
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
	/// Key for boundary string used as fields separator when performing multipart request encoding.
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

private let KBAPIRequestDefaultHeaders = __bridge_KBAPIRequestDefaultHeaders ();
private let log = KBLoggerWrapper ();
