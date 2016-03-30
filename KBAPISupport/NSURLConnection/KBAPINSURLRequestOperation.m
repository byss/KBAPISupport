//
//  KBAPINSURLRequestOperation.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/30/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import "KBAPINSURLRequestOperation.h"
#import "KBAPIRequestOperation_Protected.h"

#import "NSMutableURLRequest+KBAPIRequest.h"

@interface KBAPINSURLRequestOperation () <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
	__weak NSURLConnection *_connection;
	
	dispatch_semaphore_t _semaphore;
	NSMutableData *_buffer;
}

@end

@implementation KBAPINSURLRequestOperation

- (void) main {
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
}

- (void)cancel {
	[_connection cancel];
	[super cancel];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	self.error = error;
	dispatch_semaphore_signal (_semaphore);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
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
	[_buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	dispatch_semaphore_signal (_semaphore);
}

- (id) result {
	return _buffer;
}

@end
