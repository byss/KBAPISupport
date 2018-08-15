//
//  Result+ValueConformances.swift
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

extension Result where Wrapped: AnyObject {
	public static func === (lhs: Result, rhs: Result) -> Bool {
		guard case .success (let value1) = lhs, case .success (let value2) = rhs, value1 === value2 else {
			return false;
		}
		return true;
	}

	public static func === (lhs: Result, rhs: Wrapped) -> Bool {
		guard case .success (let value) = lhs, value === rhs else {
			return false;
		}
		return true;
	}
	
	public static func === (lhs: Wrapped, rhs: Result) -> Bool {
		guard case .success (let value) = rhs, value === lhs else {
			return false;
		}
		return true;
	}
}

extension Result: Equatable where Wrapped: Equatable {
	public static func == (lhs: Result, rhs: Result) -> Bool {
		switch (lhs, rhs) {
		case (.success (let value1), .success (let value2)):
			return value1 == value2;
		case (.failure (let error1 as NSError), .failure (let error2 as NSError)):
			return error1 == error2;
		default:
			return false;
		}
	}

	public static func == (lhs: Result, rhs: Wrapped) -> Bool {
		guard case .success (let value) = lhs, value == rhs else {
			return false;
		}
		return true;
	}
	
	public static func == (lhs: Wrapped, rhs: Result) -> Bool {
		guard case .success (let value) = rhs, value == lhs else {
			return false;
		}
		return true;
	}
}

extension Result: Hashable where Wrapped: Hashable {
	public func hash (into hasher: inout Hasher) {
		switch (self) {
		case .success (let value):
			value.hash (into: &hasher);
		case .failure (var error):
			withUnsafeBytes (of: &error) { hasher.combine (bytes: $0) };
		}
	}
}

extension Result: Comparable where Wrapped: Comparable {
	public static func < (lhs: Result, rhs: Result) -> Bool {
		guard case .success (let value1) = lhs, case .success (let value2) = rhs, value1 < value2 else {
			return false;
		}
		return true;
	}
}

extension Result where Wrapped: Comparable {
	public static func < (lhs: Result, rhs: Wrapped) -> Bool {
		guard case .success (let value) = lhs, value < rhs else {
			return false;
		}
		return true;
	}

	public static func < (lhs: Wrapped, rhs: Result) -> Bool {
		guard case .success (let value) = rhs, lhs < value else {
			return false;
		}
		return true;
	}

	public static func <= (lhs: Result, rhs: Wrapped) -> Bool {
		guard case .success (let value) = lhs, value <= rhs else {
			return false;
		}
		return true;
	}
	
	public static func <= (lhs: Wrapped, rhs: Result) -> Bool {
		guard case .success (let value) = rhs, lhs <= value else {
			return false;
		}
		return true;
	}

	public static func > (lhs: Result, rhs: Wrapped) -> Bool {
		guard case .success (let value) = lhs, value > rhs else {
			return false;
		}
		return true;
	}
	
	public static func > (lhs: Wrapped, rhs: Result) -> Bool {
		guard case .success (let value) = rhs, lhs > value else {
			return false;
		}
		return true;
	}

	public static func >= (lhs: Result, rhs: Wrapped) -> Bool {
		guard case .success (let value) = lhs, value >= rhs else {
			return false;
		}
		return true;
	}
	
	public static func >= (lhs: Wrapped, rhs: Result) -> Bool {
		guard case .success (let value) = rhs, lhs >= value else {
			return false;
		}
		return true;
	}
}

extension Result: CustomStringConvertible where Wrapped: CustomStringConvertible {
	public var description: String {
		return self.map ({ $0.description }, error: { $0.localizedDescription });
	}
}

extension Result: CustomDebugStringConvertible where Wrapped: CustomDebugStringConvertible {
	public var debugDescription: String {
		return self.map ({ $0.debugDescription }, error: { "\($0)" });
	}
}

extension Result: LosslessStringConvertible where Wrapped: LosslessStringConvertible {
	public init? (_ description: String) {
		guard let value = Wrapped (description) else {
			return nil;
		}
		self.init (value);
	}
}

