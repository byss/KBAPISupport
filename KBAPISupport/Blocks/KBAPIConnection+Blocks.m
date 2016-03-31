//
//  KBAPIConnection+Blocks.m
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

#import "KBAPIConnection+Blocks.h"
#import "KBAPIConnection_Protected.h"

#import <objc/runtime.h>

#import "KBAPIRequestOperation.h"
#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
#	import "KBJSONParsingOperation.h"
#endif
#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
#	import "KBXMLParsingOperation.h"
#endif
#if __has_include (<KBAPISupport/KBAPISupport+Mapping.h>)
#	import "KBMappingOperation.h"
#endif

@interface KBAPIConnection (BlocksStorage)

@property (nonatomic, copy, nullable) void (^rawDataCompletion) (NSData *_Nullable data, NSError *_Nullable error);

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
@property (nonatomic, copy, nullable) void (^rawObjectCompletion) (id _Nullable JSONResponse, NSError *_Nullable error);
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
@property (nonatomic, copy, nullable) void (^rawObjectCompletion) (GDataXMLDocument *_Nullable XMLResponse, NSError *_Nullable error);
#endif

#if __has_include (<KBAPISupport/KBAPISupport+Mapping.h>)
@property (nonatomic, copy, nullable) void (^objectCompletion) (id <KBEntity> _Nullable responseObject, NSError *_Nullable error);
#endif

@end

@implementation KBAPIConnection (Blocks)

+ (void) load {
	[self registerOperationSetupHandlerWithPriority:400 handlerBlock:^(KBAPIConnection * _Nonnull connection, KBAPIRequestOperation * _Nonnull operation) {
		[self setupCompletionBlocksForOperation:operation usingConnection:connection];
	}];
}

+ (void) setupCompletionBlocksForOperation: (KBAPIRequestOperation *) operation usingConnection: (KBAPIConnection *) connection {
#if __has_include (<KBAPISupport/KBAPISupport+Mapping.h>)
	if (connection.objectCompletion) {
		void (^connectionCompletion) (id <KBEntity> _Nullable, NSError *_Nullable) = connection.objectCompletion;
		connection.objectCompletion = NULL;
#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>) || __has_include (<KBAPISupport/KBAPISupport+XML.h>)
		for (KBMappingOperation *suboperation in operation.suboperations) {
			if ([suboperation isKindOfClass:[KBMappingOperation class]]) {
				void (^mappingCompletion) (id <KBEntity> _Nullable, NSError *_Nullable) = suboperation.operationCompletionBlock;
				suboperation.operationCompletionBlock = ^(id <KBEntity> _Nullable responseObject, NSError *_Nullable error) {
					if (mappingCompletion) {
						mappingCompletion (responseObject, error);
					}
					
					connectionCompletion (responseObject, error);
				};
			}
		}
#endif
		
		return;
	}
#endif
	
#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
	if (connection.rawObjectCompletion) {
		void (^connectionCompletion) (id _Nullable, NSError *_Nullable) = connection.rawObjectCompletion;
		connection.rawObjectCompletion = NULL;
		
#if __has_include (<KBAPISupport/KBAPISupport+Mapping.h>)
		NSMutableArray <KBMappingOperation *> *mappingOperations = [NSMutableArray new];
		for (KBMappingOperation *mappingOperation in operation.suboperations) {
			if ([mappingOperation isKindOfClass:[KBMappingOperation class]]) {
				[mappingOperations addObject:mappingOperation];
			}
		}
		for (KBOperation *mappingOperation in mappingOperations) {
			[operation removeSuboperation:mappingOperation];
		}
		mappingOperations = nil;
#endif
		
		for (KBJSONParsingOperation *parsingOperation in operation.suboperations) {
			if ([parsingOperation isKindOfClass:[KBJSONParsingOperation class]]) {
				void (^parsingCompletion) (id _Nullable, NSError *_Nullable) = parsingOperation.operationCompletionBlock;
				parsingOperation.operationCompletionBlock = ^(id _Nullable JSONObject, NSError *_Nullable error) {
					if (parsingCompletion) {
						parsingCompletion (JSONObject, error);
					}
					
					connectionCompletion (JSONObject, error);
				};
			}
		}
		
		return;
	}
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
	// TODO
#endif
	
	if (connection.rawDataCompletion) {
		void (^connectionCompletion) (NSData *_Nullable, NSError *_Nullable) = connection.rawDataCompletion;
		connection.rawDataCompletion = NULL;
		
#if __has_include (<KBAPISupport/KBAPISupport+Mapping.h>) || __has_include (<KBAPISupport/KBAPISupport+JSON.h>) || __has_include (<KBAPISupport/KBAPISupport+XML.h>)
		NSMutableArray <KBOperation *> *mappingAndParsingOperations = [NSMutableArray new];
		for (KBOperation *suboperation in operation.suboperations) {
#if __has_include (<KBAPISupport/KBAPISupport+Mapping.h>)
			if ([suboperation isKindOfClass:[KBMappingOperation class]]) {
				[mappingAndParsingOperations addObject:suboperation];
			}
#endif
#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
			if ([suboperation isKindOfClass:[KBJSONParsingOperation class]]) {
				[mappingAndParsingOperations addObject:suboperation];
			}
#endif
#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
			if ([operation isKindOfClass:[KBXMLParsingOperation class]]) {
				[mappingAndParsingOperations addObject:operation];
			}
#endif
		}
		
		for (KBOperation *suboperation in mappingAndParsingOperations) {
			[operation removeSuboperation:suboperation];
		}
		mappingAndParsingOperations = nil;
#endif
		
		for (KBAPIRequestOperation *requestOperation in operation.suboperations) {
			if ([requestOperation isKindOfClass:[KBAPIRequestOperation class]]) {
				void (^operationCompletion) (NSData *_Nullable, NSError *_Nullable) = requestOperation.operationCompletionBlock;
				requestOperation.operationCompletionBlock = ^(NSData *_Nullable responseData, NSError *_Nullable error) {
					if (operationCompletion) {
						operationCompletion (responseData, error);
					}
					
					connectionCompletion (responseData, error);
				};
			}
		}
	}
}

