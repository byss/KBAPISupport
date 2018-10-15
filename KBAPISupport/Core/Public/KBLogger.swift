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

/// Severity level of various supplemental information significant mostly for developers.
public enum KBLogLevel {
	case debug;   /// Nearly useless except rare cases of you being this framework developer
	case info;    /// Network data interchange tracing
	case warning; /// Perfectly manageable errors, e.g. connectivity loss.
	case error;   /// Currently unused. ¯\_(ツ)_/¯
	case fault;   /// The most severe errorneous states, leading to undefined behaviour and terrifying consequences.
	              /// Mostly caused by distracted developers who forget to write single trivial line of code, nevermind.
}

public extension KBLogLevel {
	/// Initialize `KBLogLevel` value corresponding to given `OSLogType`.
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
	
	/// Provides equivalent `OSLogType` severity label.
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

/// A type compatible with KBAPISupport's internal logging facilities and may provide
/// an alternate presentation or storage of the generated messages.
public protocol KBLoggerProtocol {
	typealias Level = KBLogLevel;
	
	/// OSLog-compatible subsystem identificators.
	init (subsystem: String, category: String);
	
	/// Processes a message with specified severity marker.
	func log (_ level: Level, _ message: @autoclosure () -> String);
	/// Processes a message with `debug` level.
	func debug (_ message: @autoclosure () -> String);
	/// Processes a message with `info` level.
	func info (_ message: @autoclosure () -> String);
	/// Processes a message with `warning` level.
	func warning (_ message: @autoclosure () -> String);
	/// Processes a message with `error` level.
	func error (_ message: @autoclosure () -> String);
	/// Processes a message with `fault` level.
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

/// Logging facility that is used throught all of the KBAPISupport. Modifiable, changes are reflected immediately and affect all library output.
public var KBLoggerType: KBLoggerProtocol.Type = KBLogger.self {
	didSet {
		KBLoggerWrapper.loggerTypeDidUpdate ();
	}
}
