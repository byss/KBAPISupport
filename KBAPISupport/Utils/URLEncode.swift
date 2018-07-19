//
//  URLEncode.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/19/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
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

public func urlencoded <S> (_ string: S) -> String where S: StringProtocol, S.Index == String.Index {
	return string.addingPercentEncoding (withAllowedCharacters: allowedCharset) ?? String (string);
}

public func urlencoded (_ string: String) -> String {
	return string.addingPercentEncoding (withAllowedCharacters: allowedCharset) ?? string;
}
