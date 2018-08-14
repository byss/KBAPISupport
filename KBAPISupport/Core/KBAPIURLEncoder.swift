//
//  KBAPIURLEncoder.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/20/18.
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

public protocol KBAPIURLEncoderProtocol: KBAPIEncoder {
	func encode <T> (_ parameters: T) throws -> [URLQueryItem] where T: Encodable;
}

private protocol KBAPIURLEncoderContainer {
	associatedtype ResultType where ResultType: KBAPIURLEncoderResult;
	
	typealias EncoderType = KBAPIURLEncoder.Encoder <ResultType>;

	var encoder: EncoderType { get }
	var baseCodingPath: [CodingKey] { get }
	
	init (for encoder: EncoderType, baseCodingPath: [CodingKey]);
}

private protocol KBAPIURLEncoderKeyedContainer: KBAPIURLEncoderContainer, KeyedEncodingContainerProtocol {}
private protocol KBAPIURLEncoderUnkeyedContainer: KBAPIURLEncoderContainer, UnkeyedEncodingContainer {
	var count: Int { get set }
}
private protocol KBAPIURLEncoderSingleValueContainer: KBAPIURLEncoderContainer, SingleValueEncodingContainer {}

private protocol KBAPIURLEncoderResult {
	init ();
	
	mutating func appendResultValue (_ value: String?, for parameterName: String);
}

extension Data: KBAPIURLEncoderResult {
	private static let interitemDelimiter = "&".utf8;
	private static let nameValueDelimiter = "=".utf8;
	
	fileprivate mutating func appendResultValue (_ value: String?, for parameterName: String) {
		let components = [
			self.currentInteritemDelimiterData,
			parameterName.utf8,
			value.map { _ in Data.nameValueDelimiter },
			value?.utf8,
		].compactMap { $0 };
		
		self.reserveCapacity (self.count + components.reduce (into: 0) { $0 += $1.count });
		for component in components {
			self.append (contentsOf: component);
		}
	}
	
	private var currentInteritemDelimiterData: String.UTF8View? {
		return self.isEmpty ? nil : Data.interitemDelimiter;
	}
}

extension Array: KBAPIURLEncoderResult where Element == URLQueryItem {
	fileprivate mutating func appendResultValue (_ value: String?, for parameterName: String) {
		self.append (URLQueryItem (name: parameterName, value: value));
	}
}

public struct KBAPIURLEncoder: KBAPIURLEncoderProtocol {
	public var userInfo = [CodingUserInfoKey: Any] ();
	
	public init () {}
	
	public func encode <T> (_ parameters: T) throws -> Data where T: Encodable {
		return try self.encode (parameters: parameters);
	}

	public func encode <T> (_ parameters: T) throws -> [URLQueryItem] where T: Encodable {
		return try self.encode (parameters: parameters);
	}
	
	private func encode <T, R> (parameters: T) throws -> R where T: Encodable, R: KBAPIURLEncoderResult {
		let encoder = Encoder (R (), userInfo: self.userInfo);
		try parameters.encode (to: encoder);
		return encoder.result;
	}
}

extension KBAPIURLEncoder {
	fileprivate class Encoder <Result> where Result: KBAPIURLEncoderResult {
		fileprivate typealias ResultType = Result;
		
		fileprivate let userInfo: [CodingUserInfoKey: Any];
		
		fileprivate private (set) var result: Result;
		fileprivate var codingPath: [CodingKey] {
			return [];
		}
		
		fileprivate init (_ result: Result, userInfo: [CodingUserInfoKey: Any]) {
			self.userInfo = userInfo;
			self.result = result;
		}
	}
	
	fileprivate struct SuperEncoder <Result> where Result: KBAPIURLEncoderResult {
		fileprivate typealias Parent = Encoder <Result>;
		
		fileprivate let codingPath: [CodingKey];
		fileprivate unowned let rootEncoder: Parent;
		
		fileprivate init (root rootEncoder: Parent, codingPath: [CodingKey]) {
			self.rootEncoder = rootEncoder;
			self.codingPath = codingPath;
		}
	}
}

private protocol KBAPIURLEncoderImplementation {
	associatedtype ResultType;
	associatedtype UnkeyedContainer where UnkeyedContainer: KBAPIURLEncoderUnkeyedContainer, UnkeyedContainer.ResultType == Self.ResultType;
	associatedtype SingleValueContainer where SingleValueContainer: KBAPIURLEncoderSingleValueContainer, SingleValueContainer.ResultType == Self.ResultType;
	
	var rootEncoder: KBAPIURLEncoder.Encoder <ResultType> { get };
	
	static func makeContainer <Key> (keyedBy type: Key.Type, for encoder: Self, baseCodingPath: [CodingKey]) -> KeyedEncodingContainer <Key>;
	
	func appendResultValue (_ value: String?, for codingPath: [CodingKey]);
}

extension KBAPIURLEncoder.Encoder: KBAPIURLEncoderImplementation, Encoder {
	fileprivate var rootEncoder: KBAPIURLEncoder.Encoder <Result> {
		return self;
	}
	
