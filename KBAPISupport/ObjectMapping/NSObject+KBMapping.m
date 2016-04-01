//
//  NSObject+KBMapping.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/31/16.
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

#import "NSObject+KBMapping.h"

#import <objc/runtime.h>

#import "KBMappingProperty.h"

static void const *const KBMappingPropertiesInitializedKey = "mapping-properties-initialized";

@implementation NSObject (KBMapping)

+ (NSArray<id<KBMappingProperty>> *)mappingProperties {
	NSArray <id <KBMappingProperty>> *mappingProperties = nil;
	if (__builtin_expect (!objc_getAssociatedObject (self, KBMappingPropertiesInitializedKey), 0)) {
		@synchronized (self) {
			if (!objc_getAssociatedObject (self, KBMappingPropertiesInitializedKey)) {
				mappingProperties = [self initializeMappingProperties];
				objc_setAssociatedObject (self, KBMappingPropertiesInitializedKey, @YES, OBJC_ASSOCIATION_ASSIGN);
				objc_setAssociatedObject (self, @selector (mappingProperties), mappingProperties, OBJC_ASSOCIATION_COPY);
			}
		}
	} else {
		mappingProperties = objc_getAssociatedObject (self, @selector (mappingProperties));
	}
	
	return mappingProperties;
}

+ (NSArray<id<KBMappingProperty>> *)initializeMappingProperties {
	return nil;
}

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
+ (instancetype) newInstanceForJSONObject: (id) JSONObject {
	return [self new];
}

+ (instancetype)objectFromJSON:(id)JSON {
	NSObject <KBObject> *result = [self newInstanceForJSONObject:JSON];
	if (!result) {
		return nil;
	}
	
	NSArray <id <KBMappingProperty>> *mappingProperties = self.mappingProperties;
	for (id <KBMappingProperty> mappingProperty in mappingProperties) {
		[mappingProperty setValueInObject:result fromJSONObject:JSON];
	}
	
	return result;
}
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
+ (instancetype) newInstanceForXMLObject: (GDataXMLElement *) XMLObject {
	return [self new];
}

+ (instancetype)objectFromXML:(GDataXMLElement *) XML {
	NSObject <KBObject> *result = [self newInstanceForXMLObject:XML];
	if (!result) {
		return nil;
	}
	
	NSArray <id <KBMappingProperty>> *mappingProperties = self.mappingProperties;
	for (id <KBMappingProperty> mappingProperty in mappingProperties) {
		[mappingProperty setValueInObject:result fromXMLObject:XML];
	}
	
	return result;
}
#endif

@end
