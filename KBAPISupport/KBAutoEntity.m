//
//  KBAutoEntity.m
//  KBAPISupport
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

#if !__has_feature(objc_arc)

#import "KBAutoEntity.h"

#if KBAPISUPPORT_XML
#	import "GDataXMLNode.h"
#endif

@implementation KBAutoEntity

+ (NSArray *) autoFields {
	return nil;
}

#if KBAPISUPPORT_JSON
+ (instancetype) entityFromJSON: (id) JSON {
	id <KBEntity> result = [[[self alloc] init] autorelease];
	for (id <KBAutoField> autoField in [self autoFields]) {
		if (![autoField setFieldInObject:result fromJSON:JSON]) {
			return nil;
		}
	}
	return result;
}
#endif

#if KBAPISUPPORT_XML
+ (instancetype) entityFromXML: (GDataXMLElement *) XML {
	id <KBEntity> result = [[[self alloc] init] autorelease];
	for (id <KBAutoField> autoField in [self autoFields]) {
		if (![autoField setFieldInObject:result fromXML:XML]) {
			return nil;
		}
	}
	return result;
}
#endif

@end

#endif // !__has_feature(objc_arc)
