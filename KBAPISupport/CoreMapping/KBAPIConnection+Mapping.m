//
//  KBAPIConnection+Mapping.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/29/16.
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

#import "KBAPIConnection+Mapping.h"
#import "KBAPIConnection_Protected.h"

#import <objc/runtime.h>

#import "KBAPIRequest+Mapping.h"
#import "KBAPIRequestOperation.h"
#import "KBXMLMappingOperation.h"
#import "KBJSONMappingOperation.h"
#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
#	import "KBJSONParsingOperation.h"
#endif
#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
#	import "KBXMLParsingOperation.h"
#endif

static id KBAPIConnectionDefaultMappingContext = nil;

@implementation KBAPIConnection (Mapping)

+ (void)load {
	[self registerOperationSetupHandlerWithPriority:300 handlerBlock:^(KBAPIConnection * _Nonnull connection, KBAPIRequestOperation * _Nonnull operation) {
		[self addMappingOperationsToOperation:operation forConnection:connection];
	}];
}

+ (void) addMappingOperationsToOperation: (KBAPIRequestOperation *) operation forConnection: (KBAPIConnection *) connection {
#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
	KBJSONMappingOperation *jsonMappingOperation = [KBJSONMappingOperation new];
	jsonMappingOperation.expectedClass = [connection.request.class expectedObjectClass];
	jsonMappingOperation.errorClass = [connection.request.class errorClass];
	__weak typeof (jsonMappingOperation) weakJSONMappingOperation = jsonMappingOperation;
#endif
#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
	KBXMLMappingOperation *xmlMappingOperation = [KBXMLMappingOperation new];
#endif
	
#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>) || __has_include (<KBAPISupport/KBAPISupport+XML.h>)
	for (KBOperation *suboperation in operation.suboperations) {
#	if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
		if ([suboperation isKindOfClass:[KBJSONParsingOperation class]]) {
			KBJSONParsingOperation *jsonParsingOperation = (KBJSONParsingOperation *) suboperation;
			void (^suboperationCompletion) (id _Nullable, NSError *_Nullable) = jsonParsingOperation.operationCompletionBlock;
			suboperation.operationCompletionBlock = ^(id _Nullable parsedObject, NSError *_Nullable error) {
				if (suboperationCompletion) {
					suboperationCompletion (parsedObject, error);
				}
				
				typeof (jsonMappingOperation) strongJSONMappingOperation = weakJSONMappingOperation;
				strongJSONMappingOperation.JSONObject = parsedObject;
				strongJSONMappingOperation.mappingContext = connection.mappingContext;
				if (error) {
					[strongJSONMappingOperation setError:(NSError *) error];
				}
			};
			[operation addSuboperation:jsonMappingOperation];
			[jsonMappingOperation addDependency:jsonParsingOperation];
		}
#	endif
#	if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
		// TODO
#	endif
	}
#endif
}

+ (id) defaultMappingContext {
	return KBAPIConnectionDefaultMappingContext;
}

+ (void) setDefaultMappingContext: (id) defaultMappingContext {
	KBAPIConnectionDefaultMappingContext = defaultMappingContext;
}

- (id) mappingContext {
	id mappingContext = objc_getAssociatedObject (self, @selector (mappingContext));
	if (mappingContext) {
		return mappingContext;
	}
	
	return self.class.defaultMappingContext;
}

- (void) setMappingContext: (id) mappingContext {
	objc_setAssociatedObject (self, @selector (mappingContext), mappingContext, OBJC_ASSOCIATION_RETAIN);
}

@end
