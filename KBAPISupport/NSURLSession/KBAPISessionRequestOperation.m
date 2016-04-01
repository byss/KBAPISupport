//
//  KBAPISessionRequestOperation.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/31/16.
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

#import "KBAPISessionRequestOperation_Protected.h"

#import "NSMutableURLRequest+KBAPIRequest.h"
#import "KBAPISupportLogging_Protected.h"
#import "KBAPIRequest.h"

#if __has_include (<KBAPISupport/KBAPISupport+NetworkIndicator.h>)
#	import "KBNetworkIndicator.h"
#endif

static NSURLSession *KBAPISessionRequestOperationDefaultSession = nil;

@interface KBAPISessionRequestOperation () {
	dispatch_semaphore_t _semaphore;
	NSData *_result;
}

@end

@implementation KBAPISessionRequestOperation

+ (void)initialize {
	if (self == [KBAPISessionRequestOperation class]) {
		KBAPISessionRequestOperationDefaultSession = [NSURLSession sharedSession];
		KBASLOGI (@"%@ initialized", self);
	}
}

+ (NSURLSession *)defaultSession {
	return KBAPISessionRequestOperationDefaultSession;
}

+ (void)setDefaultSession:(NSURLSession *)session {
	KBAPISessionRequestOperationDefaultSession = (session ?: [NSURLSession sharedSession]);
}

- (instancetype)initWithRequest:(KBAPIRequest *)request session:(NSURLSession *)session completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
	if (self = [super initWithRequest:request completion:completion]) {
		_session = session;
	}
	
	return self;
}

- (void)main {
	KBASLOGI (@"Starting request: %@ %@", self.request.HTTPMethod, self.request.URL);
	KBASLOGD (@"Headers: %@", self.request.additionalHeaders);
	KBASLOGD (@"Body length: %ld", (long) self.request.bodyData.length);
	KBASLOGD (@"Body string: %@", self.request.bodyString);
	
#if __has_include (<KBAPISupport/KBAPISupport+NetworkIndicator.h>)
	[KBNetworkIndicator requestStarted];
#endif

	NSURLSession *session = (self.session ?: [self.class defaultSession]);
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithAPIRequest:self.request];
	req.timeoutInterval = self.timeout;

	__weak typeof (self) weakSelf = self;
	NSURLSessionTask *task = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		[weakSelf handleTaskCompletionWithData:data response:response error:error];
	}];
	_task = task;

	_semaphore = dispatch_semaphore_create (0);
	[task resume];
	
	dispatch_semaphore_wait (_semaphore, DISPATCH_TIME_FOREVER);
	[super main];

#if __has_include (<KBAPISupport/KBAPISupport+NetworkIndicator.h>)
	[KBNetworkIndicator requestFinished];
#endif
}

- (void) handleTaskCompletionWithData: (NSData *) responseData response: (NSURLResponse *) response error: (NSError *) error {
	KBASLOGI (@"Task did finish");
	KBASLOGI (@"Response: %@", response);
	if (error) {
		KBASLOGE (@"Error: %@", error);
	} else {
		KBASLOGD (@"Response data length: %ld bytes", (long) responseData.length);
		KBASLOGD (@"Response string: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
	}
	
	_result = responseData;
	self.error = error;
	
	[self releaseOperationSemaphore];
}

- (void)cancel {
	[self.task cancel];
	[super cancel];
}

- (void) releaseOperationSemaphore {
	dispatch_semaphore_signal (_semaphore);
}

- (id) result {
	return _result;
}

@end
