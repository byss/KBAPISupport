//
//  KBAtomicCounter.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/19/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

import Swift

internal struct KBAtomicCounter {
	internal var value: Int {
		mutating get {
			return __KBAtomicCounterGetNext (&self.implementation);
		}
	}
	
	internal init (_ value: Int = 0) {
		self.implementation = __KBAtomicCounter ();
		__KBAtomicCounterInit (&self.implementation, value);
	}
	
	internal mutating func getNext () -> Int {
		return __KBAtomicCounterGetNext (&self.implementation);
	}
	
	private var implementation: __KBAtomicCounter;
}
