//
//  KBAPIConnection.m
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import "KBAPIConnection.h"

#import "KBAPIRequestOperation.h"

@interface KBAPIConnection ()

@property (nonatomic, readonly, nonnull) KBAPIRequest *request;
@property (nonatomic, weak) KBAPIRequestOperation *operation;

@end

static NSOperationQueue *KBAPIConnectionDefaultCallbacksQueue = nil;

@implementation KBAPIConnection

+ (void)initialize {
	if (self == [KBAPIConnection class]) {
		KBAPIConnectionDefaultCallbacksQueue = [NSOperationQueue mainQueue];
	}
}

+ (NSTimeInterval) defaultTimeout {
	return [KBAPIRequestOperation defaultTimeout];
}

+ (void) setDefaultTimeout:(NSTimeInterval) defaultTimeout {
	[KBAPIRequestOperation setDefaultTimeout:defaultTimeout];
}

+ (NSOperationQueue *) defaultCallbacksQueue {
	return KBAPIConnectionDefaultCallbacksQueue;
}

+ (void)setDefaultCallbacksQueue:(NSOperationQueue *)defaultCallbacksQueue {
	KBAPIConnectionDefaultCallbacksQueue = (defaultCallbacksQueue ?: [NSOperationQueue mainQueue]);
}

+ (NSOperationQueue *) operationQueue {
	static NSOperationQueue *operationQueue = nil;
	static dispatch_once_t onceToken;
	dispatch_once (&onceToken, ^{
		operationQueue = [NSOperationQueue new];
		operationQueue.name = @"KBAPIConnection";
	});
	
	return operationQueue;
}

+ (instancetype)connectionWithRequest:(KBAPIRequest *)request {
	return [[self alloc] initWithRequest:request];
}

- (instancetype)init {
	return [self initWithRequest:(id _Nonnull) nil];
}

- (instancetype) initWithRequest:(KBAPIRequest *)request {
	if (!request) {
		return nil;
	}
	
	if (self = [super init]) {
		_request = request;
		_timeout = [self.class defaultTimeout];
		_callbacksQueue = [self.class defaultCallbacksQueue];
	}
	
	return self;
}

- (NSOperationQueue *) callbacksQueue {
	return (_callbacksQueue ?: [self.class defaultCallbacksQueue]);
}

- (void) start {
	KBAPIRequestOperation *operation = [[KBAPIRequestOperation alloc] initWithRequest:self.request completion:NULL];
	operation.timeout = self.timeout;
	self.operation = operation;
	[[self.class operationQueue] addOperation:operation];
}

- (void) cancel {
	[self.operation cancel];
}

@end
