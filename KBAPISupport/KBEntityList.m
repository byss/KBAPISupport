//
//  KBEntityList.m
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

#import "KBEntityList.h"
#import "ARCSupport.h"

#if KBAPISUPPORT_XML
#	import "GDataXMLNode.h"
#endif

@implementation KBEntityList

- (id) init {
	return [self initWithCapacity:0];
}

- (id) initWithCapacity:(NSUInteger)capacity {
	if (self = [super init]) {
		_list = [[NSMutableArray alloc] initWithCapacity:capacity];
	}
	
	return self;
}

#if !__has_feature(objc_arc)
- (void) dealloc {
	[_list release];
	
	[super dealloc];
}
#endif

#if KBAPISUPPORT_XML
+ (NSString *) entityTag {
	return nil;
}
#endif

+ (Class) entityClass {
	return nil;
}

#if KBAPISUPPORT_JSON
+ (instancetype) entityFromJSON: (id) JSON {
	Class entityClass = [self entityClass];
	if (!([JSON isKindOfClass:[NSArray class]] && entityClass)) {
		return nil;
	}
	
	KBEntityList *result = [[self alloc] initWithJSON:JSON];
	return KB_AUTORELEASE (result);
}

- (id) initWithJSON:(id)JSON {
	if (self = [self initWithCapacity:[JSON count]]) {
		Class entityClass = [[self class] entityClass];
		for (id obj in JSON) {
			id <KBEntity> entity = [entityClass entityFromJSON:obj];
			if (entity) {
				[_list addObject:entity];
			}
		}
	}
	
	return self;
}
#endif

#if KBAPISUPPORT_XML
+ (instancetype) entityFromXML:(GDataXMLElement *)XML {
	NSString *entityTag = [self entityTag];
	Class entityClass = [self entityClass];
	if (entityTag && entityClass) {
		KBEntityList *result = [[self alloc] initWithXML:XML];
		return KB_AUTORELEASE (result);
	} else {
		return nil;
	}
}

- (id) initWithXML:(GDataXMLElement *)XML {
	NSString *entityTag = [[self class] entityTag];
	Class entityClass = [[self class] entityClass];
	NSArray *elements = [XML elementsForName:entityTag];

	if (self = [self initWithCapacity:[elements count]]) {
		for (GDataXMLElement *element in elements) {
			id <KBEntity> entity = [entityClass entityFromXML:element];
			if (entity) {
				[_list addObject:entity];
			}
		}
	}
	
	return self;
}
#endif

@end
