//
//  KBAPIConnection.m
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
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
	for (KBAPIConnectionOperationSetupHandler *handler in [self.class registeredHandlers]) {
		handler.handlerBlock (self, operation);
	}
	operation.timeout = self.timeout;
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