	fileprivate static func makeContainer <Key> (keyedBy type: Key.Type, for encoder: KBAPIURLEncoder.Encoder <Result>, baseCodingPath: [CodingKey]) -> KeyedEncodingContainer <Key> {
		return KeyedEncodingContainer (KeyedContainer (for: encoder, baseCodingPath: baseCodingPath));
	}
	
	fileprivate func appendResultValue (_ value: String?, for codingPath: [CodingKey]) {
		self.appendResultValue (value, for: codingPath.urlencodedParameterName);
	}
	
	fileprivate func appendResultValue (_ value: String?, for parameterName: String) {
		self.result.appendResultValue (value, for: parameterName);
	}
}

extension KBAPIURLEncoder.SuperEncoder: KBAPIURLEncoderImplementation, Encoder {
	fileprivate typealias UnkeyedContainer = Parent.UnkeyedContainer;
	fileprivate typealias SingleValueContainer = Parent.SingleValueContainer;

	fileprivate var userInfo: [CodingUserInfoKey : Any] {
		return self.rootEncoder.userInfo;
	}
	
	fileprivate static func makeContainer <Key> (keyedBy type: Key.Type, for encoder: KBAPIURLEncoder.SuperEncoder <ResultType>, baseCodingPath: [CodingKey]) -> KeyedEncodingContainer <Key> {
		return Parent.makeContainer (keyedBy: type, for: encoder.rootEncoder, baseCodingPath: encoder.codingPath + baseCodingPath);
	}
	
	fileprivate func appendResultValue (_ value: String?, for codingPath: [CodingKey]) {
		self.rootEncoder.appendResultValue (value, for: self.codingPath + codingPath);
	}
}

extension KBAPIURLEncoderImplementation where Self: Encoder {
	fileprivate func encodeNilValue (for codingPath: [CodingKey]) {
		self.appendResultValue (nil, for: codingPath);
	}
	
	fileprivate func encodeValue <T> (_ value: T, for codingPath: [CodingKey]) where T: Encodable {
		let valueString: String;
		switch (value) {
		case let boolValue as Bool:
			valueString = (boolValue ? "1" : "0");
		case let string as String:
			valueString = string;
		case let convertible as CustomStringConvertible:
			valueString = convertible.description;
		default:
			valueString = "\(value)";
		}
		self.appendResultValue (valueString, for: codingPath);
	}
	
	fileprivate func encodeValue <T> (_ value: T, for codingPath: [CodingKey]) where T: Encodable, T: StringProtocol {
		self.appendResultValue (String (value), for: codingPath);
	}
	
	fileprivate func encodeValue <T> (_ value: T, for codingPath: [CodingKey]) where T: Encodable, T: FixedWidthInteger {
		self.appendResultValue (String (value), for: codingPath);
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
	
	fileprivate func container <Key> (keyedBy type: Key.Type, baseCodingPath: [CodingKey]) -> KeyedEncodingContainer <Key> {
		return Self.makeContainer (keyedBy: type, for: self, baseCodingPath: baseCodingPath);
	}
	
	fileprivate func unkeyedContainer (baseCodingPath: [CodingKey]) -> UnkeyedEncodingContainer {
		return UnkeyedContainer.init (for: self.rootEncoder, baseCodingPath: baseCodingPath);
	}
	
	fileprivate func singleValueContainer (baseCodingPath: [CodingKey]) -> SingleValueEncodingContainer {
		return SingleValueContainer.init (for: self.rootEncoder, baseCodingPath: baseCodingPath);
	}
}

fileprivate extension CodingKey {
	fileprivate static var `super`: Self {
		guard let result = Self (stringValue: "super") ?? Self (intValue: 0) else {
			log.fault ("Cannot instantiate \"super\" / zero key");
			return Self (stringValue: "super")!;
		}
		return result;
	}
}

extension KBAPIURLEncoderKeyedContainer {
	fileprivate var codingPath: [CodingKey] {
		return self.baseCodingPath;
	}
	
	fileprivate func encodeNil (forKey key: Key) {
		self.encoder.encodeNilValue (for: self.codingPath (forKey: key));
	}
	
	fileprivate func encode <T> (_ value: T, forKey key: Key) throws where T: Encodable {
		self.encoder.encodeValue (value, for: self.codingPath (forKey: key));
	}
	
	fileprivate func encode <T> (_ value: T, forKey key: Key) throws where T: Encodable, T: StringProtocol {
		self.encoder.encodeValue (value, for: self.codingPath (forKey: key));
	}
	
	fileprivate func encode <T> (_ value: T, forKey key: Key) throws where T: Encodable, T: FixedWidthInteger {
		self.encoder.encodeValue (value, for: self.codingPath (forKey: key));
	}
	
