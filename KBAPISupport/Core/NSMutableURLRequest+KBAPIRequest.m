//
//  NSMutableURLRequest+KBAPIRequest.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/29/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import "NSMutableURLRequest+KBAPIRequest.h"

#import "KBAPIRequest.h"

@implementation NSMutableURLRequest (KBAPIRequest)

- (instancetype)initWithAPIRequest:(KBAPIRequest *)request {
	NSURL *url = request.URL;
	if (!url) {
		return nil;
	}
	
	if (self = [self initWithURL:url]) {
		self.HTTPMethod = request.HTTPMethod;
		self.HTTPBody = request.bodyData;
		for (NSString *header in request.additionalHeaders) {
			[self setValue:request.additionalHeaders [header] forHTTPHeaderField:header];
		}
	}
	
	return self;
}

@end
