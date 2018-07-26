//
//  DispatchQueue+safeSync.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/19/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

import Dispatch

public extension DispatchQueue {
	public func safeSync <T> (execute work: () throws -> T) rethrows -> T {
		func rethrower (_ error: Error) throws {
			throw error;
		}
		
		var result: T?;
		var error: Error?;
		__dispatch_sync_safe (self) {
			do {
				result = try work ();
			} catch let err {
				error = err;
			}
		};
		if let error = error {
			try rethrower (error);
		}		
		return result!;
	}
}
