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
	func serializeRequest <R> (_ request: R) throws -> URLRequest where R: KBAPIRequest;
}

public protocol KBAPIRequestSerializerBase: KBAPIRequestSerializerProtocol {
	func shouldSerializeRequestParametersAsBodyData <R> (for request: R) -> Bool where R: KBAPIRequest;
	func serializeParameters <P> (_ parameters: P, asBodyData: Bool, into request: inout URLRequest) throws where P: Encodable;
}

public extension KBAPIRequestSerializerBase {
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

public protocol KBAPIURLEncoder: KBAPIEncoder {
	func encode <T> (_ parameters: T) throws -> [URLQueryItem] where T: Encodable;
}

open class KBAPIURLEncodingSerializer: KBAPIRequestSerializerBase {
	public struct URLEncoder: KBAPIURLEncoder {
		fileprivate final class Encoder <Result> {
			fileprivate private (set) var result: Result;
			fileprivate let codingPath: [CodingKey];
			
			fileprivate init (_ result: Result) {
				self.result = result;
				self.codingPath = [];
			}
		}
		
		public init () {}
		
		public func encode <T> (_ parameters: T) throws -> Data where T: Encodable {
			let encoder = Encoder (Data ());
			try parameters.encode (to: encoder);
			return encoder.result;
		}
		
		public func encode <T> (_ parameters: T) throws -> [URLQueryItem] where T: Encodable {
			let encoder = Encoder ([URLQueryItem] ());
			try parameters.encode (to: encoder);
			return encoder.result;
		}
	}
	
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

fileprivate typealias KBAPIURLEncoderImpl = KBAPIURLEncodingSerializer.URLEncoder.Encoder;

extension KBAPIURLEncoderImpl: Encoder {
	fileprivate struct Container <Key> {
		fileprivate var count = 0;
		fileprivate var codingPath: [CodingKey] {
			return self.baseCodingPath + [IndexKey (self.count)];
		}

		private let baseCodingPath: [CodingKey];
		private unowned let encoder: Encoder;

		fileprivate init (for encoder: Encoder, baseCodingPath: [CodingKey]) {
			self.encoder = encoder;
			self.baseCodingPath = baseCodingPath;
		}
	}
	
	private struct IndexKey: CodingKey {
		let stringValue: String;
		let intValue: Int?;
		
		init? (stringValue: String) {
			return nil;
		}
		
		init? (intValue: Int) {
			self.init (intValue);
		}
		
		init (_ value: Int) {
			self.intValue = value;
			self.stringValue = "\(value)";
		}
	}
	
	fileprivate var userInfo: [CodingUserInfoKey : Any] {
		return [:];
	}
	
	fileprivate func container <Key> (keyedBy type: Key.Type) -> KeyedEncodingContainer <Key> {
		return self.container (keyedBy: type, baseCodingPath: self.codingPath);
	}
	
	fileprivate func unkeyedContainer () -> UnkeyedEncodingContainer {
		return self.unkeyedContainer (baseCodingPath: self.codingPath);
	}
	
	fileprivate func singleValueContainer () -> SingleValueEncodingContainer {
		return self.singleValueContainer (baseCodingPath: self.codingPath);
	}
	
	private func container <Key> (keyedBy type: Key.Type, baseCodingPath: [CodingKey]) -> KeyedEncodingContainer <Key> {
		return KeyedEncodingContainer (Container (for: self, baseCodingPath: baseCodingPath));
	}
	
	private func unkeyedContainer (baseCodingPath: [CodingKey]) -> UnkeyedEncodingContainer {
		return Container <Void> (for: self, baseCodingPath: baseCodingPath);
	}
	
	private func singleValueContainer (baseCodingPath: [CodingKey]) -> SingleValueEncodingContainer {
		return Container <Void> (for: self, baseCodingPath: baseCodingPath);
	}

	private func encodeNilValue (for parameterName: String) {
		self.appendResultItem (name: codingPath.urlencodedParameterName, value: nil);
	}
	
	private func encodeValue (_ value: Bool, for parameterName: String) {
		self.appendResultItem (name: parameterName, value: value ? "1" : "0");
	}
	
	private func encodeValue <T> (_ value: T, for parameterName: String) where T: CustomStringConvertible {
		self.appendResultItem (name: parameterName, value: value.description);
	}
	
	private func encodeValue <I> (_ value: I, for parameterName: String) where I: BinaryInteger, I: Encodable {
		self.appendResultItem (name: parameterName, value: "\(value)");
	}
	
	private func encodeValue <I> (_ value: I, for parameterName: String) where I: FixedWidthInteger, I: Encodable {
		self.appendResultItem (name: parameterName, value: String (value));
	}
	
