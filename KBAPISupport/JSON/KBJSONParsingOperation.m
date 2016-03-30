//
//  KBJSONParsingOperation.m
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import "KBJSONParsingOperation.h"

#import "KBOperation_Protected.h"

@implementation KBJSONParsingOperation

@dynamic operationCompletionBlock;
@synthesize result = _result;

- (void) main {
	NSData *JSONData = self.JSONData;
	if (JSONData) {
		NSError *JSONError = nil;
		_result = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:&JSONError];
		self.error = JSONError;
	}
	
	[super main];
}

@end
