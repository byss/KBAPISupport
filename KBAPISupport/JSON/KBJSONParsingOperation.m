//
//  KBJSONParsingOperation.m
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

#import "KBJSONParsingOperation.h"

#import "KBOperation_Protected.h"
#import "KBAPISupportLogging_Protected.h"

@implementation KBJSONParsingOperation

@dynamic operationCompletionBlock;
@synthesize result = _result;

- (void) main {
	[self parseJSONData];
	[super main];
}

- (void) parseJSONData {
	if (self.error) {
		return;
	}
	
	NSData *JSONData = self.JSONData;
	if (!JSONData.length) {
		self.error = [[NSError alloc] initWithDomain:@"KBAPIConnection" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"No data received"}];
		return;
	}
	
	KBASLOGI (@"Deserializing data (%ld bytes)", (long) JSONData.length);
	NSError *JSONError = nil;
	_result = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:&JSONError];
	if (JSONError) {
		KBASLOGE (@"Deserialization error: %@", JSONError);
		self.error = JSONError;
		return;
	}
	
	KBASLOGI (@"Deserialization success");
	KBASLOGD (@"Deserialized object: %@", _result);
}

@end
