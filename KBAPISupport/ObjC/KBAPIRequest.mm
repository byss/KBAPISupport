//
//  KBAPIRequest.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/19/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

#import "KBAPIRequest.h"

KBAPIRequestHTTPMethod const KBAPIRequestHTTPMethodHEAD = @"HEAD";
KBAPIRequestHTTPMethod const KBAPIRequestHTTPMethodGET = @"GET";
KBAPIRequestHTTPMethod const KBAPIRequestHTTPMethodPOST = @"POST";
KBAPIRequestHTTPMethod const KBAPIRequestHTTPMethodPUT = @"PUT";
KBAPIRequestHTTPMethod const KBAPIRequestHTTPMethodPATCH = @"PATCH";
KBAPIRequestHTTPMethod const KBAPIRequestHTTPMethodDELETE = @"DELETE";

static NSURL *const NSURLNone = [[NSURL alloc] initWithString:@""];

@implementation KBAPIRequest

- (KBAPIRequestHTTPMethod) HTTPMethod {
	return KBAPIRequestHTTPMethodGET;
}

- (NSDictionary <NSString *, NSString *> *) HTTPHeaders {
	return @{};
}

- (NSURL *) baseURL {
	return NSURLNone;
}

- (NSString *) path {
	return @"";
}

- (NSURL *) URL {
	return (NSURL *) [[NSURL alloc] initWithString:self.path relativeToURL:self.baseURL];
}

- (NSDictionary <NSString *, id> *) parameters {
	return @{};
}

@end
