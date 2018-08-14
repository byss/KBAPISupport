//
//  KBImageLoading.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 8/3/18.
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

import Swift

public protocol KBImageLoading {
	func setImage (url: URL);
	func setImage (url: URL, completion: @escaping (Result <KBImage>) -> KBImage?);
	func setImage (with request: URLRequest);
	func setImage (with request: URLRequest, completion: @escaping (Result <KBImage>) -> KBImage?);
	func setImage <R> (with request: R) where R: KBAPIRequest, R.ResponseType == KBImage;
	func setImage <R> (with request: R, completion: @escaping (Result <KBImage>) -> KBImage?) where R: KBAPIRequest, R.ResponseType == KBImage;
	func cancelImageLoading ();
}

internal protocol KBImageLoadingImplementation: KBImageLoading, NSObjectProtocol {
	var currentImageConnection: KBAPIConnectionProtocol? { get set }

	func setImage <T> (using connection: (T, @escaping (Result <KBImage>) -> ()) -> KBAPIConnectionProtocol, with argument: T);
	func setImage <T> (using connection: (T, @escaping (Result <KBImage>) -> ()) -> KBAPIConnectionProtocol, with argument: T, completion: @escaping (Result <KBImage>) -> KBImage?);
	
	func handleLoadedImage (_ image: KBImage);
}

extension KBImageLoadingImplementation {
	@inlinable
	public func setImage (url: URL) {
		self.setImage (using: KBImage.withURL, with: url);
	}

	@inlinable
	public func setImage (url: URL, completion: @escaping (Result <KBImage>) -> KBImage?) {
		self.setImage (using: KBImage.withURL, with: url, completion: completion);
	}

	@inlinable
	public func setImage (with request: URLRequest) {
		self.setImage (using: KBImage.withRequest, with: request);
	}
	
	@inlinable
	public func setImage (with request: URLRequest, completion: @escaping (Result <KBImage>) -> KBImage?) {
		self.setImage (using: KBImage.withRequest, with: request, completion: completion);
	}

	@inlinable
	public func setImage <R> (with request: R) where R: KBAPIRequest, R.ResponseType == KBImage {
		self.setImage (using: KBImage.withRequest, with: request);
	}
	
	@inlinable
	public func cancelImageLoading () {
		self.currentImageConnection?.cancel ();
		self.currentImageConnection = nil;
	}

	@inlinable
	public func setImage <R> (with request: R, completion: @escaping (Result <KBImage>) -> KBImage?) where R: KBAPIRequest, R.ResponseType == KBImage {
		self.setImage (using: KBImage.withRequest, with: request, completion: completion);
	}
	
	@usableFromInline
	internal func setImage <T> (using connection: (T, @escaping (Result <KBImage>) -> ()) -> KBAPIConnectionProtocol, with argument: T) {
		self.setImage (using: connection, with: argument) { $0.value };
	}

	@usableFromInline
	internal func setImage <T> (using connection: (T, @escaping (Result <KBImage>) -> ()) -> KBAPIConnectionProtocol, with argument: T, completion: @escaping (Result <KBImage>) -> KBImage?) {
		self.currentImageConnection?.cancel ();
		self.currentImageConnection = connection (argument) { [weak self] in
			guard let strongSelf = self else {
				return;
			}
			strongSelf.currentImageConnection = nil;
			completion ($0).map { strongSelf.handleLoadedImage ($0) };
		};
	}

	@usableFromInline
	internal var currentImageConnection: KBAPIConnectionProtocol? {
		get { return objc_getAssociatedObject (self, &currentImageConnectionKey) as? KBAPIConnectionProtocol }
		set { objc_setAssociatedObject (self, &currentImageConnectionKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
	}
}

private var currentImageConnectionKey: () = ();
