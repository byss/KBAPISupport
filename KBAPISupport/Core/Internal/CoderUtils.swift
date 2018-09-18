//
//  CoderUtils.swift
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

internal typealias CodingPath = [CodingKey];

internal extension KeyedEncodingContainerProtocol {
	internal mutating func superEncoder () -> Encoder {
		return self.superEncoder (forKey: .super);
	}
}

internal extension Array where Element == CodingKey {
	internal static func += (lhs: inout Array, rhs: CodingKey) {
		lhs.append (rhs);
	}

	internal static func += <Key> (lhs: inout Array, rhs: Key) where Key: CodingKey {
		lhs.append (rhs);
	}
	
	internal static func += <Path> (lhs: inout Array, rhs: Path) where Path: Sequence, Path.Element: CodingKey {
		lhs.reserveCapacity (lhs.count + rhs.underestimatedCount);
		for element in rhs {
			lhs += element;
		}
	}

	internal static func + (lhs: Array, rhs: CodingKey) -> Array {
		var lhs = lhs;
		lhs += rhs;
		return lhs;
	}
	
	internal static func + <Key> (lhs: Array, rhs: Key) -> Array where Key: CodingKey {
		var lhs = lhs;
		lhs += rhs;
		return lhs;
	}
	
	internal static func + <Path> (lhs: Array, rhs: Path) -> Array where Path: Sequence, Path.Element: CodingKey {
		var lhs = lhs;
		lhs += rhs;
		return lhs;
	}	

	internal var urlencodedParameterName: String {
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

internal extension String {
	internal init <T> (urlRequestSerialized value: T) where T: Encodable {
		print (value);
		switch (value) {
		case let boolValue as Bool:
			self = (boolValue ? "1" : "0");
		case let string as String:
			self = string;
		case let convertible as CustomStringConvertible:
			self = convertible.description;
		default:
			self.init (reflecting: value);
		}
	}

	internal init <T> (urlRequestSerialized value: T) where T: Encodable, T: StringProtocol {
		self.init (value);
	}

	internal init <T> (urlRequestSerialized value: T) where T: Encodable, T: FixedWidthInteger {
		self.init (value);
	}
}

internal struct ContainerIndexKey: CodingKey {
	internal var intValue: Int? {
		return self.value;
	}
	
	internal var stringValue: String {
		return "\(self.value)";
	}
	
	private let value: Int;
	
	internal init (intValue: Int) {
		self.value = intValue;
	}
	
	internal init? (stringValue: String) {
		guard let value = Int (stringValue) else {
			return nil;
		}
		self.value = value;
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

private let log = KBLoggerWrapper ();
