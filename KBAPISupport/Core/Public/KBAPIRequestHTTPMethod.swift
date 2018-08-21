//
//  KBAPIRequestHTTPMethod.swift
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

public struct KBAPIRequestHTTPMethod {
	public let rawValue: String;
	
	private init? (_ value: String) {
		guard !value.isEmpty else {
			return nil;
		}
		self.rawValue = value;
	}
}

public extension KBAPIRequestHTTPMethod {
	private typealias SelfType = KBAPIRequestHTTPMethod;
	private typealias ObjCType = __KBAPIRequestHTTPMethod;
	
	public static let head = KBAPIRequestHTTPMethod (.HEAD);
	public static let get = KBAPIRequestHTTPMethod (.GET);
	public static let post = KBAPIRequestHTTPMethod (.POST);
	public static let put = KBAPIRequestHTTPMethod (.PUT);
	public static let patch = KBAPIRequestHTTPMethod (.PATCH);
	public static let delete = KBAPIRequestHTTPMethod (.DELETE);

	private static let `default` = SelfType.get;

	private init (_ objcValue: ObjCType) {
		self.rawValue = objcValue.rawValue;
	}
}

extension KBAPIRequestHTTPMethod: Equatable {
	public static func == (lhs: KBAPIRequestHTTPMethod, rhs: KBAPIRequestHTTPMethod) -> Bool {
		return lhs.rawValue == rhs.rawValue;
	}

	public static func == (lhs: KBAPIRequestHTTPMethod, rhs: String) -> Bool {
		return lhs.rawValue == rhs;
	}

	public static func == (lhs: String, rhs: KBAPIRequestHTTPMethod) -> Bool {
		return lhs == rhs.rawValue;
	}
}

extension KBAPIRequestHTTPMethod: Hashable {
	public func hash (into hasher: inout Hasher) {
		self.rawValue.hash (into: &hasher);
	}
}

extension KBAPIRequestHTTPMethod: ExpressibleByStringLiteral {
	public typealias StringLiteralType = String;
	
	public init (stringLiteral: String) {
		self = SelfType (stringLiteral) ?? .default;
	}
}

extension KBAPIRequestHTTPMethod: RawRepresentable {
	public typealias RawValue = String;

	public init (rawValue value: String) {
		self = SelfType (value) ?? .default;
	}
}

extension KBAPIRequestHTTPMethod: CustomStringConvertible {
	public var description: String {
		return self.rawValue;
	}
}
