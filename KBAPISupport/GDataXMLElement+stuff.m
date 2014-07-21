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
	if (!firstChild) {
		return nil;
	}
	
	__block NSMutableString *result = nil;
	dispatch_once_t onceToken = 0L;
	for (GDataXMLNode *node in firstChild.children) {
		NSString *nodeXMLString = node.XMLString;
		dispatch_once (&onceToken, ^{
			result = [[NSMutableString alloc] initWithCapacity:(nodeXMLString.length * firstChild.children.count)]; // fair guess
		});
		[result appendString:node.XMLString];
	}
	
	return (result ? [[NSString alloc] initWithString:result] : @"");
}

- (GDataXMLElement *) firstChildWithName: (NSString *) childName {
	return [self elementsForName:childName].firstObject;
}

- (id) objectValue {
	NSString *childName = nil;
	BOOL parseAsArray = NO;
	if (!self.attributes.count) {
		for (GDataXMLNode *node in self.children) {
			if (node.kind != GDataXMLElementKind) {
				if (node.kind == GDataXMLTextKind) {
					return node.stringValue;
				} else {
					return nil;
				}
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
		NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:self.children.count];
		for (GDataXMLElement *element in self.children) {
			id object = element.objectValue;
			if (object) {
				[result addObject:object];
			} else {
				return nil;
			}
		}
		
		return [[NSArray alloc] initWithArray:result];
	} else {
		NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:(self.attributes.count + self.children.count)];
		for (GDataXMLNode *attr in self.attributes) {
			result [attr.name] = attr.stringValue;
		}
		
		for (GDataXMLElement *element in self.children) {
			id object = element.objectValue;
			if (object) {
				result [element.name] = object;
			} else {
				return nil;
			}
		}
		
		return [[NSDictionary alloc] initWithDictionary:result];
	}
}

@end
#endif
