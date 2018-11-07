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
import Foundation

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

private func makeLogger (subsystem: String, category: String) -> () -> KBLoggerProtocol {
	return { KBLoggerType.init (subsystem: subsystem, category: category) };
}

internal final class KBLoggerWrapper: KBLoggerProtocol {
	private static var reloadLoggerCallbacks = [UnsafeRawPointer: () -> ()] ();
	
	private var logger: KBLoggerProtocol;
	
	fileprivate static func loggerTypeDidUpdate () {
		self.reloadLoggerCallbacks.values.forEach { $0 () };
	}
	
	private static func registerLogger (_ logger: KBLoggerWrapper, reloadLoggerCallback: @escaping (KBLoggerWrapper) -> ()) {
		let logger = Unmanaged.passUnretained (logger).toOpaque ();
		self.reloadLoggerCallbacks [logger] = { reloadLoggerCallback (logger.assumingMemoryBound (to: self).pointee) };
	}
	
	private static func unregisterLogger (_ logger: KBLoggerWrapper) {
		self.reloadLoggerCallbacks [Unmanaged.passUnretained (logger).toOpaque ()] = nil;
	}
	
	internal convenience init (_ filename: String = #file) {
		self.init (category: URL (fileURLWithPath: filename).deletingPathExtension ().lastPathComponent);
	}
	
	internal init (subsystem: String = .loggerBundleIdentifier, category: String) {
		let makeLoggerBlock = makeLogger (subsystem: subsystem, category: category);
		self.logger = makeLoggerBlock ();
		KBLoggerWrapper.registerLogger (self) {
			$0.logger = makeLoggerBlock ()
		}
	}
	
	deinit {
		KBLoggerWrapper.unregisterLogger (self);
	}
	
	@inline (__always)
	internal func log (_ level: KBLoggerProtocol.Level, _ message: @autoclosure () -> String) {
		self.logger.log (level, message);
	}
}

internal struct KBLogger: KBLoggerProtocol {
#if DEBUG
	private static let defaultLevel = Bundle.main.overrideDefaultLogLevel ?? .info;
#else
	private static let defaultLevel = Level.fault;
#endif
	
	internal var minimumLevel = KBLogger.defaultLevel;
	
	internal var abortsOnFault = true {
		didSet {
#if DEBUG
			if (!self.abortsOnFault) {
				_ = KBLogger.disabledAbortsOnFaultOnceToken;
			}
#endif
		}
	}
	
	private let logHandle: OSLog;

	internal init (subsystem: String, category: String) {
		self.logHandle = OSLog (subsystem: subsystem, category: category);
	}
	
	@inline (__always)
	internal func log (_ level: Level, _ message: @autoclosure () -> String) {
		if (level == .fault) {
			let message = message ();
			self.log (level, message: message);
			if (self.abortsOnFault) {
				fatalError (message);
			} else {
#if DEBUG
				self.log (level, message: "This is a serious error. Please consider turning `abortsOnFault` on again." as StaticString);
#endif
			}
		} else if (self.minimumLevel <= level) {
			self.log (level, message: message ());
		}
	}
	
#if swift(>=4.2)
	@usableFromInline
	internal func log (_ level: Level, message: String) {
		os_log ("%@", log: self.logHandle, type: level.osLogType, message);
	}
#else
	@_versioned
	internal func log (_ level: Level, message: String) {
		os_log ("%@", log: self.logHandle, type: level.osLogType, message);
	}
#endif

#if DEBUG
	#if swift(>=4.2)
	@usableFromInline
	internal func log (_ level: Level, message: StaticString) {
		os_log (message, log: self.logHandle, type: level.osLogType);
	}
	#else
	@_versioned
	internal func log (_ level: Level, message: StaticString) {
		os_log (message, log: self.logHandle, type: level.osLogType);
	}
	#endif
#endif
}

#if DEBUG
private extension KBLogger {
	private static let disabledAbortsOnFaultOnceToken: () = print (
		"",
		"",
		"[WARNING]",
		"KBAPISupport reports only critical, game-breaking errors using `KBLogLevel.fault`, so setting `abortsOnFault` to `false`",
		"is not recommended. This option should only be used as a last resort for things like bug workarounds or such. Please",
		"consider turning is off as soon as possible because it can lead to an unimaginable amount of undesired behaviour.",
		"[/WARNING]",
		"",
		"",
		separator: "\n"
	);
}
#endif

fileprivate extension Bundle {
	fileprivate static let logger = Bundle (for: KBLoggerWrapper.self);
	
#if DEBUG
	fileprivate var overrideDefaultLogLevel: KBLogLevel? {
		return (self.object (forInfoDictionaryKey: .overrideDefaultLevelInfoDictionaryKey) as? String).flatMap (KBLogLevel.init);
	}
#endif
}

fileprivate extension String {
#if DEBUG
	fileprivate static let overrideDefaultLevelInfoDictionaryKey = "KBOverrideDefaultLogLevel";
#endif
	fileprivate static let loggerBundleIdentifier = Bundle.logger.bundleIdentifier!;
}