- (KBOperation *) startWithRawDataCompletion:(void (^)(NSData * _Nullable, NSError * _Nullable))completion {
	if (completion) {
		__weak typeof (self) weakSelf = self;
		self.rawDataCompletion = ^(NSData * _Nullable data, NSError * _Nullable error) {
			[weakSelf.callbacksQueue addOperationWithBlock:^{
				completion (data, error);
			}];
		};
	}
	return [self start];
}

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
- (KBOperation *) startWithRawObjectCompletion:(void (^)(id _Nullable, NSError * _Nullable))completion {
	if (completion) {
		__weak typeof (self) weakSelf = self;
		self.rawObjectCompletion = ^(id _Nullable JSONObject, NSError * _Nullable error) {
			[weakSelf.callbacksQueue addOperationWithBlock:^{
				completion (JSONObject, error);
			}];
		};
	}
	return [self start];
}
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
- (KBOperation *) startWithRawObjectCompletion:(void (^)(GDataXMLDocument *_Nullable, NSError * _Nullable))completion {
	if (completion) {
		__weak typeof (self) weakSelf = self;
		self.rawObjectCompletion = ^(GDataXMLDocument *_Nullable XMLObject, NSError * _Nullable error) {
			[weakSelf.callbacksQueue addOperationWithBlock:^{
				completion (XMLObject, error);
			}];
		};
	}
	return [self start];
}
#endif

#if __has_include (<KBAPISupport/KBAPISupport+Mapping.h>)
- (KBOperation *) startWithCompletion:(void (^)(id<KBEntity> _Nullable, NSError * _Nullable))completion {
	if (completion) {
		__weak typeof (self) weakSelf = self;
		self.rawObjectCompletion = ^(id <KBEntity> _Nullable responseObject, NSError * _Nullable error) {
			[weakSelf.callbacksQueue addOperationWithBlock:^{
				completion (responseObject, error);
			}];
		};
	}
	return [self start];
}
#endif

@end

@implementation KBAPIConnection (BlocksStorage)

- (void (^)(NSData * _Nullable, NSError * _Nullable))rawDataCompletion {
	return objc_getAssociatedObject (self, @selector (rawDataCompletion));
}

- (void)setRawDataCompletion:(void (^)(NSData * _Nullable, NSError * _Nullable))rawDataCompletion {
	objc_setAssociatedObject (self, @selector (rawDataCompletion), rawDataCompletion, OBJC_ASSOCIATION_COPY);
}

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
- (void (^)(id _Nullable, NSError * _Nullable))rawObjectCompletion {
	return objc_getAssociatedObject (self, @selector (rawObjectCompletion));
}

- (void)setRawObjectCompletion:(void (^)(id _Nullable, NSError * _Nullable))rawObjectCompletion {
	objc_setAssociatedObject (self, @selector (rawObjectCompletion), rawObjectCompletion, OBJC_ASSOCIATION_COPY);
}
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
- (void (^)(GDataXMLDocument *_Nullable XMLResponse, NSError * _Nullable))rawObjectCompletion {
	return objc_getAssociatedObject (self, @selector (rawObjectCompletion));
}

- (void)setRawObjectCompletion:(void (^)(GDataXMLDocument *_Nullable, NSError * _Nullable))rawObjectCompletion {
	objc_setAssociatedObject (self, @selector (rawObjectCompletion), rawObjectCompletion, OBJC_ASSOCIATION_COPY);
}
#endif

#if __has_include (<KBAPISupport/KBAPISupport+Mapping.h>)
- (void (^)(id<KBEntity> _Nullable, NSError * _Nullable))objectCompletion {
	return objc_getAssociatedObject (self, @selector (objectCompletion));
}

- (void)setObjectCompletion:(void (^)(id<KBEntity> _Nullable, NSError * _Nullable))objectCompletion {
	objc_setAssociatedObject (self, @selector (objectCompletion), objectCompletion, OBJC_ASSOCIATION_COPY);
}
#endif

@end
