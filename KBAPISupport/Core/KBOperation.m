//
//  KBOperation.m
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
	
	if (self.error) {
		NSArray <NSOperation *> *completionDependencies = self.completionOperation.dependencies;
		for (NSOperation *operation in completionDependencies) {
			[self.completionOperation removeDependency:operation];
		}
	} else {
		NSArray <NSOperation *> *suboperations = self.suboperations;
		if (suboperations.count) {
			[queue addOperations:suboperations waitUntilFinished:NO];
		}
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

- (void)removeSuboperation:(NSOperation *)operation {
	[self.completionOperation removeDependency:operation];
	[_suboperations removeObject:operation];
}

- (NSArray <NSOperation *> *) suboperations {
	return _suboperations;
}

- (void) setError: (NSError *_Nonnull) error {
	if (error) {
		_error = error;
	}
}

@end
