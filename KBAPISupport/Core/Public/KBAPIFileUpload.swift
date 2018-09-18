//
//  KBAPIFileUpload.swift
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
import MobileCoreServices

public enum KBAPIFormDataCodingKeys: String, CodingKey, CaseIterable {
	case filename;
	case mimeType;
	case contentStream;
	case data;
}

public protocol KBAPIFileUploadProtocol: Encodable {
	typealias FormDataCodingKeys = KBAPIFormDataCodingKeys;
	
	var filename: String { get };
	var mimeType: String { get };
	var contentsStream: InputStream { get };
}

public struct KBAPIDataUpload {
	private typealias Metadata = KBAPIFileUploadMetadata;

	public let contentsStream: InputStream;
	private let metadata: Metadata;

	private init? (_ contentsStream: InputStream?, metadata: Metadata) {
		guard let contentsStream = contentsStream else {
			return nil;
		}
		self.init (contentsStream, metadata: metadata);
	}
	
	private init (_ contentsStream: InputStream, metadata: Metadata) {
		self.contentsStream = contentsStream;
		self.metadata = metadata;
	}
}

extension KBAPIDataUpload: Encodable {
	public func encode (to encoder: Encoder) throws {
		var metaContainer = encoder.container (keyedBy: KBAPIFormDataCodingKeys.self);
		try metaContainer.encode (self.filename, forKey: .filename);
		try metaContainer.encode (self.mimeType, forKey: .mimeType);
		
		var dataContainer = metaContainer.nestedUnkeyedContainer (forKey: .data);
		try self.contentsStream.readAll {
			try dataContainer.encode (contentsOf: Data (bytesNoCopy: UnsafeMutableRawPointer (mutating: $0), count: $1, deallocator: .none));
		}
	}
}

extension KBAPIDataUpload: KBAPIFileUploadProtocol {
	public var filename: String {
		return self.metadata.filename;
	}
	
	public var mimeType: String {
		return self.metadata.mimeType;
	}
}

public extension KBAPIDataUpload {
	public init (data: Data) {
		self.init (InputStream (data: data), metadata: Metadata ());
	}
	
	public init? (fileURL: URL) {
		guard fileURL.isFileURL else {
			return nil;
		}
		self.init (InputStream (url: fileURL), metadata: Metadata (fileURL: fileURL));
	}
	
	public init (data: Data, filename: String) {
		self.init (InputStream (data: data), metadata: Metadata (filename: filename));
	}
	
	public init (data: Data, filename: String, mimeType: String) {
		self.init (InputStream (data: data), metadata: Metadata (filename: filename, mimeType: mimeType));
	}
}

private struct KBAPIFileUploadMetadata {
	fileprivate let filename: String;
	fileprivate let mimeType: String;
	
	fileprivate init () {
		self.init (filename: "");
	}
	
	fileprivate init (filename: String) {
		self.init (filename: filename.isEmpty ? "file.bin" : filename, mimeType: "");
	}
	
	fileprivate init (filename: String, mimeType: String) {
		guard !filename.isEmpty else {
			self.init (filename: "");
			return;
		}
		
		if (mimeType.isEmpty || (UTTypeCopyPreferredTagWithClass (kUTTagClassMIMEType, mimeType as CFString) == nil)) {
			let pathExtension = URL (fileURLWithPath: filename).pathExtension as CFString;
			if
				let typeIdentifier = UTTypeCreatePreferredIdentifierForTag (kUTTagClassFilenameExtension, pathExtension, kUTTypeData)?.takeUnretainedValue (),
				let mimeType = UTTypeCopyPreferredTagWithClass (typeIdentifier, kUTTagClassMIMEType)?.takeUnretainedValue () as String? {
				self.init (unchecked: (filename, mimeType));
			} else {
				self.init (unchecked: (filename, "application/octet-stream"))
			}
		} else {
			self.init (unchecked: (filename, mimeType));
		}
	}
	
	fileprivate init (fileURL: URL) {
		let filename = fileURL.lastPathComponent;
		if
			let typeIdentifier = (try? fileURL.resourceValues (forKeys: [.typeIdentifierKey]))?.typeIdentifier as CFString?,
			UTTypeConformsTo (typeIdentifier, kUTTypeData),
			let mimeType = UTTypeCopyPreferredTagWithClass (typeIdentifier, kUTTagClassMIMEType)?.takeUnretainedValue () as String? {
			self.init (unchecked: (filename, mimeType));
		} else {
			self.init (filename: filename);
		}
	}
	
	private init (unchecked: (filename: String, mimeType: String)) {
		self.filename = unchecked.filename;
		self.mimeType = unchecked.mimeType;
	}
}
