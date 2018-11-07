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

open class KBAPIMultipartFormDataRequestSerializer: KBAPIRequestSerializerProtocol {
	public struct UploadedFile {
		public let data: Data
		public let filename: String
		public let contentType: String
		
		public init (data: Data, filename: String = "file.bin", contentType: String = "appication/octet-stream") {
			self.data = data
			self.filename = filename
			self.contentType = contentType
		}
		
		fileprivate var escapedFilename: String {
			let allowedCharacters = CharacterSet.urlQueryAllowed
			return String (String.UnicodeScalarView (self.filename.unicodeScalars.compactMap { allowedCharacters.contains ($0) ? $0 : "_" })).replacingOccurrences (of: "\"", with: "\\\"")
		}
		
		fileprivate func multipartFormData (boundary: String, fieldName: String) -> Data {
			let headerData = (
				"--\(boundary)\r\n" +
				"Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(self.escapedFilename)\"\r\n" +
				"Content-Type: \(self.contentType)\r\n" +
				"\r\n"
			).data (using: .utf8)!
			let footerData = "\r\n".data (using: .utf8)!
			return headerData + self.data + footerData;
		}
	}
	
	private enum Error: Swift.Error {
		case unsupportedDestination;
		case unsupportedParameters;
	}
	
	open var userInfo = [CodingUserInfoKey: Any] ();
	private let boundary: String
	
	public init () {
		let randomValue = (UInt64 (arc4random ()) << 32) | UInt64 (arc4random ());
		self.boundary = "KBAPISupport_boundary_hi_there_who_reads_this_\(String (randomValue, radix: 16, uppercase: true))";
	}

	open func serializeParameters <P> (_ parameters: P, asBodyData: Bool, into request: inout URLRequest) throws where P: Encodable {
		guard asBodyData else {
			throw Error.unsupportedDestination;
		}
		guard let parameters = parameters as? [String: UploadedFile] else {
			throw Error.unsupportedParameters;
		}
		try self.serializeUploadedFiles (parameters, into: &request);
	}
	
	private func serializeUploadedFiles (_ uploadedFiles: [String: UploadedFile], into request: inout URLRequest) throws {
		request.httpBody = uploadedFiles.compactMap {
			$0.value.multipartFormData (boundary: self.boundary, fieldName: $0.key)
		}.reduce (into: Data ()) { $0 += $1 } + "--\(self.boundary)--\r\n".data (using: .utf8)!;
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

private let KBAPIRequestCommonHeaders = [
	"Accept": "application/json",
	"Accept-Encoding": "gzip, deflate",
];

private let log = KBLoggerWrapper ();
