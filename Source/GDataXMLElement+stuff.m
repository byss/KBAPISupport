//
//  GDataXMLElement+stuff.m
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 28.11.12.
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

#import "GDataXMLElement+stuff.h"

#if KBAPISUPPORT_XML

@implementation GDataXMLElement (stuff)

- (NSString *) childStringValue: (NSString *) childName {
	GDataXMLElement *firstChild = [self firstChildWithName:childName];
	if (firstChild) {
		return firstChild.stringValue;
	} else {
		return nil;
	}
}

- (GDataXMLElement *) firstChildWithName: (NSString *) childName {
	NSArray *children = [self elementsForName:childName];
	if ([children count]) {
		GDataXMLElement *child = [children objectAtIndex:0];
		return child;
	} else {
		return nil;
	}
}

- (id) objectValue {
	NSString *childName = nil;
	BOOL parseAsArray = NO;
	if (!self.attributes.count) {
		for (GDataXMLNode *node in self.children) {
			if (node.kind != GDataXMLElementKind) {
				NSString *result = nil;
				if (node.kind == GDataXMLTextKind) {
					result = node.stringValue;
				}

				return result;
			}
			GDataXMLElement *element = (GDataXMLElement *) node;
			if (childName) {
				if ([childName isEqualToString:element.name]) {
					parseAsArray = YES;
				} else {
					parseAsArray = NO;
					break;
				}
			} else {
				childName = element.name;
			}
		}
	}
	
	if (parseAsArray) {
		NSMutableArray *result = [NSMutableArray array];
		for (GDataXMLElement *element in self.children) {
			id object = [element objectValue];
			if (object) {
				[result addObject:object];
			} else {
				return nil;
			}
		}
		
		return [NSArray arrayWithArray:result];
	} else {
		NSMutableDictionary *result = [NSMutableDictionary dictionary];
		for (GDataXMLNode *attr in self.attributes) {
			[result setObject:attr.stringValue forKey:attr.name];
		}
		for (GDataXMLElement *element in self.children) {
			id object = [element objectValue];
			if (object) {
				[result setObject:object forKey:element.name];
			} else {
				return nil;
			}
		}
		
		return [NSDictionary dictionaryWithDictionary:result];
	}
}

@end
#endif
