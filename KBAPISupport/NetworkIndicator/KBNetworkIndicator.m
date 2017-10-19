//
//  KBNetworkIndicator.m
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

#import "KBNetworkIndicator.h"

#import <stdatomic.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "KBAPISupportLogging_Protected.h"

static _Atomic NSUInteger KBNetworkRequestCount = ATOMIC_VAR_INIT (0);

@interface KBNetworkIndicator (dynamic)

+ (void) setNetworkIndicatorActive: (BOOL) active;

@end

__attribute__((visibility("hidden"))) static void KBNetworkIndicator_setNetworkIndicatorActive_UIApplication (id self, SEL _cmd, BOOL active);
__attribute__((visibility("hidden"))) static void KBNetworkIndicator_setNetworkIndicatorActive_noop (id self, SEL _cmd, BOOL active);

@implementation KBNetworkIndicator

+ (BOOL) resolveClassMethod: (SEL) sel {
	if (sel_isEqual (sel, @selector (setNetworkIndicatorActive:))) {
		BOOL const isExtension = !![[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSExtension"];
		IMP const implementation = (IMP) (isExtension ? KBNetworkIndicator_setNetworkIndicatorActive_noop : KBNetworkIndicator_setNetworkIndicatorActive_UIApplication);
		class_addMethod (object_getClass (self), sel, implementation, (char const []) { _C_ID, _C_SEL, _C_BOOL, '\0' });
		return YES;
	} else {
		return [super resolveClassMethod:sel];
	}
}

+ (void) requestStarted {
	if (!atomic_fetch_add (&KBNetworkRequestCount, 1)) {
		dispatch_async (dispatch_get_main_queue (), ^{
			[self setNetworkIndicatorActive:YES];
		});
	}
}

+ (void) requestFinished {
	if (atomic_load (&KBNetworkRequestCount) > 0) {
		atomic_fetch_add (&KBNetworkRequestCount, -1);
	} else {
		KBASLOGW (@"Network indicator counter gone below zero, resetting");
	}
	
	dispatch_after (dispatch_time (DISPATCH_TIME_NOW, (int64_t) (0.15 * NSEC_PER_SEC)), dispatch_get_main_queue (), ^{
		if (!atomic_load (&KBNetworkRequestCount)) {
			[self setNetworkIndicatorActive:NO];
		}
	});
}

@end

__attribute__((visibility("hidden"))) static void KBNetworkIndicator_setNetworkIndicatorActive_UIApplication (id self, SEL _cmd, BOOL active) NS_EXTENSION_UNAVAILABLE ("") {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = active;
}

__attribute__((visibility("hidden"))) static void KBNetworkIndicator_setNetworkIndicatorActive_noop (id self, SEL _cmd, BOOL active) {
}
