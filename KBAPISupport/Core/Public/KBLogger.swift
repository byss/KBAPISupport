//
//  KBLogger.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/31/18.
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

import os

public enum KBLogLevel {
	case debug;
	case info;
	case warning;
	case error;
	case fault;
}

public extension KBLogLevel {
	public init? (_ osLogType: OSLogType) {
		switch (osLogType) {
		case .debug:
			self = .debug;
		case .info:
			self = .info;
		case .default:
			self = .warning;
		case .error:
			self = .error;
		case .fault:
			self = .fault;
		default:
			return nil;
		}
	}
	
	public var osLogType: OSLogType {
		switch (self) {
		case .debug:
			return .debug;
		case .info:
			return .info;
		case .warning:
			return .default;
		case .error:
			return .error;
		case .fault:
			return .fault;
		}
	}
}

extension KBLogLevel: Comparable {
	private var severity: Int {
		switch (self) {
		case .debug:
			return -2;
		case .info:
			return -1;
		case .warning:
			return 0;
		case .error:
			return 1;
		case .fault:
			return 2;
		}
	}
	
	public static func < (lhs: KBLogLevel, rhs: KBLogLevel) -> Bool {
		return lhs.severity < rhs.severity;
	}
}

#if DEBUG
extension KBLogLevel: LosslessStringConvertible {
	public var description: String {
		switch (self) {
		case .debug:
			return "debug";
		case .info:
			return "info";
		case .warning:
			return "warning";
		case .error:
			return "error";
		case .fault:
			return "fault";
		}
	}
	
	public init? (_ string: String) {
		switch (string) {
		case "debug":
			self = .debug;
		case "info":
			self = .info;
		case "warning":
			self = .warning;
		case "error":
			self = .error;
		case "fault":
			self = .fault;
		default:
			return nil;
		}
	}
}
#endif

public protocol KBLoggerProtocol {
	typealias Level = KBLogLevel;
	
	init (subsystem: String, category: String);
	
	func log (_ level: Level, _ message: @autoclosure () -> String);
	func debug (_ message: @autoclosure () -> String);
	func info (_ message: @autoclosure () -> String);
	func warning (_ message: @autoclosure () -> String);
	func error (_ message: @autoclosure () -> String);
	func fault (_ message: @autoclosure () -> String);
}
	
public extension KBLoggerProtocol {
	@inline (__always)
	public func debug (_ message: @autoclosure () -> String) {
		self.log (.debug, message);
	}
	
	@inline (__always)
	public func info (_ message: @autoclosure () -> String) {
		self.log (.info, message);
	}
	
	@inline (__always)
	public func warning (_ message: @autoclosure () -> String) {
		self.log (.warning, message);
	}
	
	@inline (__always)
	public func error (_ message: @autoclosure () -> String) {
		self.log (.error, message);
	}
	
	@inline (__always)
	public func fault (_ message: @autoclosure () -> String) {
		self.log (.fault, message);
	}
}

public var KBLoggerType: KBLoggerProtocol.Type = KBLogger.self {
	didSet {
		KBLoggerWrapper.loggerTypeDidUpdate ();
	}
}
