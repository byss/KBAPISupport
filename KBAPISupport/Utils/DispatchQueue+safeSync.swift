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
	private static var identifiersCounter = KBAtomicCounter (2);
	
	private static var currentQueueIdentifier: Int? {
		if Thread.isMainThread {
			return 1;
		}
		
		return self.getSpecific (key: .queueIdentifier);
	}
	
	private var identifier: Int {
		if (self == DispatchQueue.main) {
			return 1;
		}
		
		if let identifier = self.getSpecific (key: .queueIdentifier) {
			return identifier;
		}
		
		let obtainedIdentifier = DispatchQueue.identifiersCounter.getNext ();
		self.setSpecific (key: .queueIdentifier, value: obtainedIdentifier);
		return obtainedIdentifier;
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
