//
//  URLEncode.swift
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

import Foundation

private func sequence (from: Unicode.Scalar, through: Unicode.Scalar) -> [Unicode.Scalar] {
	return stride (from: from.value, through: through.value, by: 1).compactMap { Unicode.Scalar ($0) };
}

private let allowedCharset = CharacterSet (
	sequence (from: "0", through: "9") +
	sequence (from: "A", through: "Z") +
	sequence (from: "a", through: "z") +
	["-", ".", "_"]
);

internal func urlencoded <S> (_ string: S) -> String where S: StringProtocol, S.Index == String.Index {
	return string.addingPercentEncoding (withAllowedCharacters: allowedCharset) ?? String (string);
}

internal func urlencoded (_ string: String) -> String {
	return string.addingPercentEncoding (withAllowedCharacters: allowedCharset) ?? string;
}
