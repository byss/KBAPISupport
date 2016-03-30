//
//  KBOperation.m
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import "KBOperation_Protected.h"

@interface KBCompletionOperation: NSOperation

@property (nonatomic, nullable, copy) void (^operationCompletionBlock) (id _Nullable result, NSError *_Nullable error);

- (instancetype _Nullable) initWithCompletion: (void (^_Nullable) (id _Nullable result, NSError *_Nullable error)) completion NS_DESIGNATED_INITIALIZER;

@end

@interface KBOperation () {
	NSMutableArray *_suboperations;
}

@property (nonatomic, readonly, nonnull) NSOperation *completionOperation;

@end

@implementation KBOperation

@dynamic result;

- (instancetype) init {
	return [self initWithCompletion:NULL];
}

- (instancetype)initWithCompletion:(void (^)(id _Nullable, NSError * _Nullable))completion {
	if (self = [super init]) {
		_operationCompletionBlock = [completion copy];
		
		__weak typeof (self) weakSelf = self;
		_completionOperation = [NSBlockOperation blockOperationWithBlock:^{
			typeof (self) strongSelf = weakSelf;
			if (!strongSelf) {
				return;
			}
			
			void (^completionBlock) (id, NSError *) = strongSelf.operationCompletionBlock;
			if (completionBlock) {
				completionBlock (strongSelf.result, strongSelf.error);
			}
		}];
	}
	
	return self;
}

- (void) main {
	NSOperationQueue *queue = [NSOperationQueue currentQueue];
	NSArray <NSOperation *> *suboperations = self.suboperations;
	if (suboperations.count) {
		[queue addOperations:suboperations waitUntilFinished:NO];
	}
	[queue addOperations:@[self.completionOperation] waitUntilFinished:YES];
}

- (void) cancel {
	[self.completionOperation cancel];
	for (NSOperation *operation in self.suboperations) {
		[operation cancel];
	}
	[super cancel];
}

- (void)addSuboperation:(NSOperation *)operation {
	if (!_suboperations) {
		_suboperations = [NSMutableArray new];
	}
	
	[_suboperations addObject:operation];
	[self.completionOperation addDependency:operation];
}

- (NSArray <NSOperation *> *) suboperations {
	return _suboperations;
}

@end
