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

/// Coding keys of an item that is encoded using `KBAPIMultipartFormDataEncoder`.
///
/// - filename: Source file name of an item.
/// - mimeType: MIME type of the encoded data.
/// - contentStream: `InputStream` containing item data.
/// - data: Raw data of an item.
public enum KBAPIFormDataCodingKeys: String, CodingKey, CaseIterable {
	case filename;
	case mimeType;
	case contentStream;
	case data;
}

/// A type that is serializable using `KBAPIMultipartFormDataEncoder`.
public protocol KBAPIFileUploadProtocol: Encodable {
	/// See `KBAPIFormDataCodingKeys`.
	typealias FormDataCodingKeys = KBAPIFormDataCodingKeys;
	
	/// Source file name of an item.
	var filename: String { get };
	/// MIME type of the encoded data.
	var mimeType: String { get };
	/// `InputStream` containing item data.
	var contentsStream: InputStream { get };
}

/// A value representing in-memory data or a file to be uploaded.
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
	/// Fallback implementation for cases when `KBAPIDataUpload` is being used with a generic `Encoder`.
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
	/// Creates an new instance containing in-memory data for upload.
	///
	/// - Parameter data: Raw item data to upload.
	public init (data: Data) {
		self.init (InputStream (data: data), metadata: Metadata ());
	}
	
	/// Creates an new instance containing data at the given file URL.
	///
	/// - Parameter fileURL: Source of item's data.
	public init? (fileURL: URL) {
		guard fileURL.isFileURL else {
			return nil;
		}
		self.init (InputStream (url: fileURL), metadata: Metadata (fileURL: fileURL));
	}
	
	/// Creates an new instance containing in-memory data for upload under the given filename.
	///
	/// - Parameters:
	///   - data: Raw item data to upload.
	///   - filename: File name associated with the item's data.
	public init (data: Data, filename: String) {
		self.init (InputStream (data: data), metadata: Metadata (filename: filename));
	}
	
	/// Creates an new instance containing in-memory data for upload under the given filename with specified MIME type.
	///
	/// - Parameters:
	///   - data: Raw item data to upload.
	///   - filename: File name associated with the item's data.
	///   - mimeType: MIME type of the encoded data.
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
		
		if (UTIdentifier.preferred (forTag: .mimeType, withValue: mimeType, conformingTo: .data) == nil) {
			let pathExtension = URL (fileURLWithPath: filename).pathExtension;
			if let mimeType = UTIdentifier.preferred (forTag: .filenameExtension, withValue: pathExtension, conformingTo: .data)?.preferredValue (ofTag: .mimeType) {
				self.init (unchecked: (filename, mimeType));
			} else {
				self.init (unchecked: (filename, UTIdentifier.data.preferredValue (ofTag: .mimeType)!));
			}
		} else {
			self.init (unchecked: (filename, mimeType));
		}
	}
	
	fileprivate init (fileURL: URL) {
		let filename = fileURL.lastPathComponent;
		if
			let typeIdentifier = (try? fileURL.resourceValues (forKeys: [.typeIdentifierKey]))?.typeIdentifier.flatMap (UTIdentifier.init),
			typeIdentifier.conforms (to: .data),
			let mimeType = typeIdentifier.preferredValue (ofTag: .mimeType) {
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
