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

#import <UIKit/UIKit.h>

static int32_t KBNetworkRequestCount = 0;
static dispatch_queue_t KBNetworkIndicatorQueue = NULL;

@implementation KBNetworkIndicator

+ (void) initialize {
	if (self == [KBNetworkIndicator class]) {
		KBNetworkIndicatorQueue = dispatch_queue_create ("KBNetworkIndicatorQueue", dispatch_queue_attr_make_with_qos_class (DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0));
	}
}

+ (void) requestStarted {
	dispatch_async (KBNetworkIndicatorQueue, ^{
		int32_t oldValue = KBNetworkRequestCount++;
		if (oldValue == 0) {
			[self setNetworkIndicatorActive:YES];
		}
	});
}

+ (void) requestFinished {
	dispatch_async (KBNetworkIndicatorQueue, ^{
		if (KBNetworkRequestCount > 0) {
			KBNetworkRequestCount--;
		}
		dispatch_after (dispatch_time (DISPATCH_TIME_NOW, (int64_t) (0.15 * NSEC_PER_SEC)), KBNetworkIndicatorQueue, ^{
			if (KBNetworkRequestCount == 0) {
				[self setNetworkIndicatorActive:NO];
			}
		});
	});
}

+ (void) setNetworkIndicatorActive: (BOOL) active {
	dispatch_sync (dispatch_get_main_queue (), ^{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = active;
	});
}

@end
