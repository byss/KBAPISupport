//
//  KBAPINSURLConnection.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/30/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import "KBAPINSURLConnection.h"
#import "KBAPIConnection_Protected.h"

#import "KBAPINSURLRequestOperation.h"

#if !__has_include (<KBAPISupport/KBAPISupport+NSURLSession.h>)
@interface KBAPIConnection (NSURLConnectionOnly)
@end

@implementation KBAPIConnection (NSURLConnectionOnly)

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
	return [KBAPINSURLConnection allocWithZone:zone];
}

@end
#endif

@implementation KBAPINSURLConnection

- (KBAPIRequestOperation *)createRequestOperationWithRequest:(KBAPIRequest *)request {
	KBAPIRequestOperation *result = [super createRequestOperationWithRequest:request];
	
	KBAPIRequestOperation *urlRequestOperation = [[KBAPINSURLRequestOperation alloc] initWithRequest:request completion:NULL];
	urlRequestOperation.timeout = self.timeout;
	[result addSuboperation:urlRequestOperation];
	
	return result;
}

@end
