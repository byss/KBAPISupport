//
//  KBAPIConnection.m
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
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

#import "KBAPIConnection_Protected.h"

#import "KBAPIRequestOperation.h"

static NSOperationQueue *KBAPIConnectionDefaultCallbacksQueue = nil;

@interface KBAPIConnection ()

@property (nonatomic, weak, nullable) KBAPIRequestOperation *operation;

@end

@interface KBAPIConnectionOperationSetupHandler: NSObject

@property (nonatomic, readonly) NSUInteger priority;
@property (nonatomic, nonnull, readonly) void (^handlerBlock) (KBAPIConnection * _Nonnull, KBAPIRequestOperation * _Nonnull);

- (instancetype) initWithPriority: (NSUInteger) priority handlerBlock: (void (^) (KBAPIConnection * _Nonnull, KBAPIRequestOperation * _Nonnull)) handlerBlock NS_DESIGNATED_INITIALIZER;

@end

@implementation KBAPIConnection

+ (void)initialize {
	if (self == [KBAPIConnection class]) {
		KBAPIConnectionDefaultCallbacksQueue = [NSOperationQueue mainQueue];
	}
}

+ (NSMutableArray <KBAPIConnectionOperationSetupHandler *> *) registeredHandlers {
	static NSMutableArray <KBAPIConnectionOperationSetupHandler *> *registeredHandlers = nil;
	static dispatch_once_t onceToken;
	dispatch_once (&onceToken, ^{
		registeredHandlers = [NSMutableArray new];
	});
	
	return registeredHandlers;
}

+ (void)registerOperationSetupHandlerWithPriority:(NSUInteger)priority handlerBlock:(void (^)(KBAPIConnection * _Nonnull, KBAPIRequestOperation * _Nonnull))handlerBlock {
	KBAPIConnectionOperationSetupHandler *handler = [[KBAPIConnectionOperationSetupHandler alloc] initWithPriority:priority handlerBlock:handlerBlock];
	if (handler) {
		[[self registeredHandlers] addObject:handler];
		[[self registeredHandlers] sortUsingComparator:^NSComparisonResult (KBAPIConnectionOperationSetupHandler *handler1, KBAPIConnectionOperationSetupHandler *handler2) {
			if (handler1.priority > handler2.priority) {
				return NSOrderedDescending;
			} else if (handler1.priority > handler2.priority) {
				return NSOrderedDescending;
			} else {
				return NSOrderedSame;
			}
		}];
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
		if ([operationQueue respondsToSelector:@selector (setQualityOfService:)]) {
			operationQueue.qualityOfService = NSQualityOfServiceUtility;
		}
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

- (KBOperation *) start {
	KBAPIRequestOperation *operation = [self createRequestOperationWithRequest:self.request];
	operation.timeout = self.timeout;
	for (KBAPIConnectionOperationSetupHandler *handler in [self.class registeredHandlers]) {
		handler.handlerBlock (self, operation);
	}
	self.operation = operation;
	[[self.class operationQueue] addOperation:operation];
	return operation;
}

- (KBAPIRequestOperation *)createRequestOperationWithRequest:(KBAPIRequest *)request {
	return [[KBAPIRequestOperation alloc] initWithRequest:request completion:NULL];
}

- (void) cancel {
	[self.operation cancel];
}

@end

@implementation KBAPIConnectionOperationSetupHandler

- (instancetype)init {
	return [self initWithPriority:0 handlerBlock:NULL];
}

- (instancetype)initWithPriority:(NSUInteger)priority handlerBlock:(void (^)(KBAPIConnection * _Nonnull, KBAPIRequestOperation * _Nonnull))handlerBlock {
	if (!handlerBlock) {
		return nil;
	}
	
	if (self = [super init]) {
		_priority = priority;
		_handlerBlock = [handlerBlock copy];
	}
	
	return self;
}

@end