extension Result: CaseIterable where Wrapped: CaseIterable {
	public struct AllCases: Collection {
		public enum Index: Comparable {
			public static func < (lhs: Index, rhs: Index) -> Bool {
				switch (lhs, rhs) {
				case (.error, .error), (.value, .error):
					return false;
				case (.error, .value):
					return true;
				case (.value (let index1), .value (let index2)):
					return index1 < index2;
				}
			}
			
			case error;
			case value (underlying: Wrapped.AllCases.Index);
		}
		
		private struct Error: Swift.Error {}
		
		public typealias Element = Result;
		
		public var startIndex: Index {
			return .error;
		}
		
		public var endIndex: Index {
			return .value (underlying: Wrapped.allCases.endIndex);
		}

		public subscript (position: Index) -> Result {
			switch (position) {
			case .error:
				return .failure (Error ());
			case .value (let index):
				return .success (Wrapped.allCases [index]);
			}
		}
		
		public func index (after i: Index) -> Index {
			switch (i) {
			case .error:
				return .value (underlying: Wrapped.allCases.startIndex);
			case .value (let index):
				return .value (underlying: Wrapped.allCases.index (after: index));
			}
		}
	}
	
	public static var allCases: AllCases {
		return AllCases ();
	}
}

extension Result: RawRepresentable where Wrapped: RawRepresentable {
	public typealias RawValue = Wrapped.RawValue?;

	public var rawValue: RawValue {
		return self.value?.rawValue;
	}
	
	public init? (rawValue: RawValue) {
		guard let rawValue = rawValue, let value = Wrapped (rawValue: rawValue) else {
			return nil;
		}
		self = .success (value);
	}
}

extension Result: Decodable where Wrapped: Decodable {
	private struct ImpossibleError: LocalizedError {
		fileprivate var errorDescription: String? {
			return "This error must not be happening";
		}
	}
	
	public init (from decoder: Decoder) throws {
		let container = try decoder.container (keyedBy: CodingKeys.self);
		
		switch (container.allKeys) {
		case [.success]:
			self.init (try container.decode (Wrapped.self, forKey: .success));
		case [.failureDescription]:
			self.init (try container.decode (ErrorDescription.self, forKey: .failureDescription));
		case let invalidKeys:
			log.fault ("Cannot decode \(Result.self) from \(invalidKeys)");
			self.init (ImpossibleError ());
		}
	}
}

extension Result: Encodable where Wrapped: Encodable {
	public func encode (to encoder: Encoder) throws {
		var container = encoder.container (keyedBy: CodingKeys.self);
		
		switch (self) {
		case .success (let value):
			try container.encode (value, forKey: .success);
		case .failure (let error):
			try container.encode (ErrorDescription (error.localizedDescription), forKey: .failureDescription);
		}
	}
}

extension Result: ExpressibleByNilLiteral where Wrapped: ExpressibleByNilLiteral {
	public init (nilLiteral: ()) {
		self.init (nil);
	}
}

extension Result: ExpressibleByBooleanLiteral where Wrapped: ExpressibleByBooleanLiteral {
	public typealias BooleanLiteralType = Wrapped.BooleanLiteralType;

	public init (booleanLiteral value: Wrapped.BooleanLiteralType) {
		self.init (Wrapped (booleanLiteral: value));
	}
}

extension Result: ExpressibleByIntegerLiteral where Wrapped: ExpressibleByIntegerLiteral {
	public typealias IntegerLiteralType = Wrapped.IntegerLiteralType;

	public init (integerLiteral value: Wrapped.IntegerLiteralType) {
		self.init (Wrapped (integerLiteral: value));
	}
}

extension Result: ExpressibleByFloatLiteral where Wrapped: ExpressibleByFloatLiteral {
	public typealias FloatLiteralType = Wrapped.FloatLiteralType;

	public init (floatLiteral value: Wrapped.FloatLiteralType) {
		self.init (Wrapped (floatLiteral: value));
	}
}

extension Result: ExpressibleByUnicodeScalarLiteral where Wrapped: ExpressibleByUnicodeScalarLiteral {
	public typealias UnicodeScalarLiteralType = Wrapped.UnicodeScalarLiteralType;

	public init (unicodeScalarLiteral value: Wrapped.UnicodeScalarLiteralType) {
		self.init (Wrapped (unicodeScalarLiteral: value));
	}
}

