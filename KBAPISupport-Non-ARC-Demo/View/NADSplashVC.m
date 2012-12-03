//
//  NADSplashVC.m
//  KBAPISupport-Non-ARC-Demo
//
//  Created by Kirill byss Bystrov on 01.12.12.
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

#import "NADSplashVC.h"

#import "NADViewController.h"

#import "NADIndexRequest.h"

@implementation NADSplashVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"Loading index";
	}
	
	return self;
}

- (void) loadIndex {
	self.button.hidden = YES;
	[self.activityView startAnimating];
	self.label.text = @"Please wait...";
	KBAPIConnection *conn = [KBAPIConnection connectionWithRequest:[NADIndexRequest request] delegate:self];
#if KBAPISUPPORT_BOTH_FORMATS
	conn.responseType = KBAPIConnectionResponseTypeJSON;
#endif
	[conn start];
}

- (void) loadingFailed {
	self.button.hidden = NO;
	[self.activityView stopAnimating];
	self.label.text = @"Loading failed.";
}

- (void) viewDidAppear:(BOOL)animated {
	[self loadIndex];
}

- (void) connection:(KBAPIConnection *)connection didFailWithError:(NSError *)error {
	MLOG(@"error: %@", error);
	UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[av show];
	[self loadingFailed];
}

- (void) connection:(KBAPIConnection *)connection didReceiveJSON:(id)JSON {
	F_START
	
	MLOG(@"JSON: %@", JSON);
	if (![JSON isKindOfClass:[NSDictionary class]]) {
		[self loadingFailed];

		F_END
		return;
	}
	
	baseAddress = [[JSON objectForKey:@"base"] retain];
	if (![baseAddress isKindOfClass:[NSString class]]) {
		[self loadingFailed];
		
		F_END
		return;
	}
	
	delimiter = [[JSON objectForKey:@"delimiter"] retain];
	if (![delimiter isKindOfClass:[NSString class]]) {
		[self loadingFailed];
		
		F_END
		return;
	}
	
	NSArray *fields = @[@"types", @"formats", @"codings"];
	NSMutableArray *values = [NSMutableArray array];
	
	for (NSString *field in fields) {
		if (!([[JSON objectForKey:field] isKindOfClass:[NSArray class]] && [[JSON objectForKey:field] count])) {
			[self loadingFailed];
			
			F_END
			return;
		}
	}
	
	[values addObject:[JSON objectForKey:@"types"]];
	
	NSArray *formats = [JSON objectForKey:@"formats"];
	NSMutableArray *supportedFormats = [NSMutableArray array];
	for (NSString *format in formats) {
		if ([format isEqualToString:@"json"]) {
#if KBAPISUPPORT_JSON
			[supportedFormats addObject:format];
#endif
		} else if ([format isEqualToString:@"xml"]) {
#if KBAPISUPPORT_XML
			[supportedFormats addObject:format];
#endif
		}
	}
	[values addObject:supportedFormats];
	
	NSString *supportedCoding =
#if KBAPISUPPORT_DECODE
#	if KBAPISUPPORT_DECODE_FROM == NSWindowsCP1251StringEncoding
		@"cp1251"
#	else
		nil
#	endif
#else
		@"utf8"
#endif
	;
	if ([[JSON objectForKey:@"codings"] containsObject:supportedCoding]) {
		[values addObject:@[supportedCoding]];
	}
	
	NSArray *urls = [self assembleField:@"" withArrayIdx:0 values:values];
	MLOG(@"urls: %@", urls);
	
	NADViewController *vc = [[NADViewController alloc] init];
	vc.containsURLs = YES;
	vc.contents = urls;
	[self.navigationController setViewControllers:@[vc] animated:YES];
}

- (NSArray *) assembleField: (NSString *) field withArrayIdx: (NSUInteger) idx values: (NSArray *) values {
	NSArray *current = [values objectAtIndex:idx];
	NSUInteger count = [current count];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
	for (NSUInteger i = 0; i < count; i++) {
		[result addObject:[field stringByAppendingFormat:@"%@%@", (idx ? delimiter : @""), [current objectAtIndex:i]]];
	}
	
	if (idx < [values count] - 1) {
		NSMutableArray *full = [NSMutableArray array];
		for (NSUInteger i = 0; i < count; i++) {
			[full addObjectsFromArray:[self assembleField:[result objectAtIndex:i] withArrayIdx:idx + 1 values:values]];
		}
		return full;
	} else {
		return result;
	}
}

- (void)dealloc {
	[_label release];
	[_activityView release];
	[_button release];
	
	[super dealloc];
}

@end
