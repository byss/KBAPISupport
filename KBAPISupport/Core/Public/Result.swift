//
//  Result.swift
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

import Swift

/// A type that can store either some value or the fact that is is missing and optionally provide justification for it.
public protocol ResultProtocol {
	/// Primary data type that is expected to be inside the container.
	associatedtype Wrapped;
	
	/// Boolean flag indicating whether an actual value is being stored.
	var isSuccess: Bool { get }
	/// Boolean flag indicating that this storage is empty.
	var isFailure: Bool { get }

	/// Returns stored value if any, or `nil`.
	var value: Wrapped? { get };
	/// `Error` object containing arbitrary information about value absence.
	///
	/// Must always be `nil` when storage represents any "real" data, e.g. empty string for Wrapped = String,
	/// UIColor.clear for Wrapped = UIColor and so on.
	var error: Error? { get };
	
	/// Creates an instance that stores the given value.
	init (_ value: Wrapped);
	/// Creates an empty instance that contains `error` value relevant to the actual stored data expectations.
	init (_ error: Error);
}

/// A type that can be initialized with or convereted to another Result-like types.
public protocol ResultProtocolExtra: ResultProtocol {
	/// Creates a new instance equivalent to the given value.
	init <R> (_ other: R) where R: ResultProtocol, R.Wrapped == Wrapped;
	/// Creates a new instance equivalent to the given value.
	init <R> (_ other: R) where R: ResultProtocolExtra, R.Wrapped == Wrapped;

	/// Convert information stored in this value into another compatible representation.
	func converted <R> () -> R where R: ResultProtocol, R.Wrapped == Wrapped;
	/// Convert information stored in this value into another explicitly specified representation.
	func converted <R> (to anotherResultType: R.Type) -> R where R: ResultProtocol, R.Wrapped == Wrapped;

	/// Optional-like value mapping; calculations are only performed on `Wrapped` values.
	func map <T> (_ block: (Wrapped) throws -> Result <T>) rethrows -> Result <T>;
	/// Optional-like value mapping; calculations are only performed on `Wrapped` values.
	func map <T> (_ block: (Wrapped) throws -> T) rethrows -> Result <T>;
	/// Optional-like value mapping, falling back to supplied `errorValue`.
	func map <T> (_ block: (Wrapped) throws -> T, error errorValue: @autoclosure () -> T) rethrows -> T;
	/// Generic state mapping; either `valueBlock` with `Wrapped` or `errorBlock` with `Error` argument is called, depending on container state.
	func map <T> (_ valueBlock: (Wrapped) throws -> T, error errorBlock: (Error) throws -> T) rethrows -> T;
	
	/// Performs generic state mapping in place.
	mutating func withMutableValue <T> (perform block: (inout Wrapped) throws -> T, error errorValue: T) rethrows -> T;
}

public extension ResultProtocol {
	public var isSuccess: Bool {
		return self.value != nil;
	}
	
	public var isFailure: Bool {
		return self.error != nil;
	}
}

private struct ResultConversionError: Error {}

public extension ResultProtocolExtra {
	public init <R> (_ other: R) where R: ResultProtocol, R.Wrapped == Wrapped {
		if let value = other.value {
			self.init (value);
		} else {
			self.init (other.error ?? ResultConversionError ());
		}
	}
	
	public init <R> (_ other: R) where R: ResultProtocolExtra, R.Wrapped == Wrapped {
		self = other.map (Self.init, error:Self.init);
	}
	
	public func converted <R> () -> R where R: ResultProtocol, R.Wrapped == Wrapped {
		return self.map (R.init, error: R.init);
	}

	public func converted <R> (to anotherResultType: R.Type = R.self) -> R where R: ResultProtocol, R.Wrapped == Wrapped {
		return self.map (anotherResultType.init, error: anotherResultType.init);
	}

	public func map <T> (_ block: (Wrapped) throws -> Result <T>) rethrows -> Result <T> {
		return try self.map ({ try block ($0) }, error: { .failure ($0) });
	}
	
	public func map <T> (_ block: (Wrapped) throws -> T) rethrows -> Result <T> {
		return try self.map ({ .success (try block ($0)) }, error: { .failure ($0) });
	}
	
	public func map <T> (_ block: (Wrapped) throws -> T, error errorValue: @autoclosure () -> T) rethrows -> T {
		return try self.map ({ try block ($0) }, error: errorValue);
	}
}

/// A type that represents either a wrapped value or its absence and reason for that.
public enum Result <Wrapped> {
	/// The presence of a value, stored as Wrapped.
	case success (Wrapped);
	/// The absence of a value. Error instance may contain additional details.
	case failure (Error);
}

extension Result: ResultProtocol {
	public var isSuccess: Bool {
		guard case .success = self else {
			return false;
		}
		return true;
	}
	
	public var isFailure: Bool {
		guard case .failure = self else {
			return false;
		}
		return true;
	}
	
	public var value: Wrapped? {
		guard case .success (let value) = self else {
			return nil;
		}
		return value;
	}
	
	public var error: Error? {
		guard case .failure (let error) = self else {
			return nil;
		}
		return error;
	}
	
	public init (_ value: Wrapped) {
		self = .success (value);
	}
	
	public init (_ error: Error) {
		self = .failure (error);
	}
}

extension Result: ResultProtocolExtra {
	public func map <T> (_ valueBlock: (Wrapped) throws -> T, error errorBlock: (Error) throws -> T) rethrows -> T {
		switch (self) {
		case .success (let wrapped):
			return try valueBlock (wrapped);
		case .failure (let error):
			return try errorBlock (error);
		}
	}

	public mutating func withMutableValue <T> (perform block: (inout Wrapped) throws -> T, error errorValue: T) rethrows -> T {
		guard case .success (var value) = self else {
			return errorValue;
		}
		let result = try block (&value);
		self = .success (value);
		return result;
	}
}
