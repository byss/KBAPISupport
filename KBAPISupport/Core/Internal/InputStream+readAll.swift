//
//  InputStream+readAll.swift
//  CPCommon
//
//  Created by Kirill Bystrov on 9/18/18.
//

import Foundation

internal extension InputStream {
	private enum Error: Swift.Error {
		case unknownReadFailure;
	}
	
	internal func readAll (_ dataCallback: (UnsafeRawPointer, Int) throws -> ()) throws {
		var buffer = vm_address_t (0);
		guard (vm_allocate (mach_task_self_, &buffer, vm_page_size, VM_FLAGS_ANYWHERE) == KERN_SUCCESS) else {
			return;
		}
		defer {
			vm_deallocate (mach_task_self_, buffer, vm_page_size);
		}
		
		guard let bufferPointer = UnsafeMutablePointer <UInt8> (bitPattern: buffer) else {
			return;
		}
		while (self.hasBytesAvailable) {
			switch (self.read (bufferPointer, maxLength: .streamPassthroughBufferSize)) {
			case 0:
				return;
			case -1:
				throw self.streamError ?? Error.unknownReadFailure;
			case (let readResult):
				try dataCallback (UnsafeRawPointer (bufferPointer), readResult);
			}
		}
	}
}

fileprivate extension Int {
	fileprivate static let streamPassthroughBufferSize = Int (bitPattern: vm_page_size);
}

#if arch (i386) || arch (arm) || arch (arm64_32)
fileprivate extension UnsafeMutablePointer where Pointee == UInt8 {
	fileprivate init? (bitPattern: vm_size_t) {
		self.init (bitPattern: Int (bitPattern: bitPattern));
	}
}

fileprivate extension Int {
	fileprivate init (bitPattern: vm_size_t) {
		self.init (bitPattern);
	}
}
#endif

