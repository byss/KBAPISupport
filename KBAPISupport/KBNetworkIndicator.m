//
//  KBNetworkIndicator.m
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 28.11.12.
//  Copyright (c) 2012 Kirill byss Bystrov. All rights reserved.
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

#import "KBNetworkIndicator.h"

#if TARGET_OS_IPHONE
#	import <UIKit/UIKit.h>
#endif

#import "KBAPISupport-debug.h"
#import "ARCSupport.h"

static NSUInteger requestsCount = 0;
#if !TARGET_OS_IPHONE
static id <KBNetworkIndicatorDelegate> KBNetworkIndicatorDelegate = nil;
#endif

@implementation KBNetworkIndicator

#if !TARGET_OS_IPHONE

+ (id <KBNetworkIndicatorDelegate>) activityDelegate {
	return KBNetworkIndicatorDelegate;
}

+ (void) setActivityDelegate: (id <KBNetworkIndicatorDelegate>) delegate {
	KB_RELEASE (KBNetworkIndicatorDelegate);
	KBNetworkIndicatorDelegate = KB_RETAIN (delegate);
}

#endif

+ (void) requestStarted {
	@synchronized (self) {
		if (!(requestsCount++)) {
#if TARGET_OS_IPHONE
#	if !KBAPISUPPORT_EXTENSION_SAFE
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
#	endif
#else
			[KBNetworkIndicatorDelegate setNetworkActivityStatus:YES];
#endif
		}
	}
}

+ (void) requestFinished {
	@synchronized (self) {
		if (requestsCount) {
			if (!(--requestsCount)) {
#if TARGET_OS_IPHONE
#	if !KBAPISUPPORT_EXTENSION_SAFE
				[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
#	endif
#else
				[KBNetworkIndicatorDelegate setNetworkActivityStatus:NO];
#endif
			}
		} else {
			KBAPISUPPORT_BUG_HERE
		}
	}
}

@end
