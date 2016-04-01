//
//  KBAPINSURLRequestOperation.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/30/16.
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

#import "KBAPINSURLRequestOperation_Protected.h"

#import "NSMutableURLRequest+KBAPIRequest.h"
#import "KBAPISupportLogging_Protected.h"
#import "KBAPIRequest.h"

#if __has_include (<KBAPISupport/KBAPISupport+NetworkIndicator.h>)
#	import "KBNetworkIndicator.h"
#endif

@interface KBAPINSURLRequestOperation () {
	dispatch_semaphore_t _semaphore;
	NSMutableData *_buffer;
}

@end

@implementation KBAPINSURLRequestOperation

- (void) main {
	KBLOGI (@"Starting request: %@ %@", self.request.HTTPMethod, self.request.URL);
	KBLOGD (@"Headers: %@", self.request.additionalHeaders);
	KBLOGD (@"Body length: %ld", (long) self.request.bodyData.length);
	KBLOGD (@"Body string: %@", self.request.bodyString);

#if __has_include (<KBAPISupport/KBAPISupport+NetworkIndicator.h>)
	[KBNetworkIndicator requestStarted];
#endif
	
	_semaphore = dispatch_semaphore_create (0);
	
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithAPIRequest:self.request];
	req.timeoutInterval = self.timeout;
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
	_connection = conn;
	
	dispatch_async (dispatch_get_main_queue (), ^{
		[conn start];
	});
	
	dispatch_semaphore_wait (_semaphore, DISPATCH_TIME_FOREVER);
	[super main];

#if __has_include (<KBAPISupport/KBAPISupport+NetworkIndicator.h>)
	[KBNetworkIndicator requestFinished];
#endif
}

- (void)cancel {
	[self.connection cancel];
	[super cancel];
}

- (void) releaseOperationSemaphore {
	dispatch_semaphore_signal (_semaphore);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	KBLOGE (@"Connection error: %@", error);
	self.error = error;
	[self releaseOperationSemaphore];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	KBLOGI (@"Connection response: %@", response);
	if (_buffer) {
		_buffer.length = 0;
	} else {
		long long const expectedContentLength = response.expectedContentLength;
		if (expectedContentLength == NSURLResponseUnknownLength) {
			_buffer = [NSMutableData new];
		} else {
			_buffer = [[NSMutableData alloc] initWithCapacity:(NSUInteger) expectedContentLength];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	KBLOGD (@"Connection received %ld bytes", (long) data.length);
	[_buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	KBLOGI (@"Connection did finish loading");
	KBLOGD (@"Response data length: %ld bytes", (long) _buffer.length);
	KBLOGD (@"Response string: %@", [[NSString alloc] initWithData:_buffer encoding:NSUTF8StringEncoding]);
	[self releaseOperationSemaphore];
}

- (id) result {
	return _buffer;
}

@end
