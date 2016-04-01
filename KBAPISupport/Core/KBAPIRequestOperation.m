//
//  KBAPIRequestOperation.m
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
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

#import "KBAPIRequestOperation_Protected.h"

#import "KBOperation_Protected.h"

#if __has_include (<KBAPISupport/KBAPISupport+NetworkIndicator.h>)
#	import "KBNetworkIndicator.h"
#endif

static NSTimeInterval KBAPIRequestOperationDefaultTimeout = 30.0;

@implementation KBAPIRequestOperation

@dynamic operationCompletionBlock;

+ (NSTimeInterval)defaultTimeout {
	return KBAPIRequestOperationDefaultTimeout;
}

+ (void)setDefaultTimeout:(NSTimeInterval)defaultTimeout {
	KBAPIRequestOperationDefaultTimeout = defaultTimeout;
}

- (instancetype)initWithCompletion:(void (^)(id _Nullable, NSError * _Nullable))completion {
	return [self initWithRequest:(id _Nonnull) nil completion:completion];
}

- (instancetype)initWithRequest:(KBAPIRequest *)request completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
	if (!request) {
		return nil;
	}
	
	if (self = [super initWithCompletion:completion]) {
		_request = request;
		_timeout = [self.class defaultTimeout];
	}
	
	return self;
}

- (void)main {
#if __has_include (<KBAPISupport/KBAPISupport+NetworkIndicator.h>)
	[KBNetworkIndicator requestStarted];
#endif

	[super main];
	
#if __has_include (<KBAPISupport/KBAPISupport+NetworkIndicator.h>)
	[KBNetworkIndicator requestFinished];
#endif
}

@end
