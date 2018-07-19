//
//  Result.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/19/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

import Swift

public enum Result <Value> {
	case success (Value);
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
	
	public var value: Value? {
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
}
