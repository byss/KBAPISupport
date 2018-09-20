//
//  UTIdentifier.swift
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

#if os (iOS) || os (tvOS) || os (watchOS)
import MobileCoreServices
#elseif os (macOS)
import CoreServices
#else
	#error ("Unsupported platform")
#endif

internal struct UTIdentifier {
	private let rawValue: CFString;
}

internal extension UTIdentifier {
	internal static let data = UTIdentifier (rawValue: kUTTypeData);
	
	private static let isDeclared = UTTypeIsDeclared;
	private static let isDynamic = UTTypeIsDynamic;
	
	internal var value: String {
		return self.rawValue as String;
	}
	
	internal var isDeclared: Bool {
		return UTIdentifier.isDeclared (self.rawValue);
	}
	
	internal var isDynamic: Bool {
		return UTIdentifier.isDynamic (self.rawValue);
	}
	
	internal var declaration: [String: Any]? {
		guard let rawDeclaration = UTTypeCopyDeclaration (self.rawValue) else {
			return nil;
		}
		return rawDeclaration.takeUnretainedValue () as NSDictionary as? [String: Any];
	}
	
	internal var bundleURL: URL? {
		return UTTypeCopyDeclaringBundleURL (self.rawValue)?.takeUnretainedValue () as URL?;
	}
	
	internal static func preferred (forTag tag: Tag, withValue tagValue: String, conformingTo otherIdentifier: UTIdentifier?) -> UTIdentifier? {
		return (UTTypeCreatePreferredIdentifierForTag (tag.rawValue, tagValue as CFString, otherIdentifier?.rawValue)?.takeUnretainedValue ()).map (UTIdentifier.init);
	}
	
	internal static func allIdentifiers (forTag tag: Tag, withValue tagValue: String, conformingTo otherIdentifier: UTIdentifier?) -> [UTIdentifier]? {
		guard let rawIdentifiers = UTTypeCreateAllIdentifiersForTag (tag.rawValue, tagValue as CFString, otherIdentifier?.rawValue) else {
			return nil;
		}
		return CFArrayWrapper (rawIdentifiers.takeUnretainedValue ()).map (UTIdentifier.init);
	}
	
	internal static func isDeclared (_ identifierValue: String) -> Bool {
		return self.isDeclared (identifierValue as CFString);
	}

	internal static func isDynamic (_ identifierValue: String) -> Bool {
		return self.isDynamic (identifierValue as CFString);
	}
	
	internal init? (string: String) {
		guard !string.isEmpty else {
			return nil;
		}
		self.init (rawValue: string as CFString);
	}

	internal func conforms (to identifier: UTIdentifier) -> Bool {
		return UTTypeConformsTo (self.rawValue, identifier.rawValue);
	}
	
	internal func preferredValue (ofTag tag: Tag) -> String? {
		return UTTypeCopyPreferredTagWithClass (self.rawValue, tag.rawValue)?.takeUnretainedValue () as String?;
	}
	
	internal func allValues (ofTag tag: Tag) -> [String]? {
		return (UTTypeCopyAllTagsWithClass (self.rawValue, tag.rawValue)?.takeUnretainedValue ()).map (CFArrayWrapper <CFString>.init)?.map { $0 as String };
	}
}

internal extension UTIdentifier {
	internal enum Tag {
		case mimeType;
		case filenameExtension;
		
		fileprivate var rawValue: CFString {
			switch (self) {
			case .mimeType:
				return kUTTagClassMIMEType;
			case .filenameExtension:
				return kUTTagClassFilenameExtension;
			}
		}
	}
}

extension UTIdentifier: Equatable {
	internal static func == (lhs: UTIdentifier, rhs: UTIdentifier) -> Bool {
		return UTTypeEqual (lhs.rawValue, rhs.rawValue);
	}
}

extension UTIdentifier: CustomStringConvertible {
	internal var description: String {
		return (UTTypeCopyDescription (self.rawValue)?.takeUnretainedValue () ?? self.rawValue) as String;
	}
}

private struct CFArrayWrapper <Element> {
	private let wrapped: CFArray;

	fileprivate init (_ array: CFArray) {
		self.wrapped = array;
	}
}

extension CFArrayWrapper: RandomAccessCollection {
	fileprivate var startIndex: CFIndex {
		return 0;
	}
	
	fileprivate var endIndex: CFIndex {
		return CFArrayGetCount (self.wrapped);
	}
	
	fileprivate subscript (index: CFIndex) -> Element {
		return CFArrayGetValueAtIndex (self.wrapped, index)!.assumingMemoryBound (to: Element.self).pointee;
	}
}
