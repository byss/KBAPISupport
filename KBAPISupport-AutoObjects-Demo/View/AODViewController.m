//
//  AODViewController.m
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

#import "AODViewController.h"

#import "AODRequest.h"
#import "AODMain.h"
#import "AODDummy.h"
#import "AODDummyList.h"

#import "KBAPISupport-debug.h"

@implementation AODViewController

- (void)dealloc {
	[_field1Status release];
	[_field2Status release];
	[_field3Status release];
	[_field4Status release];
	[_field5Status release];
	
	[_field4ObjFieldStatus release];
	
	[_field5Obj0Status release];
	[_field5Obj1Status release];
	[_field5Obj2Status release];
	
	[_field5Obj0FieldStatus release];
	[_field5Obj1FieldStatus release];
	[_field5Obj2FieldStatus release];
	
	[_activityView release];
	[super dealloc];
}

- (IBAction)loadObject:(id)sender {
	[[KBAPIConnection connectionWithRequest:[AODRequest request] delegate:self] start];
	[self.activityView startAnimating];
}

- (void) apiConnection:(KBAPIConnection *)connection didFailWithError:(NSError *)error {
	KBAPISUPPORT_LOG (@"error: %@", error);
	UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[av show];
	[self.activityView stopAnimating];
}

- (void) updateLabel: (UILabel *) label withResult: (BOOL) result {
	if (result) {
		label.textColor = [UIColor greenColor];
		label.text = @"OK";
	} else {
		label.textColor = [UIColor redColor];
		label.text = @"FAIL";
	}
}

- (void) apiConnection:(KBAPIConnection *)connection didReceiveResponse:(id<KBEntity>)response {
	[self.activityView stopAnimating];
	if ([response isKindOfClass:[AODMain class]]) {
		AODMain *main = response;
#if SWAP_FIELD1_AND_FIELD2
		[self updateLabel:self.field1Status withResult:[@"1" isEqual:main.field1]];
		[self updateLabel:self.field2Status withResult:(main.field2 == 2)];
#else
		[self updateLabel:self.field1Status withResult:(main.field1 == 1)];
		[self updateLabel:self.field2Status withResult:[@"2" isEqual:main.field2]];
#endif
		[self updateLabel:self.field3Status withResult:(main.field3 == 42)];
		
		BOOL ok = [main.field4 isKindOfClass:[AODDummy class]];
		if (ok) {
			AODDummy *dummy = main.field4;
			BOOL fieldOK = [@"value" isEqual:dummy.field];
			[self updateLabel:self.field4ObjFieldStatus withResult:fieldOK];
			ok &= fieldOK;
		} else {
			[self updateLabel:self.field4ObjFieldStatus withResult:NO];
		}
		[self updateLabel:self.field4Status withResult:ok];
		
		ok = ([main.field5 isKindOfClass:[AODDummyList class]] && ([main.field5 count] == 3));
		if (ok) {
			AODDummy *dummy = [main.field5 entityForIndex:0];
			BOOL objectOK = [dummy isKindOfClass:[AODDummy class]];
			if (objectOK) {
				BOOL fieldOK = [@"value0" isEqual:dummy.field];
				[self updateLabel:self.field5Obj0FieldStatus withResult:fieldOK];
				objectOK &= fieldOK;
			} else {
				[self updateLabel:self.field5Obj0FieldStatus withResult:NO];
			}
			[self updateLabel:self.field5Obj0Status withResult:objectOK];
			ok &= objectOK;

			dummy = [main.field5 entityForIndex:1];
			objectOK = [dummy isKindOfClass:[AODDummy class]];
			if (objectOK) {
				BOOL fieldOK = [@"value1" isEqual:dummy.field];
				[self updateLabel:self.field5Obj1FieldStatus withResult:fieldOK];
				objectOK &= fieldOK;
			} else {
				[self updateLabel:self.field5Obj1FieldStatus withResult:NO];
			}
			[self updateLabel:self.field5Obj1Status withResult:objectOK];
			ok &= objectOK;

			dummy = [main.field5 entityForIndex:2];
			objectOK = [dummy isKindOfClass:[AODDummy class]];
			if (objectOK) {
				BOOL fieldOK = [@"value2" isEqual:dummy.field];
				[self updateLabel:self.field5Obj2FieldStatus withResult:fieldOK];
				objectOK &= fieldOK;
			} else {
				[self updateLabel:self.field5Obj2FieldStatus withResult:NO];
			}
			[self updateLabel:self.field5Obj2Status withResult:objectOK];
			ok &= objectOK;
		} else {
			[self updateLabel:self.field5Obj0FieldStatus withResult:NO];
			[self updateLabel:self.field5Obj1FieldStatus withResult:NO];
			[self updateLabel:self.field5Obj2FieldStatus withResult:NO];
			[self updateLabel:self.field5Obj0Status withResult:NO];
			[self updateLabel:self.field5Obj1Status withResult:NO];
			[self updateLabel:self.field5Obj2Status withResult:NO];
		}
		[self updateLabel:self.field5Status withResult:ok];
	} else {
		UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Total fail." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[av show];
	}
}

@end
