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
#import "NSURLSession+KBAPISupport.h"
#import "KBURLSessionDelegate.h"
#import "KBAPIRequest.h"

#if __has_include (<KBAPISupport/KBAPISupport+NetworkIndicator.h>)
#	import "KBNetworkIndicator.h"
#endif

static NSURLSession *KBAPISessionRequestOperationDefaultSession = nil;

@interface KBAPISessionRequestOperation () {
	dispatch_semaphore_t _semaphore;
	NSURLResponse *_response;
	NSMutableData *_responseData;
	NSError *_error;
}

@end

@implementation KBAPISessionRequestOperation

+ (void)initialize {
	if (self == [KBAPISessionRequestOperation class]) {
		KBAPISessionRequestOperationDefaultSession = [NSURLSession kb_sharedSession];
		KBASLOGI (@"%@ initialized", self);
	}
}

+ (NSURLSession *)defaultSession {
	return KBAPISessionRequestOperationDefaultSession;
}

+ (void)setDefaultSession:(NSURLSession *)session {
	if (session && ![session.delegate isKindOfClass:[KBURLSessionDelegate class]]) {
		@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot use a session that is not created by using one of NSURLSession (KBAPISupport) methods" userInfo:nil];
	}
	
	KBAPISessionRequestOperationDefaultSession = (session ?: [NSURLSession kb_sharedSession]);
}

- (instancetype)initWithRequest:(KBAPIRequest *)request session:(NSURLSession *)session completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
	if (session && ![session.delegate isKindOfClass:[KBURLSessionDelegate class]]) {
		@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot use a session that is not created by using one of NSURLSession (KBAPISupport) methods" userInfo:nil];
	}
	
	if (self = [super initWithRequest:request completion:completion]) {
		_session = session;
	}
	
	return self;
}

- (void) dealloc {
	NSURLSession *session = (self.session ?: [self.class defaultSession]);
	[(KBURLSessionDelegate *) session.delegate unregisterOperation:self];
}

- (void)main {
	KBASLOGI (@"Starting request: %@ %@", self.request.HTTPMethod, self.request.URL);
	KBASLOGD (@"Headers: %@", self.request.additionalHeaders);
	if (self.request.bodyStreamed) {
		KBASLOGD (@"Body stream: %@", self.request.bodyStream);
	} else {
		KBASLOGD (@"Body length: %ld", (long) self.request.bodyData.length);
		KBASLOGD (@"Body string: %@", self.request.bodyString);
	}
	
#if __has_include (<KBAPISupport/KBAPISupport+NetworkIndicator.h>)
	[KBNetworkIndicator requestStarted];
#endif

	NSURLSession *session = (self.session ?: [self.class defaultSession]);
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithAPIRequest:self.request];
	req.timeoutInterval = self.timeout;

	_task = [session dataTaskWithRequest:req];

	_semaphore = dispatch_semaphore_create (0);
	[(KBURLSessionDelegate *) session.delegate registerOperation:self];
	[self.task resume];
	
	dispatch_semaphore_wait (_semaphore, DISPATCH_TIME_FOREVER);
	[super main];

#if __has_include (<KBAPISupport/KBAPISupport+NetworkIndicator.h>)
	[KBNetworkIndicator requestFinished];
#endif
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
	[self handleTaskCompletionWithData:_responseData response:_response error:error];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition)) completionHandler {
	_response = response;
	completionHandler (NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
	if (_responseData) {
		[_responseData appendData:data];
	} else {
		_responseData = [data mutableCopy];
	}
}

- (void) handleTaskCompletionWithData: (NSData *) responseData response: (NSURLResponse *) response error: (NSError *) error {
	KBASLOGI (@"Task did finish");
	KBASLOGI (@"Response: %@", response);
	if (error) {
		KBASLOGE (@"Error: %@", error);
		self.error = error;		
	} else {
		KBASLOGD (@"Response data length: %ld bytes", (long) responseData.length);
		KBASLOGD (@"Response string: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
	}
	
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
	return _responseData;
}

@end
