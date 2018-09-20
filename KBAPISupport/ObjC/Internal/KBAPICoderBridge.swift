//
//  KBAPICoderBridge.swift
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

public extension KBAPICoder where Self: __KBAPICoder {
	public var userInfo: [CodingUserInfoKey : Any] {
		get {
			let rawUserInfo = self.__userInfo;
			var result = [CodingUserInfoKey: Any] (minimumCapacity: rawUserInfo.count);
			for (key, value) in rawUserInfo {
				guard let key = CodingUserInfoKey (rawValue: key) else {
					continue;
				}
				result [key] = value;
			}
			return result;
		}
		set {
			var rawUserInfo = [String: Any] (minimumCapacity: newValue.count);
			for (key, value) in newValue {
				rawUserInfo [key.rawValue] = value;
			}
			self.__userInfo = rawUserInfo;
		}
	}
}
