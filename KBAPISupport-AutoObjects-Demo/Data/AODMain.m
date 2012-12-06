//
//  AODMain.m
//  KBAPISupport-AutoObjects-Demo
//
//  Created by Kirill byss Bystrov on 06.12.12.
//  Copyright (c) 2012 Kirill byss Bystrov. All rights reserved.
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

#import "AODMain.h"

#import "AODDummy.h"
#import "AODDummyList.h"

static NSArray *_autoFields = nil;

@implementation AODMain

+ (void) initialize {
#if SWAP_FIELD1_AND_FIELD2
	KBAutoStringField *field1 = [[KBAutoStringField alloc] init];
	KBAutoIntegerField *field2 = [[KBAutoIntegerField alloc] init];
#else
	KBAutoIntegerField *field1 = [[KBAutoIntegerField alloc] init];
	KBAutoStringField *field2 = [[KBAutoStringField alloc] init];
#endif
	field1.fieldName = @"field1";
	field2.fieldName = @"field2";
	
	KBAutoIntegerField *field3 = [[KBAutoIntegerField alloc] init];
	field3.fieldName = @"field3";
	field3.sourceFieldName = @"field_three";
	
	KBAutoObjectField *field4 = [[KBAutoObjectField alloc] init];
	field4.fieldName = @"field4";
	field4.objectClass = [AODDummy class];
	
	KBAutoObjectField *field5 = [[KBAutoObjectField alloc] init];
	field5.fieldName = @"field5";
	field5.objectClass = [AODDummyList class];
	
	_autoFields = [@[field1, field2, field3, field4, field5] retain];
	for (id field in _autoFields) {
		[field release];
	}
}

+ (NSArray *) autoFields {
	return _autoFields;
}

- (void) dealloc {
#if SWAP_FIELD1_AND_FIELD2
	[_field1 release];
#else
	[_field2 release];
#endif
	
	[_field4 release];
	[_field5 release];
	
	[super dealloc];
}

@end
