//
//  KBNetworkIndicator.h
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

#import <Foundation/Foundation.h>

@protocol KBNetworkIndicatorDelegate;

/** This class is used to manage the network activity indicator. */
@interface KBNetworkIndicator: NSObject

/** ---------------------------
  * @name Counting API requests
  * ---------------------------
  */
#if !TARGET_OS_IPHONE

/** Get current network activity delegate (non-iOS). */
+ (id <KBNetworkIndicatorDelegate>) activityDelegate;

/** Set network activity delegate (non-iOS). */
+ (void) setActivityDelegate: (id <KBNetworkIndicatorDelegate>) delegate;

#endif

/** Call this method when new network activity begins. */
+ (void) requestStarted;

/** Call this method when new network activity finishes. */
+ (void) requestFinished;

@end

#if !TARGET_OS_IPHONE
/** This protocol is used to handle non-iOS network activity indicator. */
@protocol KBNetworkIndicatorDelegate <NSObject>

@required
/** This methid is called when network activity status is changed. */
- (void) setNetworkActivityStatus: (BOOL) active;

@end
#endif