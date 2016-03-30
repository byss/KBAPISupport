//
//  KBAPIConnection+JSON.m
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import "KBAPIConnection_Protected.h"

#import "KBAPIRequestOperation.h"
#import "KBJSONParsingOperation.h"

@interface KBAPIConnection (JSON)

@end

@implementation KBAPIConnection (JSON)

+ (void)load {
	[self registerOperationSetupHandlerWithPriority:200 handlerBlock:^(KBAPIConnection * _Nonnull connection, KBAPIRequestOperation * _Nonnull operation) {
		[self addJSONParsingOperationForOperation:operation];
	}];
}

+ (void) addJSONParsingOperationForOperation: (KBAPIRequestOperation *) operation {
	KBJSONParsingOperation *parsingOperation = [KBJSONParsingOperation new];
	__weak typeof (parsingOperation) weakParsingOperation = parsingOperation;
	for (KBAPIRequestOperation *suboperation in operation.suboperations) {
		if ([suboperation isKindOfClass:[KBAPIRequestOperation class]]) {
			void (^suboperationCompletion) (NSData *_Nullable, NSError *_Nullable) = suboperation.operationCompletionBlock;
			if (suboperationCompletion) {
				suboperation.operationCompletionBlock = ^(NSData *_Nullable data, NSError *_Nullable error) {
					weakParsingOperation.JSONData = data;
					suboperationCompletion (data, error);
				};
			} else {
				suboperation.operationCompletionBlock = ^(NSData *_Nullable data, NSError *_Nullable error) {
					weakParsingOperation.JSONData = data;
				};
			}
			[parsingOperation addDependency:suboperation];
			break;
		}
	}
}

@end