	fileprivate func nestedContainer <NestedKey> (keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer <NestedKey> where NestedKey: CodingKey {
		return self.encoder.container (keyedBy: keyType, baseCodingPath: self.codingPath (forKey: key));
	}
	
	fileprivate func nestedUnkeyedContainer (forKey key: Key) -> UnkeyedEncodingContainer {
		return self.encoder.unkeyedContainer (baseCodingPath: self.codingPath (forKey: key));
	}
	
	fileprivate func superEncoder () -> Encoder {
		return self.superEncoder (forKey: .super);
	}
	
	fileprivate func superEncoder (forKey key: Key) -> Swift.Encoder {
		return KBAPIURLEncoder.SuperEncoder (root: self.encoder.rootEncoder, codingPath: self.codingPath (forKey: key));
	}
	
	private func codingPath (forKey key: Key) -> [CodingKey] {
		return self.baseCodingPath + [key];
	}
}

private struct ContainerIndexKey: CodingKey {
	fileprivate var intValue: Int? {
		return self.value;
	}
	fileprivate var stringValue: String {
		return "\(self.value)";
	}
	
	private let value: Int;
	
	fileprivate init? (intValue: Int) {
		return nil;
	}
	
	fileprivate init? (stringValue: String) {
		return nil;
	}
	
	fileprivate init (_ value: Int) {
		self.value = value;
	}
}

extension KBAPIURLEncoderUnkeyedContainer {
	fileprivate var codingPath: [CodingKey] {
		return self.baseCodingPath + [ContainerIndexKey (self.count)];
	}

	fileprivate mutating func advanceCodingPath () -> [CodingKey] {
		let oldCodingPath = self.codingPath;
		self.count += 1;
		return oldCodingPath;
	}
	
	fileprivate func encodeNil () {
		self.encoder.encodeNilValue (for: self.codingPath);
	}
	
	fileprivate mutating func encode <T> (_ value: T) where T: Encodable {
		self.encoder.encodeValue (value, for: self.advanceCodingPath ());
	}

	fileprivate mutating func encode <T> (_ value: T) throws where T: Encodable, T: StringProtocol {
		self.encoder.encodeValue (value, for: self.advanceCodingPath ());
	}
	
	fileprivate mutating func encode <T> (_ value: T) throws where T: Encodable, T: FixedWidthInteger {
		self.encoder.encodeValue (value, for: self.advanceCodingPath ());
	}
	fileprivate mutating func nestedContainer <NestedKey> (keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer <NestedKey> where NestedKey: CodingKey {
		return self.encoder.container (keyedBy: keyType, baseCodingPath: self.advanceCodingPath ());
	}
	
	fileprivate mutating func nestedUnkeyedContainer () -> UnkeyedEncodingContainer {
		return self.encoder.unkeyedContainer (baseCodingPath: self.advanceCodingPath ());
	}
	
	fileprivate mutating func superEncoder () -> Swift.Encoder {
		return KBAPIURLEncoder.SuperEncoder (root: self.encoder.rootEncoder, codingPath: self.advanceCodingPath ());
	}
}

extension KBAPIURLEncoderSingleValueContainer {
	fileprivate var codingPath: [CodingKey] {
		return self.baseCodingPath;
	}
	
	fileprivate func encodeNil () {
		self.encoder.encodeNilValue (for: self.codingPath);
	}
	
	fileprivate func encode <T> (_ value: T) throws where T: Encodable {
		self.encoder.encodeValue (value, for: self.codingPath);
	}
	
	fileprivate func encode <T> (_ value: T) throws where T: Encodable, T: StringProtocol {
		self.encoder.encodeValue (value, for: self.codingPath);
	}

	fileprivate func encode <T> (_ value: T) where T: Encodable, T: FixedWidthInteger {
		self.encoder.encodeValue (value, for: self.codingPath);
	}
}

fileprivate extension KBAPIURLEncoder.Encoder {
	fileprivate struct KeyedContainer <Key>: KBAPIURLEncoderKeyedContainer where Key: CodingKey {
		fileprivate unowned let encoder: KBAPIURLEncoder.Encoder <ResultType>;
		fileprivate let baseCodingPath: [CodingKey];
		
		fileprivate init (for encoder: KBAPIURLEncoder.Encoder <ResultType>, baseCodingPath: [CodingKey]) {
			self.encoder = encoder;
			self.baseCodingPath = baseCodingPath;
		}
	}
	
	fileprivate struct UnkeyedContainer: KBAPIURLEncoderUnkeyedContainer {
		fileprivate unowned let encoder: KBAPIURLEncoder.Encoder <ResultType>;
		fileprivate let baseCodingPath: [CodingKey];
		
		fileprivate var count = 0;
		
		fileprivate init (for encoder: KBAPIURLEncoder.Encoder <ResultType>, baseCodingPath: [CodingKey]) {
			self.encoder = encoder;
			self.baseCodingPath = baseCodingPath;
		}
	}
	
	fileprivate struct SingleValueContainer: KBAPIURLEncoderSingleValueContainer {
		fileprivate unowned let encoder: KBAPIURLEncoder.Encoder <ResultType>;
		fileprivate let baseCodingPath: [CodingKey];
		
		fileprivate init (for encoder: KBAPIURLEncoder.Encoder <ResultType>, baseCodingPath: [CodingKey]) {
			self.encoder = encoder;
			self.baseCodingPath = baseCodingPath;
		}
	}
}

public extension KBAPIURLEncodingSerializer {
	public typealias URLEncoder = KBAPIURLEncoder;
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

private let log = KBLoggerWrapper ();
