//
//  DispatchQueue+safeSync.swift
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