extension Result: ExpressibleByExtendedGraphemeClusterLiteral where Wrapped: ExpressibleByExtendedGraphemeClusterLiteral {
	public typealias ExtendedGraphemeClusterLiteralType = Wrapped.ExtendedGraphemeClusterLiteralType;
	
	public init (extendedGraphemeClusterLiteral value: Wrapped.ExtendedGraphemeClusterLiteralType) {
		self.init (Wrapped (extendedGraphemeClusterLiteral: value));
	}
}

extension Result: ExpressibleByStringLiteral where Wrapped: ExpressibleByStringLiteral {
	public typealias StringLiteralType = Wrapped.StringLiteralType;

	public init (stringLiteral value: Wrapped.StringLiteralType) {
		self.init (Wrapped (stringLiteral: value));
	}
}

extension Result: ExpressibleByArrayLiteral where Wrapped: ExpressibleByArrayLiteral {
	public typealias ArrayLiteralElement = Wrapped.ArrayLiteralElement;
	
	public init (arrayLiteral elements: ArrayLiteralElement...) {
		let wrappedInitializer = unsafeBitCast (Wrapped.init, to: (([ArrayLiteralElement]) -> Wrapped).self);
		self.init (wrappedInitializer (elements));
	}
}

extension Result: ExpressibleByDictionaryLiteral where Wrapped: ExpressibleByDictionaryLiteral {
	public typealias Key = Wrapped.Key;
	public typealias Value = Wrapped.Value;
	
	public init (dictionaryLiteral elements: (Key, Value)...) {
		let wrappedInitializer = unsafeBitCast (Wrapped.init, to: (([(Key, Value)]) -> Wrapped).self);
		self.init (wrappedInitializer (elements));
	}
}

extension Result: IteratorProtocol where Wrapped: IteratorProtocol {
	public typealias Element = Wrapped.Element;
	
	public mutating func next () -> Wrapped.Element? {
		guard case .success (var wrapped) = self else {
			return nil;
		}

		let next = wrapped.next ();
		self = .success (wrapped);
		return next;
	}
}

extension Result: RangeExpression where Wrapped: RangeExpression {
	public typealias Bound = Wrapped.Bound;
	
	public func relative <C> (to collection: C) -> Range <Bound> where C: Collection, C.Index == Bound {
		return self.map ({ $0.relative (to: collection) }, error: collection.startIndex ..< collection.startIndex);
	}

	public func contains (_ element: Wrapped.Bound) -> Bool {
		return self.map ({ $0.contains (element) }, error: false);
	}
}

extension Result: Strideable where Wrapped: Strideable {
	public typealias Stride = Wrapped.Stride;
	
	public func distance (to other: Result) -> Stride {
		switch (self, other) {
		case (.success (let value1), .success (let value2)):
			return value1.distance (to: value2);
		default:
			return 0;
		}
	}
	
	public func advanced (by n: Stride) -> Result {
		return self.map { $0.advanced (by: n) };
	}
}

extension Result: Sequence where Wrapped: Sequence {
	public typealias Iterator = Result <Wrapped.Iterator>;
	public typealias SubSequence = Result <Wrapped.SubSequence>;

	public func makeIterator () -> Iterator {
		return self.map { $0.makeIterator () };
	}

	public func dropFirst (_ n: Int) -> SubSequence {
		return self.map { $0.dropFirst () };
	}
	
	public func dropLast (_ n: Int) -> SubSequence {
		return self.map { $0.dropLast () };
	}

	public func drop (while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
		return try self.map { try $0.drop (while: predicate) };
	}

	public func prefix (_ maxLength: Int) -> SubSequence {
		return self.map { $0.prefix (maxLength) };
	}
	
	public func prefix (while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
		return try self.map { try $0.prefix (while: predicate) };
	}

	public func suffix (_ maxLength: Int) -> SubSequence {
		return self.map { $0.suffix (maxLength) };
	}
	
	public func split (maxSplits: Int, omittingEmptySubsequences: Bool, whereSeparator isSeparator: (Element) throws -> Bool) rethrows -> [SubSequence] {
		switch (self) {
		case .success (let wrapped):
			return try wrapped.split (maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences, whereSeparator: isSeparator).map (SubSequence.init);
		case .failure:
			return [];
		}
	}
}

extension Result: Collection where Wrapped: Collection {
	public typealias Index = Result <Wrapped.Index>;
	
