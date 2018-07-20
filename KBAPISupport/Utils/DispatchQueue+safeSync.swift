//
//  DispatchQueue+safeSync.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/19/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

import Dispatch

public extension DispatchQueue {
	private static let identifierKey = DispatchSpecificKey <Int> ();
	private static var identifiersCounter = KBAtomicCounter (1);
	
	private static var currentQueueIdentifier: Int? {
		return self.getSpecific (key: .queueIdentifier) ?? (Thread.isMainThread ? 0 : nil);
	}
	
	private var identifier: Int {
		if let identifier = self.getSpecific (key: .queueIdentifier) {
			return identifier;
		}

		let obtainedIdentifier = DispatchQueue.identifier (for: self);
		self.setSpecific (key: .queueIdentifier, value: obtainedIdentifier);
		return obtainedIdentifier;
	}
	
	private static func identifier (for queue: DispatchQueue) -> Int {
		return ((queue !== DispatchQueue.main) ? self.identifiersCounter.getNext () : 0);
	}

	public func safeSync <T> (execute work: () throws -> T) rethrows -> T {
		guard (self.identifier != DispatchQueue.currentQueueIdentifier) else {
			return try work ();
		}
		return try self.sync (execute: work);
	}
}

fileprivate extension DispatchSpecificKey where T == Int {
	fileprivate static let queueIdentifier = DispatchSpecificKey ();
}
