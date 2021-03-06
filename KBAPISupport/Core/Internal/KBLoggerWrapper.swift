//
//  KBLoggerWrapper.swift
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

internal final class KBLoggerWrapper: KBLoggerProtocol {
	private static var reloadLoggerCallbacks = [UnsafeRawPointer: () -> ()] ();
	
	private var logger: KBLoggerProtocol;
	
	internal static func loggerTypeDidUpdate () {
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
	
	@usableFromInline
	internal func log (_ level: Level, message: String) {
		os_log ("%@", log: self.logHandle, type: level.osLogType, message);
	}

#if DEBUG
	@usableFromInline
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

private func makeLogger (subsystem: String, category: String) -> () -> KBLoggerProtocol {
	return { KBLoggerType.init (subsystem: subsystem, category: category) };
}
