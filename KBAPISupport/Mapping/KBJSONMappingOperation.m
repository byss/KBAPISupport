//
//  KBJSONMappingOperation.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/30/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import "KBJSONMappingOperation.h"
#import "KBOperation_Protected.h"

#import "KBEntity.h"

@interface KBJSONMappingOperation () {
	id <KBEntity> _result;
}

@end

@implementation KBJSONMappingOperation

@dynamic operationCompletionBlock;

- (void) main {
	id JSONObject = self.JSONObject;
	if (JSONObject) {
		_result = [self.expectedClass entityFromJSON:JSONObject];

		if (!_result) {
			self.error = [self.errorClass entityFromJSON:JSONObject];
			if (!self.error) {
				self.error = [NSError errorWithDomain:@"KBAPIConnection" code:-1 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Cannot build %@ from JSON object.", self.expectedClass]}];
			}
		}
	}
	
	[super main];
}

- (id)result {
	return _result;
}

@end
