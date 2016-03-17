//
//  KBAPIRequest.m
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import "KBAPIRequest.h"

@implementation KBAPIRequest

@dynamic URLString;

- (NSURL *) URL {
	NSString *URLString = self.URLString;
	return (URLString ? [[NSURL alloc] initWithString:URLString] : nil);
}

- (KBAPIRequestMethod) HTTPMethodType {
	return KBAPIRequestMethodGET;
}

- (NSString *) HTTPMethod {
	switch (self.HTTPMethodType) {
	  case KBAPIRequestMethodGET:
			return @"GET";
		case KBAPIRequestMethodPOST:
			return @"POST";
		case KBAPIRequestMethodPUT:
			return @"PUT";
		case KBAPIRequestMethodDELETE:
			return @"DELETE";
	  default:
			return @"GET"; // well, we need _some_ default
	}
}

- (NSString *) bodyString {
	return nil;
}

- (NSData *) bodyData {
	return [self.bodyString dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary *) additionalHeaders {
	return nil;
}

@end
