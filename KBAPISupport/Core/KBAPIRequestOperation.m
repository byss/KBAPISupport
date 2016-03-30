//
//  KBAPIRequestOperation.m
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import "KBAPIRequestOperation_Protected.h"

#import "KBOperation_Protected.h"

static NSTimeInterval KBAPIRequestOperationDefaultTimeout = 30.0;

@implementation KBAPIRequestOperation

@dynamic operationCompletionBlock;

+ (NSTimeInterval)defaultTimeout {
	return KBAPIRequestOperationDefaultTimeout;
}

+ (void)setDefaultTimeout:(NSTimeInterval)defaultTimeout {
	KBAPIRequestOperationDefaultTimeout = defaultTimeout;
}

- (instancetype)initWithCompletion:(void (^)(id _Nullable, NSError * _Nullable))completion {
	return [self initWithRequest:(id _Nonnull) nil completion:completion];
}

- (instancetype)initWithRequest:(KBAPIRequest *)request completion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
	if (!request) {
		return nil;
	}
	
	if (self = [super initWithCompletion:completion]) {
		_request = request;
		_timeout = [self.class defaultTimeout];
	}
	
	return self;
}

@end
