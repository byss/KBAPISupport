//
//  KBOperation.m
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import "KBOperation_Protected.h"

@implementation KBOperation

@dynamic suboperations;

- (instancetype) init {
	return [self initWithCompletion:NULL];
}

- (instancetype)initWithCompletion:(void (^)(id _Nullable, NSError * _Nullable))completion {
	if (self = [super init]) {
		__weak typeof (self) weakSelf = self;
		_completionOperation = [NSBlockOperation blockOperationWithBlock:^{
			typeof (self) strongSelf = weakSelf;
			if (!strongSelf) {
				return;
			}
			
			if (completion) {
				completion (strongSelf.result, strongSelf.error);
			}
		}];
		[self.completionOperation addDependency:self];
	}
	
	return self;
}

- (void) main {
	NSOperationQueue *queue = [NSOperationQueue currentQueue];
	NSArray <NSOperation *> *suboperations = self.suboperations;
	if (suboperations.count) {
		[queue addOperations:suboperations waitUntilFinished:NO];
	}
	[queue addOperation:self.completionOperation];
}

- (void) cancel {
	[self.completionOperation cancel];
	for (NSOperation *operation in self.suboperations) {
		[operation cancel];
	}
	[super cancel];
}

@end
