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

public enum Result <Wrapped> {
	case success (Wrapped);
	case failure (Error);
}

public extension Result {
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
	
	public func map <T> (_ block: (Wrapped) throws -> Result <T>) rethrows -> Result <T> {
		return try self.map ({ try block ($0) }, error: { .failure ($0) });
	}
	
	public func map <T> (_ block: (Wrapped) throws -> T) rethrows -> Result <T> {
		return try self.map ({ .success (try block ($0)) }, error: { .failure ($0) });
	}
	
	public func map <T> (_ block: (Wrapped) throws -> T, error errorValue: @autoclosure () -> T) rethrows -> T {
		return try self.map ({ try block ($0) }, error: errorValue);
	}
	
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
