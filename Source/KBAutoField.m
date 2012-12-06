//
//  KBAutoField.m
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

#import <objc/objc-runtime.h>

#if KBAPISUPPORT_XML
#	import "GDataXMLNode.h"
#	import "GDataXMLElement+stuff.h"
#endif

#pragma mark - KBAutoFieldBase

@interface KBAutoFieldBase ()

- (NSString *) realSourceFieldName;
- (SEL) setter;

@end

@implementation KBAutoFieldBase

- (id) init {
	if (self = [super init]) {
		_isAttribute = NO;
	}
	
	return self;
}

- (void) dealloc {
	[_fieldName release];
	[_sourceFieldName release];
	
	[super dealloc];
}

- (SEL) setter {
	return NSSelectorFromString ([NSString stringWithFormat:@"set%@:", [self.fieldName capitalizedString]]);
}

- (NSString *) realSourceFieldName {
	return (self.sourceFieldName ? self.sourceFieldName : self.fieldName);
}

#if KBAPISUPPORT_JSON
- (BOOL) setFieldInObject: (id) object fromJSON: (id) JSON {
	if (![JSON isKindOfClass:[NSDictionary class]]) {
		return NO;
	}
	
	NSString *sourceFieldName = [self realSourceFieldName];
	NSString *fieldName = self.fieldName;
	if (!(sourceFieldName && fieldName)) {
		return NO;
	}
	
	return YES;
}
#endif

#if KBAPISUPPORT_XML
- (BOOL) setFieldInObject: (id) object fromXML:(GDataXMLElement *)XML {
	NSString *sourceFieldName = [self realSourceFieldName];
	NSString *fieldName = self.fieldName;
	if (!(sourceFieldName && fieldName)) {
		return NO;
	}
	
	return YES;
}
#endif

@end

#pragma mark - KBAutoIntegerField

@implementation KBAutoIntegerField

- (id) init {
	if (self = [super init]) {
		_isUnsigned = NO;
	}
	
	return self;
}

- (void) setIntValue: (NSInteger) value forObject: (id) object {
	SEL setter = [self setter];
	if (![object respondsToSelector:setter]) {
		return;
	}
	
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:setter]];
	[invocation setSelector:setter];
	[invocation setTarget:object];
	[invocation setArgument:&value atIndex:2];
	[invocation invoke];
}

#if KBAPISUPPORT_JSON
- (BOOL) setFieldInObject: (id) object fromJSON: (id) JSON {
	if (![super setFieldInObject:object fromJSON:JSON]) {
		return NO;
	}
	
	NSString *sourceFieldName = [self realSourceFieldName];
	
	id fieldValue = [JSON objectForKey:sourceFieldName];
	if ([fieldValue isKindOfClass:[NSNumber class]]) {
		if (self.isUnsigned) {
			[self setIntValue:[fieldValue unsignedIntegerValue] forObject:object];
		} else {
			[self setIntValue:[fieldValue integerValue] forObject:object];
		}
	} else if ([fieldValue isKindOfClass:[NSString class]]) {
		NSInteger value = [fieldValue integerValue];
		if (self.isUnsigned) {
			value = MAX (0, value);
		}
		[self setIntValue:value forObject:object];
	} else {
		[self setIntValue:0 forObject:object];
	}
	
	return YES;
}
#endif

#if KBAPISUPPORT_XML
- (BOOL) setFieldInObject: (id) object fromXML: (GDataXMLElement *) XML {
	if (![super setFieldInObject:object fromXML:XML]) {
		return NO;
	}
	
	NSInteger value;
	NSString *sourceFieldName = [self realSourceFieldName];
	if (self.isAttribute) {
		GDataXMLNode *attr = [XML attributeForName:sourceFieldName];
		if (!attr) {
			return NO;
		}
		value = [[attr stringValue] integerValue];
	} else {
		NSString *stringValue = [XML childStringValue:sourceFieldName];
		if (!stringValue) {
			return NO;
		}
		value = [stringValue integerValue];
	}

	if (self.isUnsigned) {
		value = MAX (0, value);
	}
	[self setIntValue:value forObject:object];
	
	return YES;
}
#endif

