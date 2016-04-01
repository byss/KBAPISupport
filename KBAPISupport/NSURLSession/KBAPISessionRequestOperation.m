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

#import "KBAPISessionRequestOperation.h"
#import "KBAPIRequestOperation_Protected.h"

#import "NSMutableURLRequest+KBAPIRequest.h"

static NSURLSession *KBAPISessionRequestOperationDefaultSession = nil;

@interface KBAPISessionRequestOperation () {
	__weak NSURLSessionTask *_task;
	
	dispatch_semaphore_t _semaphore;
	NSData *_result;
}

@end

@implementation KBAPISessionRequestOperation

+ (void)initialize {
	if (self == [KBAPISessionRequestOperation class]) {
		KBAPISessionRequestOperationDefaultSession = [NSURLSession sharedSession];
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
	NSURLSession *session = (self.session ?: [self.class defaultSession]);
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithAPIRequest:self.request];
	req.timeoutInterval = self.timeout;

	__weak typeof (self) weakSelf = self;
	NSURLSessionTask *task = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		[weakSelf handleTaskCompletionWithData:data error:error];
	}];
	_task = task;

	_semaphore = dispatch_semaphore_create (0);
	[task resume];
	
	dispatch_semaphore_wait (_semaphore, DISPATCH_TIME_FOREVER);
	[super main];
}

- (void) handleTaskCompletionWithData: (NSData *) responseData error: (NSError *) error {
	_result = responseData;
	self.error = error;
	
	dispatch_semaphore_signal (_semaphore);
}

- (void)cancel {
	[_task cancel];
	[super cancel];
}

- (id) result {
	return _result;
}

@end
