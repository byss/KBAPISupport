//
//  KBAPIMultipartFormDataEncoder.swift
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

public protocol KBAPIMultipartFormDataEncoderProtocol: KBAPIEncoder {
	var boundary: String { get }
	
	func encode <T> (_ parameters: T) throws -> InputStream? where T: Encodable;
}

public struct KBAPIMultipartFormDataEncoder: KBAPIMultipartFormDataEncoderProtocol {
	public var userInfo = [CodingUserInfoKey: Any] ();
	
	public let boundary: String;
	
	public init (boundary: String) {
		self.boundary = boundary;
	}

	public func encode <T> (_ parameters: T) throws -> Data where T: Encodable {
		var result = Data ();
		if let stream: InputStream = try self.encode (parameters) {
			try stream.readAll { result.append ($0.assumingMemoryBound (to: UInt8.self), count: $1) };
		}
		return result;
	}
	
	public func encode <T> (_ parameters: T) throws -> InputStream? where T: Encodable {
		let encoder = Encoder (self.boundary);
		try parameters.encode (to: encoder);
		return encoder.result;
	}
}

fileprivate extension KBAPIMultipartFormDataEncoder {
	fileprivate final class Encoder: Swift.Encoder {
		fileprivate var userInfo = [CodingUserInfoKey: Any] ();

		fileprivate var result: InputStream? {
			if !self.finishingBoundaryAdded {
				try! self.appendFinishingBoundary ();
			}
			return KBCompoundInputStream (self.substreams);
		}

		fileprivate var codingPath: CodingPath {
			return [];
		}
		
		fileprivate let boundary: String;

		private var substreams = [InputStream] ();
		private var finishingBoundaryAdded = false;
		
		fileprivate init (_ boundary: String) {
			self.boundary = boundary;
		}
		
		fileprivate func container <Key> (keyedBy type: Key.Type) -> Swift.KeyedEncodingContainer <Key> where Key: CodingKey {
			return Swift.KeyedEncodingContainer (KeyedEncodingContainer (self));
		}
		
		fileprivate func unkeyedContainer () -> Swift.UnkeyedEncodingContainer {
			return UnkeyedEncodingContainer (self);
		}
		
		fileprivate func singleValueContainer () -> Swift.SingleValueEncodingContainer {
			return SingleValueEncodingContainer (self);
		}

		fileprivate func appendBoringValue <T> (_ value: T, for codingPath: CodingPath) throws where T: Encodable {
			if let fileUpload = value as? KBAPIFileUploadProtocol {
				try self.appendFileUpload (fileUpload, for: codingPath);
			} else {
				try self.appendBoringValue (String (urlRequestSerialized: value), for: codingPath);
			}
		}

		fileprivate func appendBoringValue <T> (_ value: T, for codingPath: CodingPath) throws where T: Encodable, T: FixedWidthInteger {
			try self.appendBoringValue (String (value), for: codingPath);
		}
		
		fileprivate func appendBoringValue <T> (_ value: T, for codingPath: CodingPath) throws where T: Encodable, T: StringProtocol, T.Index == String.Index {
			guard let encodedValue = value.data (using: .utf8) else {
				throw EncodingError.invalidValue (value, EncodingError.Context (codingPath: codingPath, debugDescription: "Cannot convert to UTF-8"));
			}
			try self.appendFileUpload (KBAPIDataUpload (data: encodedValue, filename: codingPath.last?.stringValue ?? "some.txt", mimeType: "text/plain"), for: codingPath);
		}

		fileprivate func appendBoringValue (_ value: Data, mimeType: String = "application/octet-stream", for codingPath: CodingPath) throws {
			try self.appendFileUpload (KBAPIDataUpload (data: value, filename: codingPath.last?.stringValue ?? "file.bin", mimeType: mimeType), for: codingPath);
		}
		
		fileprivate func appendFileUpload (_ fileUpload: KBAPIFileUploadProtocol, for codingPath: CodingPath) throws {
			guard !self.finishingBoundaryAdded else {
				throw EncodingError.invalidValue (self.boundary, EncodingError.Context (codingPath: codingPath, debugDescription: "Cannot add data after finishing boundary"));
			}
			
			let fieldName = codingPath.urlencodedParameterName, boundary = self.boundary;
			let escapedFilename = fileUpload.filename.escapedForMultipartEnccoding, escapedMimeType = fileUpload.mimeType.escapedForMultipartEnccoding;
			self.substreams += [
				InputStream (data: (
					"--\(boundary)\r\n" +
					"Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(escapedFilename)\"\r\n" +
					"Content-Type: \(escapedMimeType)\r\n" +
					"\r\n"
				).data (using: .utf8)!),
			
				fileUpload.contentsStream,
			
				InputStream (data: "\r\n".data (using: .utf8)!),
			];
		}
		
		fileprivate func appendFinishingBoundary () throws {
			guard !self.finishingBoundaryAdded else {
				throw EncodingError.invalidValue (self.boundary, EncodingError.Context (codingPath: [], debugDescription: "Cannot add second finishing boundary"));
			}
			self.finishingBoundaryAdded = true;
			self.substreams.append (InputStream (data: "--\(self.boundary)--\r\n".data (using: .utf8)!));
		}
		
		fileprivate struct SuperEncoder: Swift.Encoder {
			fileprivate var userInfo: [CodingUserInfoKey: Any] {
				return self.root.userInfo;
			}
			
			fileprivate let codingPath: CodingPath;
			
			private unowned let root: Encoder;
			
			fileprivate init (_ root: Encoder, codingPath: CodingPath) {
				self.root = root;
				self.codingPath = codingPath;
			}
			
			fileprivate func container <Key> (keyedBy type: Key.Type) -> Swift.KeyedEncodingContainer <Key> where Key: CodingKey {
				return Swift.KeyedEncodingContainer (KeyedEncodingContainer (self.root, codingPath: self.codingPath));
			}
			
			fileprivate func unkeyedContainer () -> Swift.UnkeyedEncodingContainer {
				return UnkeyedEncodingContainer (self.root, codingPath: self.codingPath);
			}
			
			fileprivate func singleValueContainer () -> Swift.SingleValueEncodingContainer {
				return SingleValueEncodingContainer (self.root, codingPath: self.codingPath);
			}
		}
	}
}

