//
//  UIImageLoading.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 8/3/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

import UIKit.UIImage

public protocol UIImageLoading {
	func setImage (url: URL);
	func setImage (url: URL, completion: @escaping (Result <UIImage>) -> UIImage?);
	func setImage (with request: URLRequest);
	func setImage (with request: URLRequest, completion: @escaping (Result <UIImage>) -> UIImage?);
	func setImage <R> (with request: R) where R: KBAPIRequest, R.ResponseType == UIImage;
	func setImage <R> (with request: R, completion: @escaping (Result <UIImage>) -> UIImage?) where R: KBAPIRequest, R.ResponseType == UIImage;
	func cancelImageLoading ();
}

internal protocol UIImageLoadingImplementation: UIImageLoading, NSObjectProtocol {
	var currentImageConnection: KBAPIConnectionProtocol? { get set }

	func setImage <T> (using connection: (T, @escaping (Result <UIImage>) -> ()) -> KBAPIConnectionProtocol, with argument: T);
	func setImage <T> (using connection: (T, @escaping (Result <UIImage>) -> ()) -> KBAPIConnectionProtocol, with argument: T, completion: @escaping (Result <UIImage>) -> UIImage?);
	
	func handleLoadedImage (_ image: UIImage);
}

extension UIImageLoadingImplementation {
	@_inlineable
	public func setImage (url: URL) {
		self.setImage (using: UIImage.withURL, with: url);
	}

	@_inlineable
	public func setImage (url: URL, completion: @escaping (Result <UIImage>) -> UIImage?) {
		self.setImage (using: UIImage.withURL, with: url, completion: completion);
	}

	@_inlineable
	public func setImage (with request: URLRequest) {
		self.setImage (using: UIImage.withRequest, with: request);
	}
	
	@_inlineable
	public func setImage (with request: URLRequest, completion: @escaping (Result <UIImage>) -> UIImage?) {
		self.setImage (using: UIImage.withRequest, with: request, completion: completion);
	}

	@_inlineable
	public func setImage <R> (with request: R) where R: KBAPIRequest, R.ResponseType == UIImage {
		self.setImage (using: UIImage.withRequest, with: request);
	}
	
	@_inlineable
	public func cancelImageLoading () {
		self.currentImageConnection?.cancel ();
		self.currentImageConnection = nil;
	}

	@_inlineable
	public func setImage <R> (with request: R, completion: @escaping (Result <UIImage>) -> UIImage?) where R: KBAPIRequest, R.ResponseType == UIImage {
		self.setImage (using: UIImage.withRequest, with: request, completion: completion);
	}
	
	@_versioned
	internal func setImage <T> (using connection: (T, @escaping (Result <UIImage>) -> ()) -> KBAPIConnectionProtocol, with argument: T) {
		self.setImage (using: connection, with: argument) { $0.value };
	}

	@_versioned
	internal func setImage <T> (using connection: (T, @escaping (Result <UIImage>) -> ()) -> KBAPIConnectionProtocol, with argument: T, completion: @escaping (Result <UIImage>) -> UIImage?) {
		self.currentImageConnection?.cancel ();
		self.currentImageConnection = connection (argument) { [weak self] in
			guard let strongSelf = self else {
				return;
			}
			strongSelf.currentImageConnection = nil;
			completion ($0).map { strongSelf.handleLoadedImage ($0) };
		};
	}

	@_versioned
	internal var currentImageConnection: KBAPIConnectionProtocol? {
		get { return objc_getAssociatedObject (self, &currentImageConnectionKey) as? KBAPIConnectionProtocol }
		set { objc_setAssociatedObject (self, &currentImageConnectionKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
	}
}

private var currentImageConnectionKey: () = ();
