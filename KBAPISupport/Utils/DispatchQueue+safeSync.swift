//
//  DispatchQueue+safeSync.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/19/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

import Dispatch

public extension DispatchQueue {
	public func safeSync (execute work: () -> ()) {
		__dispatch_sync_safe (self, work);
	}

	public func safeSync <T> (execute work: () -> T) -> T {
		var result: T?;
		__dispatch_sync_safe (self) {
			result = work ();
		};
		return result!;
	}
	
	public func safeSync <T> (execute work: () throws -> T) throws -> T {
		var result: Result <T>?;
		__dispatch_sync_safe (self) {
			do {
				result = .success (try work ());
			} catch {
				result = .failure (error);
			}
		};
		switch (result!) {
		case .success (let result):
			return result;
		case .failure (let error):
			throw error;
		}
	}
}