@end

#pragma mark - KBAutoStringField

@implementation KBAutoStringField

- (void) setStringValue: (NSString *) value forObject: (id) object {
	SEL setter = [self setter];
	if ([object respondsToSelector:setter]) {
		[object performSelector:setter withObject:value];
	}
}

#if KBAPISUPPORT_JSON
- (BOOL) setFieldInObject: (id) object fromJSON: (id) JSON {
	if (![super setFieldInObject:object fromJSON:JSON]) {
		return NO;
	}
	
	NSString *sourceFieldName = [self realSourceFieldName];

	id fieldValue = [JSON objectForKey:sourceFieldName];
	if ([fieldValue isKindOfClass:[NSString class]]) {
		[self setStringValue:fieldValue forObject:object];
	} else if ([fieldValue isKindOfClass:[NSNumber class]]) {
		NSString *value = [fieldValue stringValue];
		[self setStringValue:value forObject:object];
	} else {
		[self setStringValue:nil forObject:object];
	}
	
	return YES;
}
#endif

#if KBAPISUPPORT_XML
- (BOOL) setFieldInObject: (id) object fromXML: (GDataXMLElement *) XML {
	if (![super setFieldInObject:object fromXML:XML]) {
		return NO;
	}
	
	NSString *value;
	NSString *sourceFieldName = [self realSourceFieldName];
	if (self.isAttribute) {
		GDataXMLNode *attr = [XML attributeForName:sourceFieldName];
		if (!attr) {
			return NO;
		}
		value = [attr stringValue];
	} else {
		value = [XML childStringValue:sourceFieldName];
		if (!value) {
			return NO;
		}
	}

	[self setStringValue:value forObject:object];
	
	return YES;
}
#endif

@end

#pragma mark - KBAutoObjectField

@implementation KBAutoObjectField

- (void) dealloc {
	[_objectClass release];
	
	[super dealloc];
}

- (void) setObjectValue: (id) value forObject: (id) object {
	SEL setter = [self setter];
	if ([object respondsToSelector:setter]) {
		[object performSelector:setter withObject:value];
	}
}

#if KBAPISUPPORT_JSON
- (BOOL) setFieldInObject: (id) object fromJSON: (id) JSON {
	if (![super setFieldInObject:object fromJSON:JSON]) {
		return NO;
	}

	Class objectClass = self.objectClass;
	if (![objectClass conformsToProtocol:@protocol (KBEntity)]) {
		return NO;
	}

	NSString *sourceFieldName = [self realSourceFieldName];

	id fieldValue = [JSON objectForKey:sourceFieldName];
	id value = [objectClass entityFromJSON:fieldValue];
	if (!value) {
		return NO;
	}
	[self setObjectValue:value forObject:object];
	
	return YES;
}
#endif

#if KBAPISUPPORT_XML
- (BOOL) setFieldInObject: (id) object fromXML: (GDataXMLElement *) XML {
	if (![super setFieldInObject:object fromXML:XML]) {
		return NO;
	}

	Class objectClass = self.objectClass;
	if (![objectClass conformsToProtocol:@protocol (KBEntity)]) {
		return NO;
	}

	GDataXMLElement *fieldValue;
	NSString *sourceFieldName = [self realSourceFieldName];
	if (self.isAttribute) {
		return NO;
	} else {
		fieldValue = [XML firstChildWithName:sourceFieldName];
		if (!fieldValue) {
			return NO;
		}
	}

	id value = [objectClass entityFromXML:fieldValue];
	if (!value) {
		return NO;
	}
	[self setObjectValue:value forObject:object];
	
	return YES;
}
#endif

@end

#endif // !__has_feature(objc_arc)