private extension KBAPIMultipartFormDataEncoder.Encoder {
	private struct KeyedEncodingContainer <Key>: KeyedEncodingContainerProtocol where Key: CodingKey {
		fileprivate let codingPath: CodingPath;

		private unowned let root: KBAPIMultipartFormDataEncoder.Encoder;

		fileprivate init (_ root: KBAPIMultipartFormDataEncoder.Encoder, codingPath: CodingPath = []) {
			self.root = root;
			self.codingPath = codingPath;
		}
		
		fileprivate mutating func nestedContainer <NestedKey> (keyedBy keyType: NestedKey.Type, forKey key: Key) -> Swift.KeyedEncodingContainer <NestedKey> where NestedKey: CodingKey {
			return Swift.KeyedEncodingContainer (KeyedEncodingContainer <NestedKey> (self.root, codingPath: self.codingPath + key));
		}

		fileprivate mutating func nestedUnkeyedContainer (forKey key: Key) -> Swift.UnkeyedEncodingContainer {
			return UnkeyedEncodingContainer (self.root, codingPath: self.codingPath + key)
		}
		
		fileprivate mutating func superEncoder (forKey key: Key) -> Encoder {
			return SuperEncoder (self.root, codingPath: self.codingPath + key);
		}

		fileprivate mutating func encodeNil (forKey key: Key) throws {}
		
		fileprivate mutating func encode <T> (_ value: T, forKey key: Key) throws where T: Encodable {
			switch (value) {
			case let fileUpload as KBAPIFileUploadProtocol:
				try self.root.appendFileUpload (fileUpload, for: self.codingPath + key);
			case let data as Data:
				try self.root.appendBoringValue (data, for: self.codingPath + key);
			default:
				throw EncodingError.invalidValue (value, EncodingError.Context (codingPath: self.codingPath, debugDescription: "Cannot handle value"));
			}
		}

		fileprivate mutating func encode <T> (_ value: T, forKey key: Key) throws where T: Encodable, T: StringProtocol {
			try self.root.appendBoringValue (String (urlRequestSerialized: value), for: self.codingPath + key);
		}
		
		fileprivate mutating func encode <T> (_ value: T, forKey key: Key) throws where T: Encodable, T: FixedWidthInteger {
			try self.root.appendBoringValue (value, for: self.codingPath + key);
		}
	}
	
	private struct UnkeyedEncodingContainer: Swift.UnkeyedEncodingContainer {
		fileprivate private (set) var count = 0;
		
		fileprivate mutating func encodeNil () {}
		
		fileprivate let codingPath: CodingPath;
		
		private unowned let root: KBAPIMultipartFormDataEncoder.Encoder;
		
		fileprivate init (_ root: KBAPIMultipartFormDataEncoder.Encoder, codingPath: CodingPath = []) {
			self.root = root;
			self.codingPath = codingPath;
		}

		fileprivate mutating func encode <T> (_ value: T) throws where T: Encodable {
			try self.root.appendBoringValue (value, for: self.codingPath);
		}
		
		fileprivate mutating func nestedContainer <NestedKey> (keyedBy keyType: NestedKey.Type) -> Swift.KeyedEncodingContainer <NestedKey> where NestedKey: CodingKey {
			return Swift.KeyedEncodingContainer (KeyedEncodingContainer (self.root, codingPath: self.codingPath));
		}
		
		fileprivate mutating func nestedUnkeyedContainer() -> Swift.UnkeyedEncodingContainer {
			return UnkeyedEncodingContainer (self.root, codingPath: self.codingPath);
		}
		
		fileprivate mutating func superEncoder () -> Encoder {
			return SuperEncoder (self.root, codingPath: self.codingPath);
		}
	}
	
	private struct SingleValueEncodingContainer: Swift.SingleValueEncodingContainer {
		fileprivate let codingPath: CodingPath;
		
		private unowned let root: KBAPIMultipartFormDataEncoder.Encoder;
		
		fileprivate init (_ root: KBAPIMultipartFormDataEncoder.Encoder, codingPath: CodingPath = []) {
			self.root = root;
			self.codingPath = codingPath;
		}

		fileprivate mutating func encodeNil () {}
		
		fileprivate mutating func encode <T> (_ value: T) throws where T: Encodable {
			try self.root.appendBoringValue (value, for: self.codingPath);
		}
	}
}

fileprivate extension String {
	fileprivate var escapedForMultipartEnccoding: String {
		guard let result = self.applyingTransform (.toLatin, reverse: false) else {
			return "file.bin";
		}
		return String (result.map { $0.unicodeScalars.allSatisfy (CharacterSet.urlQueryAllowed.contains) ? $0 : "_" }).replacingOccurrences (of: "\"", with: "\\\"");
	}
}

private let log = KBLoggerWrapper ();
