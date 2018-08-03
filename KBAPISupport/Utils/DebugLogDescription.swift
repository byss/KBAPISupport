//
//  DebugLogDescription.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/31/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

import Foundation

internal extension Array where Element == URLQueryItem {
	internal var debugLogDescription: String {
		return "[" + self.map { "\($0.name) = \($0.value ?? "<nil>")" }.joined (separator: ", ") + "]";
	}
}

internal extension Data {
	internal var debugLogDescription: String {
		if let stringDescription = String (decodingUTF8: self, maximumLength: .maximumDataDebugLogDescriptionLength) {
			return stringDescription;
		}
		let descriptionHead = "\(self.count) bytes: <", descriptionTailFull = ">", descriptionTailTruncated = "…";
		let describedLength: Int, descriptionTail: String;
		if (self.count * 2 + descriptionHead.count + descriptionTailFull.count < .maximumDataDebugLogDescriptionLength) {
			describedLength = self.count;
			descriptionTail = descriptionTailFull;
		} else {
			describedLength = (.maximumDataDebugLogDescriptionLength - descriptionHead.count - descriptionTailTruncated.count) / 2;
			descriptionTail = descriptionTailTruncated;
		}
		
		var describedDataBytes = [UInt16] ();
		describedDataBytes.reserveCapacity (describedLength * 2);
		for byte in self.subdata (in: 0 ..< describedLength) {
			describedDataBytes.append (hexdigit ((byte & 0xF0) >> 4));
			describedDataBytes.append (hexdigit (byte & 0x0F));
		}
		
		return describedDataBytes.withUnsafeBufferPointer { descriptionHead + String (utf16CodeUnits: $0.baseAddress!, count: $0.count) + descriptionTail };
	}
}

fileprivate extension String {
	fileprivate init? (decodingUTF8 data: Data, maximumLength: Int) {
		var scalarView = UnicodeScalarView ();
		scalarView.reserveCapacity (maximumLength);
		
		var codec = Unicode.UTF8 (), inputIterator = data.makeIterator ();
		loop: while (true) {
			switch (codec.decode (&inputIterator)) {
			case .scalarValue (let scalar):
				if (scalarView.count + 1 < maximumLength) {
					scalarView.append (scalar);
				} else {
					scalarView.append ("…");
					break loop;
				}
			
			case .emptyInput:
				break loop;
			
			case .error:
				return nil;
			}
		}

		self.init (scalarView);
	}
}

private struct UnsafePointerCollection <Element>: RandomAccessCollection {
	fileprivate let startIndex: UnsafePointer <Element>;
	fileprivate let endIndex: UnsafePointer <Element>;
	
	fileprivate subscript (index: UnsafePointer <Element>) -> Element {
		return index.pointee;
	}
}

fileprivate extension Int {
	fileprivate static let maximumDataDebugLogDescriptionLength = 1024;
}

fileprivate extension UInt8 {
	fileprivate static let asciiZeroCode = "0".utf8.first!;
	fileprivate static let asciiACode = "A".utf8.first!;
}

private func hexdigit (_ x: UInt8) -> UInt16 {
	switch (x) {
	case 0 ..< 10:
		return numericCast (x + .asciiZeroCode);
	case 0xA ..< 0x10:
		return numericCast (x + .asciiACode);
	default:
		return 0;
	}
}
