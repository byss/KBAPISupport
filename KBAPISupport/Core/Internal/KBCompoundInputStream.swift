//
//  KBCompoundInputStream.swift
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

internal final class KBCompoundInputStream: InputStream {
	internal override var delegate: StreamDelegate? {
		get { return self.substreamDelegate.parentDelegate }
		set { self.substreamDelegate.parentDelegate = newValue }
	}
	
	internal override var streamError: Error? {
		return self.substreamError;
	}
	
	internal override var hasBytesAvailable: Bool {
		guard !self.activeSubstream.hasBytesAvailable else {
			return true;
		}
		guard self.activateNextSubstream () else {
			return false;
		}
		return self.hasBytesAvailable;
	}
	
	internal override var streamStatus: Status {
		guard self.substreamError == nil else {
			return .error;
		}
		let substreamStatus = self.activeSubstream.streamStatus;
		guard substreamStatus == .atEnd else {
			return substreamStatus;
		}
		guard self.activateNextSubstream () else {
			return substreamStatus;
		}
		return self.streamStatus;
	}
	
	private var activeSubstream: InputStream {
		willSet { self.activeSubstream.delegate = nil }
		didSet { self.activeSubstream.delegate = self.substreamDelegate }
	}
	private let substreamsIterator: AnyIterator <InputStream>;
	private lazy var substreamDelegate = SubstreamDelegate (self);
	private var substreamError: Error?;
	
	internal init? <S> (_ substreams: S) where S: Sequence, S.Element == InputStream {
		let substreamsIterator = AnyIterator (substreams.makeIterator ());
		guard let activeSubstream = substreamsIterator.next () else {
			return nil;
		}
		
		self.substreamsIterator = substreamsIterator;
		self.activeSubstream = activeSubstream;
		super.init (data: Data ());
		self.activeSubstream.delegate = self.substreamDelegate;
	}
	
	internal override func open () {
		self.activeSubstream.open ();
	}
	
	internal override func close () {
		self.activeSubstream.close ();
	}
	
	internal override func schedule (in aRunLoop: RunLoop, forMode mode: RunLoop.Mode) {
		self.activeSubstream.schedule (in: aRunLoop, forMode: mode);
	}
	
	internal override func remove (from aRunLoop: RunLoop, forMode mode: RunLoop.Mode) {
		self.activeSubstream.remove (from: aRunLoop, forMode: mode);
	}
	
	internal override func property (forKey key: PropertyKey) -> Any? {
		return self.activeSubstream.property (forKey: key)
	}
	
	internal override func setProperty (_ property: Any?, forKey key: PropertyKey) -> Bool {
		return self.activeSubstream.setProperty (property, forKey: key)
	}
	
	internal override func read (_ buffer: UnsafeMutablePointer <UInt8>, maxLength len: Int) -> Int {
		switch (self.streamStatus) {
		case .notOpen, .opening, .closed, .error:
			return -1;
		case .atEnd:
			return 0;
		default:
			break;
		}
		
		var bufferStart = buffer;
		let bufferEnd = bufferStart.advanced (by: len);
		
		readLoop: while (bufferStart < bufferEnd) {
			switch (self.activeSubstream.read (bufferStart, maxLength: bufferEnd - bufferStart)) {
			case 0:
				guard self.activateNextSubstream () else {
					break readLoop;
				}
			case -1:
				return -1;
			case (let readBytes):
				bufferStart += readBytes;
			}
		}
		
		return bufferStart - buffer;
	}
	
	internal override func getBuffer (_ buffer: UnsafeMutablePointer <UnsafeMutablePointer <UInt8>?>, length len: UnsafeMutablePointer <Int>) -> Bool {
		return self.activeSubstream.getBuffer (buffer, length: len);
	}
	
	private func activateNextSubstream () -> Bool {
		guard let nextSubstream = self.substreamsIterator.next () else {
			return false;
		}
		self.activeSubstream.close ();
		self.activeSubstream = nextSubstream;
		self.activeSubstream.open ();
		return true;
	}
}

private extension KBCompoundInputStream {
	private final class SubstreamDelegate: NSObject, StreamDelegate {
		fileprivate weak var parentDelegate: StreamDelegate?;
		
		private var activeSubstream: InputStream {
			get { return self.parent.activeSubstream }
			set { self.parent.activeSubstream = newValue }
		}
		
		private unowned let parent: KBCompoundInputStream;
		
		fileprivate init (_ parent: KBCompoundInputStream) {
			self.parent = parent;
		}
		
		fileprivate func stream (_ aStream: Stream, handle eventCode: Event) {
			switch (eventCode) {
			case .errorOccurred:
				self.parent.substreamError = aStream.streamError;
			case .endEncountered:
				guard !self.activateNextSubstream () else {
					return;
				}
			default:
				break;
			}
			
			self.parent.delegate?.stream? (self.parent, handle: eventCode);
		}
		
		private func activateNextSubstream () -> Bool {
			return self.parent.activateNextSubstream ();
		}
	}
}