	private func encodeValue <F> (_ value: F, for parameterName: String) where F: FloatingPoint, F: Encodable, F: CustomStringConvertible {
		self.appendResultItem (name: parameterName, value: "\(value)");
	}
	
	private func encodeValue (_ value: Decimal, for parameterName: String) {
		self.appendResultItem (name: parameterName, value: value.description);
	}
	
	private func encodeValue (_ value: String, for parameterName: String) {
		self.appendResultItem (name: parameterName, value: .some (value));
	}
	
	private func encodeValue <S> (_ value: S, for parameterName: String) where S: StringProtocol {
		self.appendResultItem (name: parameterName, value: String (value));
	}

	private func encodeValue <T> (_ value: T, for parameterName: String) where T: Encodable {
		
	}

	private func appendResultItem (name: String, value: String?) {
		let itemDescription: String;
		if let value = value {
			itemDescription = "\"\(name)\" = \"\(value)\"";
		} else {
			itemDescription = "\"\(name)\"";
		}
		fatalError ("Cannot append \(itemDescription) item to \(self.result)");
	}
}

extension KBAPIURLEncoderImpl.Container: SingleValueEncodingContainer, UnkeyedEncodingContainer {
	fileprivate typealias Encoder = KBAPIURLEncoderImpl <Result>;
	
	private var currentParameterName: String {
		return self.codingPath.urlencodedParameterName;
	}
	
	fileprivate mutating func encodeNil () {
		self.encoder.encodeNilValue (for: self.currentParameterName);
		self.count += 1;
	}
	
	fileprivate mutating func encode (_ value: Bool) {
		self.encoder.encodeValue (value, for: self.currentParameterName);
		self.count += 1;
	}
	
	fileprivate mutating func encode <T> (_ value: T) where T: CustomStringConvertible {
		self.encoder.encodeValue (value, for: self.currentParameterName);
		self.count += 1;
	}
	
	fileprivate mutating func encode <I> (_ value: I) where I: BinaryInteger, I: Encodable {
		self.encoder.encodeValue (value, for: self.currentParameterName);
		self.count += 1;
	}
	
	fileprivate mutating func encode <I> (_ value: I) where I: FixedWidthInteger, I: Encodable {
		self.encoder.encodeValue (value, for: self.currentParameterName);
		self.count += 1;
	}
	
	fileprivate mutating func encode <F> (_ value: F) where F: FloatingPoint, F: Encodable, F: CustomStringConvertible {
		self.encoder.encodeValue (value, for: self.currentParameterName);
		self.count += 1;
	}
	
	fileprivate mutating func encode (_ value: Decimal) {
		self.encoder.encodeValue (value, for: self.currentParameterName);
		self.count += 1;
	}
	
	fileprivate mutating func encode (_ value: String) {
		self.encoder.encodeValue (value, for: self.currentParameterName);
		self.count += 1;
	}
	
	fileprivate mutating func encode <S> (_ value: S) where S: StringProtocol {
		self.encoder.encodeValue (value, for: self.currentParameterName);
		self.count += 1;
	}
	
	fileprivate mutating func encode <T> (_ value: T) throws where T: Encodable {
		self.encoder.encodeValue (value, for: self.currentParameterName);
		self.count += 1;
	}
	
	fileprivate func nestedContainer <NestedKey> (keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer <NestedKey> where NestedKey: CodingKey {
		return self.encoder.container (keyedBy: keyType, baseCodingPath: self.codingPath);
	}
	
	fileprivate func nestedUnkeyedContainer () -> UnkeyedEncodingContainer {
		return self.encoder.unkeyedContainer (baseCodingPath: self.codingPath);
	}
	
	fileprivate mutating func superEncoder () -> Swift.Encoder {
		return self.encoder;
	}
}

extension KBAPIURLEncoderImpl.Container: KeyedEncodingContainerProtocol where Key: CodingKey {
	fileprivate func encodeNil (forKey key: Key) {
		self.encoder.encodeNilValue (for: self.parameterName (forKey: key));
	}
	
	fileprivate func encode (_ value: Bool, forKey key: Key) {
		self.encoder.encodeValue (value, for: self.parameterName (forKey: key));
	}
	
	fileprivate func encode <T> (_ value: T, forKey key: Key) where T: CustomStringConvertible {
		self.encoder.encodeValue (value, for: self.parameterName (forKey: key));
	}

	fileprivate func encode <I> (_ value: I, forKey key: Key) where I: BinaryInteger, I: Encodable {
		self.encoder.encodeValue (value, for: self.parameterName (forKey: key));
	}
	
	fileprivate func encode <I> (_ value: I, forKey key: Key) where I: FixedWidthInteger, I: Encodable {
		self.encoder.encodeValue (value, for: self.parameterName (forKey: key));
	}
	
