//
//  KBAPISessionConnection.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/31/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import "KBAPISessionConnection.h"
#import "KBAPIConnection_Protected.h"

#import "KBAPISessionRequestOperation.h"

#if !__has_include (<KBAPISupport/KBAPISupport+NSURLConnection.h>)
@interface KBAPIConnection (NSURLSessionOnly)
@end

@implementation KBAPIConnection (NSURLSessionOnly)

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
	if (self == [KBAPIConnection class]) {
		return [KBAPISessionConnection allocWithZone:zone];
	} else {
		return [super allocWithZone:zone];
	}
}

@end
#endif

@implementation KBAPISessionConnection

+ (NSURLSession *_Nonnull) defaultSession {
	return [KBAPISessionRequestOperation defaultSession];
}

+ (void) setDefaultSession: (NSURLSession *_Nullable) session {
	[KBAPISessionRequestOperation setDefaultSession:session];
}

- (instancetype)initWithRequest:(KBAPIRequest *)request {
	return [self initWithRequest:request session:nil];
}

- (instancetype _Nullable) initWithRequest: (KBAPIRequest *_Nonnull) request session: (NSURLSession *_Nullable) session {
	if (self = [super initWithRequest:request]) {
		_session = session;
	}
	
	return self;
}

- (KBAPIRequestOperation *)createRequestOperationWithRequest:(KBAPIRequest *)request {
	KBAPIRequestOperation *result = [super createRequestOperationWithRequest:request];
	
	KBAPIRequestOperation *sessionRequestOperation = [[KBAPISessionRequestOperation alloc] initWithRequest:request session:self.session completion:NULL];
	sessionRequestOperation.timeout = result.timeout;
	[result addSuboperation:sessionRequestOperation];
	
	return result;
}

@end
