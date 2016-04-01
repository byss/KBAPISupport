//
//  KBLogger.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 4/1/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
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

#import "KBLogger.h"

#import "KBAPISupportLogging_Protected.h"

static id <KBLogger> KBLoggerInstance = nil;

static char const *const logLevelString (KBLogLevel const logLevel);

@implementation KBLogger

@synthesize logLevel = _logLevel;

+ (void) initialize {
	if (self == [KBLogger class]) {
		KBLoggerInstance = [KBLogger new];
		KBLOGI (@"%@ initialized", self);
	}
}

+ (id<KBLogger>)sharedLogger {
	return KBLoggerInstance;
}

+ (void)setSharedLogger:(id<KBLogger>)sharedLogger {
	KBLoggerInstance = (sharedLogger ?: [KBLogger new]);
}

- (instancetype)init {
	if (self = [super init]) {
		_logLevel = KBLogLevelDebug;
	}
	
	return self;
}

- (void)logWithLevel:(KBLogLevel)level file:(const char *)file line:(int)line function:(const char *)function message:(NSString *)fmt, ... {
	if (level > self.logLevel) {
		return;
	}
	
	va_list args;
	va_start (args, fmt);
	NSString *message = [[NSString alloc] initWithFormat:fmt arguments:args];
	va_end (args);
	
	NSLog (@"KBAPISupport: %s%s (%d): %@", logLevelString (level), function, line, message);
}

@end

static char const *const logLevelString (KBLogLevel const logLevel) {
	static char const *const noLogLevel = "";
	static char const *const logLevelStrings [] = {
		"E: ",
		"W: ",
		"I: ",
		"D: ",
	};
	
	if ((logLevel < 1) || (logLevel > sizeof (logLevelStrings) / sizeof (*logLevelStrings))) {
		return noLogLevel;
	} else {
		return logLevelStrings [logLevel - 1];
	}
}