	fileprivate func encode <F> (_ value: F, forKey key: Key) where F: FloatingPoint, F: Encodable, F: CustomStringConvertible {
		self.encoder.encodeValue (value, for: self.parameterName (forKey: key));
	}
	
	fileprivate func encode (_ value: Decimal, forKey key: Key) {
		self.encoder.encodeValue (value, for: self.parameterName (forKey: key));
	}
	
	fileprivate func encode (_ value: String, forKey key: Key) {
		self.encoder.encodeValue (value, for: self.parameterName (forKey: key));
	}
	
	fileprivate func encode <S> (_ value: S, forKey key: Key) where S: StringProtocol {
		self.encoder.encodeValue (value, for: self.parameterName (forKey: key));
	}
	
	fileprivate func encode <T> (_ value: T, forKey key: Key) throws where T: Encodable {
		self.encoder.encodeValue (value, for: self.parameterName (forKey: key));
	}
	
	fileprivate func nestedContainer <NestedKey> (keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer <NestedKey> where NestedKey: CodingKey {
		return self.encoder.container (keyedBy: keyType, baseCodingPath: self.codingPath (forKey: key));
	}
	
	fileprivate func nestedUnkeyedContainer (forKey key: Key) -> UnkeyedEncodingContainer {
		return self.encoder.unkeyedContainer (baseCodingPath: self.codingPath (forKey: key));
	}
	
	fileprivate func superEncoder (forKey key: Key) -> Swift.Encoder {
		return self.encoder;
	}
	
	private func codingPath (forKey key: Key) -> [CodingKey] {
		return self.baseCodingPath + [key];
	}
	
	private func parameterName (forKey key: Key) -> String {
		return self.codingPath (forKey: key).urlencodedParameterName;
	}
}

fileprivate extension KBAPIURLEncoderImpl where Result == Data {
	private static let interitemDelimiterData = "&".data (using: .utf8)!;
	private static let nameValueDelimiterData = "=".data (using: .utf8)!;

	fileprivate func appendResultItem (name: String, value: String?) {
		let useIteritemDelimiter = self.result.isEmpty, nameLength = name.lengthOfBytes (using: .utf8);
		let (useNameValueDelimiter, valueLength) = value.map { (true, $0.lengthOfBytes (using: .utf8)) } ?? (false, 0);
		self.result.reserveCapacity (self.result.count + (useIteritemDelimiter ? 0 : 1) + nameLength + (useNameValueDelimiter ? 1 : 0) + valueLength);
		if (useIteritemDelimiter) {
			self.result.append (KBAPIURLEncoderImpl.interitemDelimiterData);
		}
		name.data (using: .utf8).map { self.result.append ($0) };
		if (useNameValueDelimiter) {
			self.result.append (KBAPIURLEncoderImpl.nameValueDelimiterData);
		}
		value?.data (using: .utf8).map { self.result.append ($0) };
	}
}

fileprivate extension KBAPIURLEncoderImpl where Result == [URLQueryItem] {
	fileprivate func appendResultItem (name: String, value: String?) {
		self.result.append (URLQueryItem (name: name, value: value));
	}
}

public protocol KBAPIJSONEncoder: KBAPIEncoder {
	var outputFormatting: JSONEncoder.OutputFormatting { get set }
	var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy { get set }
	var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get set }
	var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy { get set }
	var nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy { get set }
}

open class KBAPIJSONSerializer: KBAPIURLEncodingSerializer {
	open let jsonEncoder: KBAPIJSONEncoder;

	public init (urlEncoder: KBAPIURLEncoder? = nil, jsonEncoder: KBAPIJSONEncoder = JSONEncoder.defaultForRequestSerialization) {
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

extension JSONEncoder: KBAPIJSONEncoder {
	public static var defaultForRequestSerialization: JSONEncoder {
		let result = JSONEncoder ();
#if DEBUG
		if #available(iOS 11.0, *) {
			result.outputFormatting = [.prettyPrinted, .sortedKeys];
		} else {
			result.outputFormatting = [.prettyPrinted];
		}
#endif
		result.keyEncodingStrategy = .convertToSnakeCase;
		result.dateEncodingStrategy = .secondsSince1970;
		result.dataEncodingStrategy = .base64;
		result.nonConformingFloatEncodingStrategy = .convertToString (positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan");
		return result;
	}
}

fileprivate extension Array where Element == CodingKey {
	fileprivate var urlencodedParameterName: String {
		guard let nameHead = self.first?.stringValue else {
			return "";
		}
		let nameTail = self.dropFirst ();
		guard !nameTail.isEmpty else {
			return nameHead;
		}
		return nameHead + "[" + nameTail.map { $0.stringValue }.joined (separator: "][") + "]";
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