	public var startIndex: Index {
		return self.map { $0.startIndex };
	}
	
	public var endIndex: Index {
		return self.map { $0.endIndex };
	}
	
	private func unwrapIndex (_ index: Index) -> (Wrapped, Wrapped.Index)? {
		guard let collection = self.value, let indexValue = index.value else {
			log.fault ("Cannot subscript \(self) with \(index)");
			return nil;
		}
		return (collection, indexValue);
	}
	
	public subscript (position: Index) -> Element {
		return self.unwrapIndex (position).map { $0 [$1] } ?? zeroedValue ();
	}
	
	public func index (after index: Index) -> Index {
		return index.map { indexValue in self.map { $0.index (after: indexValue) } };
	}
}

extension Result: BidirectionalCollection where Wrapped: BidirectionalCollection {
	public func index (before index: Index) -> Index {
		return index.map { indexValue in self.map { $0.index (before: indexValue) } };
	}
}

extension Result: RandomAccessCollection where Wrapped: RandomAccessCollection {}

extension Result: MutableCollection where Wrapped: MutableCollection {
	public subscript (position: Index) -> Element {
		get { return self.unwrapIndex (position).map { $0 [$1] } ?? zeroedValue () }
		set {
			guard case .success (var collection) = self, case .success (let index) = position else {
				return;
			}
			collection [index] = newValue;
			self = .success (collection);
		}
	}
}

extension Result: RangeReplaceableCollection where Wrapped: RangeReplaceableCollection {
	public init () {
		self.init (Wrapped ());
	}
}

extension Result: SetAlgebra where Wrapped: SetAlgebra {
	private static func performOperation (_ operation: (Wrapped) -> (Wrapped) -> Wrapped, with lhs: Result, _ rhs: Result) -> Result {
		switch (lhs, rhs) {
		case (.success (let value1), .success (let value2)):
			return .success (operation (value1) (value2));
		case (_, .failure):
			return lhs;
		case (.failure, _):
			return rhs;
		}
	}
	
	private static func performMutatingOperation (_ operation: (Wrapped) -> (Wrapped) -> Wrapped, with lhs: inout Result, _ rhs: Result) {
		lhs = self.performOperation (operation, with: lhs, rhs);
	}
	
	public init () {
		self.init (Wrapped ());
	}
	
	public func contains (_ member: Element) -> Bool {
		return self.map ({ $0.contains (member) }, error: false);
	}
	
	public mutating func insert (_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
		return self.withMutableValue (perform: { $0.insert (newMember) }, error: (inserted: false, memberAfterInsert: newMember));
	}
	
	public mutating func update (with newMember: Element) -> Element? {
		return self.withMutableValue (perform: { $0.update (with: newMember) }, error: nil);
	}

	public mutating func remove (_ member: Element) -> Element? {
		return self.withMutableValue (perform: { $0.remove (member) }, error: nil);
	}
	
	public func union (_ other: Result) -> Result {
		return .performOperation (Wrapped.union, with: self, other);
	}
	
	public func intersection (_ other: Result) -> Result {
		return .performOperation (Wrapped.intersection, with: self, other);
	}
	
	public func symmetricDifference (_ other: Result) -> Result {
		return .performOperation (Wrapped.symmetricDifference, with: self, other);
	}
	
	public mutating func formUnion (_ other: Result) {
		return Result.performMutatingOperation (Wrapped.union, with: &self, other);
	}
	
	public mutating func formIntersection (_ other: Result) {
		return Result.performMutatingOperation (Wrapped.intersection, with: &self, other);
	}
	
	public mutating func formSymmetricDifference (_ other: Result) {
		return Result.performMutatingOperation (Wrapped.symmetricDifference, with: &self, other);
	}
}

fileprivate extension Result {
	fileprivate enum CodingKeys: String, CodingKey {
		case success;
		case failureDescription;
	}

	fileprivate struct ErrorDescription: LocalizedError, Codable {
		private let value: String;
		
		fileprivate var errorDescription: String? {
			return self.value;
		}
		
		fileprivate init (_ value: String) {
			self.value = value;
		}
	}
}

private func zeroedValue <T> () -> T {
	return calloc (1, MemoryLayout <T>.stride)!.assumingMemoryBound (to: T.self).pointee;
}

private let log = KBLoggerWrapper ();
