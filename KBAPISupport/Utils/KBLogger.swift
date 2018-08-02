//
//  KBLogger.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/31/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
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
	
	internal init (subsystem: String = .loggerBundleIdentifier, category: String = NSString (string: #file).deletingPathExtension) {
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
	
	@_versioned
	internal func log (_ level: Level, message: String) {
		os_log ("%@", log: self.logHandle, type: level.osLogType, message);
	}
	
#if DEBUG
	@_versioned
	internal func log (_ level: Level, message: StaticString) {
		os_log (message, log: self.logHandle, type: level.osLogType);
	}
#endif
}

#if DEBUG
private extension KBLogger {
	private static let disabledAbortsOnFaultOnceToken: () = print (
		"",
		"",
		"[WARNING]",
		"KBAPISupport reports only critical, game-breaking errors using `KBLogLevel.fault`, so setting `abortsOnFault` to `false`",
		"is not recommended. This option should only be used as a last resort for thing like bug workarounds or such. Please",
		"consider turning is off as soon as possible because it can lead to an unimaginable amount of undesired behaviour.",
		"",
		"",
		separator: "\n"
	);
}
#endif

fileprivate extension Bundle {
	fileprivate static let logger = Bundle (for: KBLoggerWrapper.self);
	
	fileprivate var overrideDefaultLogLevel: KBLogLevel? {
		return (self.object (forInfoDictionaryKey: .overrideDefaultLevelInfoDictionaryKey) as? String).flatMap (KBLogLevel.init);
	}
}

fileprivate extension String {
#if DEBUG
	fileprivate static let overrideDefaultLevelInfoDictionaryKey = "KBOverrideDefaultLogLevel";
#endif
	fileprivate static let loggerBundleIdentifier = Bundle.logger.bundleIdentifier!;
}
