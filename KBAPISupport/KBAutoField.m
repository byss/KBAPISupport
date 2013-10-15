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

#import "KBAutoField.h"

#import "KBEntity.h"
#import "KBAutoFieldMacros.gen.h"

#if KBAPISUPPORT_XML
#	import "GDataXMLNode.h"
#	import "GDataXMLElement+stuff.h"
#	define ADDN_ARGS isAttribute: (BOOL) isAttribute
#	define ADDN_DEFAULTS isAttribute:NO
#	define ADDN_INIT _isAttribute = isAttribute;
#else
#	define ADDN_ARGS
#	define ADDN_DEFAULTS
#	define ADDN_INIT
#endif

#pragma mark - KBAutoFieldBase

@interface KBAutoFieldBase ()

- (NSString *) realSourceFieldName;
- (SEL) setter;

@end

@implementation KBAutoFieldBase

AUTOFIELD_CONVINIENCE_CREATOR_0 ()
AUTOFIELD_CONVINIENCE_CREATOR_1 (fieldName, FieldName, NSString *)
AUTOFIELD_CONVINIENCE_CREATOR_2 (fieldName, FieldName, NSString *, sourceFieldName, NSString *)

#if KBAPISUPPORT_XML
AUTOFIELD_CONVINIENCE_CREATOR_3 (fieldName, FieldName, NSString *, sourceFieldName, NSString *, isAttribute, BOOL)
#endif

DELEGATE_INITIALIZATION_0 (WithFieldName:nil sourceFieldName:nil ADDN_DEFAULTS)
DELEGATE_INITIALIZATION (WithFieldName:(NSString *)fieldName, sourceFieldName:nil ADDN_DEFAULTS)
#if KBAPISUPPORT_XML
DELEGATE_INITIALIZATION (WithFieldName:(NSString *)fieldName sourceFieldName:(NSString *) sourceFieldName, ADDN_DEFAULTS)
#endif

- (id) initWithFieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName ADDN_ARGS {
	if (self = [super init]) {
		_fieldName = [fieldName retain];
		_sourceFieldName = [sourceFieldName retain];
		ADDN_INIT
	}
	
	return self;
}

DEALLOC_MACRO_2(fieldName, sourceFieldName)

- (SEL) setter {
	NSString *first = [self.fieldName substringToIndex:1];
	NSString *other = [self.fieldName substringFromIndex:1];
	return NSSelectorFromString ([NSString stringWithFormat:@"set%@%@:", [first uppercaseString], other]);
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

#pragma mark - KBAutoTimestampField

@implementation KBAutoTimestampField

- (void) setDateFromTimestamp: (NSInteger) timestamp forObject: (id) object {
	NSDate *value = [NSDate dateWithTimeIntervalSince1970:timestamp];
	SEL setter = [self setter];
	if ([object respondsToSelector:setter]) {
		[object performSelector:setter withObject:value];
	}
}

- (void) gotIntValue: (NSInteger) value forObject: (id) object {
	[self setDateFromTimestamp:value forObject:object];
}

#if KBAPISUPPORT_JSON
- (BOOL) setFieldInObject: (id) object fromJSON: (id) JSON {
	if (![super setFieldInObject:object fromJSON:JSON]) {
		return NO;
	}
	
	NSString *sourceFieldName = [self realSourceFieldName];
	
	id fieldValue = [JSON objectForKey:sourceFieldName];
	if ([fieldValue isKindOfClass:[NSNumber class]]) {
		[self gotIntValue:[fieldValue integerValue] forObject:object];
	} else if ([fieldValue isKindOfClass:[NSString class]]) {
		NSInteger value = [fieldValue integerValue];
		[self gotIntValue:value forObject:object];
	} else {
		[self gotIntValue:0 forObject:object];
	}
	
	return YES;
}
#endif

#if KBAPISUPPORT_XML
- (BOOL) setFieldInObject: (id) object fromXML: (GDataXMLElement *) XML {
	if (![super setFieldInObject:object fromXML:XML]) {
		return NO;
	}
	
	NSInteger value = 0;
	NSString *sourceFieldName = [self realSourceFieldName];
	if (self.isAttribute) {
		GDataXMLNode *attr = [XML attributeForName:sourceFieldName];
		if (attr) {
			value = [[attr stringValue] integerValue];
		}
	} else {
		NSString *stringValue = [XML childStringValue:sourceFieldName];
		if (stringValue) {
			value = [stringValue integerValue];
		}
	}
	
	[self gotIntValue:value forObject:object];
	
	return YES;
}
#endif

@end

#pragma mark - KBAutoIntegerField

@implementation KBAutoIntegerField

AUTOFIELD_CONVINIENCE_CREATOR_1 (isUnsigned, Unsigned, BOOL)
AUTOFIELD_CONVINIENCE_CREATOR_2 (isUnsigned, Unsigned, BOOL, fieldName, NSString *)
AUTOFIELD_CONVINIENCE_CREATOR_3 (isUnsigned, Unsigned, BOOL, fieldName, NSString *, sourceFieldName, NSString *)

#if KBAPISUPPORT_XML
AUTOFIELD_CONVINIENCE_CREATOR_4 (isUnsigned, Unsigned, BOOL, fieldName, NSString *, sourceFieldName, NSString *, isAttribute, BOOL)
#endif

DELEGATE_INITIALIZATION (WithUnsigned: (BOOL) isUnsigned, fieldName:nil sourceFieldName:nil ADDN_DEFAULTS)
DELEGATE_INITIALIZATION (WithUnsigned: (BOOL) isUnsigned fieldName:(NSString *)fieldName, sourceFieldName:nil ADDN_DEFAULTS)
#if KBAPISUPPORT_XML
DELEGATE_INITIALIZATION (WithUnsigned: (BOOL) isUnsigned fieldName:(NSString *)fieldName sourceFieldName:(NSString *) sourceFieldName, ADDN_DEFAULTS)
#endif

- (id) initWithFieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName ADDN_ARGS {
	return [self initWithUnsigned:NO fieldName:fieldName sourceFieldName:sourceFieldName ADDN_ARGS];
}

- (id) initWithUnsigned: (BOOL) isUnsigned fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName ADDN_ARGS {
	if (self = [super initWithFieldName:fieldName sourceFieldName:sourceFieldName ADDN_ARGS]) {
		_isUnsigned = isUnsigned;
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

- (void) gotIntValue:(NSInteger)value forObject:(id)object {
	[self setIntValue:((self.isUnsigned && (value < 0)) ? 0 : value) forObject:object];
}

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
	
	NSString *value = nil;
	NSString *sourceFieldName = [self realSourceFieldName];
	if (self.isAttribute) {
		GDataXMLNode *attr = [XML attributeForName:sourceFieldName];
		if (attr) {
			value = [attr stringValue];
		}
	} else {
		value = [XML childStringValue:sourceFieldName];
	}

	[self setStringValue:value forObject:object];
	
	return YES;
}
#endif

@end

#pragma mark - KBAutoObjectField

@implementation KBAutoObjectField

AUTOFIELD_CONVINIENCE_CREATOR_1 (objectClass, ObjectClass, Class)
AUTOFIELD_CONVINIENCE_CREATOR_2 (objectClass, ObjectClass, Class, fieldName, NSString *)
AUTOFIELD_CONVINIENCE_CREATOR_3 (objectClass, ObjectClass, Class, fieldName, NSString *, sourceFieldName, NSString *)

#if KBAPISUPPORT_XML
AUTOFIELD_CONVINIENCE_CREATOR_4 (objectClass, ObjectClass, Class, fieldName, NSString *, sourceFieldName, NSString *, isAttribute, BOOL)
#endif

DELEGATE_INITIALIZATION (WithObjectClass: (Class) objectClass, fieldName:nil sourceFieldName:nil ADDN_DEFAULTS)
DELEGATE_INITIALIZATION (WithObjectClass: (Class) objectClass fieldName:(NSString *)fieldName, sourceFieldName:nil ADDN_DEFAULTS)
#if KBAPISUPPORT_XML
DELEGATE_INITIALIZATION (WithObjectClass: (Class) objectClass fieldName:(NSString *)fieldName sourceFieldName:(NSString *) sourceFieldName, ADDN_DEFAULTS)
#endif

- (id) initWithFieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName ADDN_ARGS {
	return [self initWithObjectClass:nil fieldName:fieldName sourceFieldName:sourceFieldName ADDN_ARGS];
}

- (id) initWithObjectClass: (Class) objectClass fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName ADDN_ARGS {
	if (self = [super initWithFieldName:fieldName sourceFieldName:sourceFieldName ADDN_ARGS]) {
		_objectClass = [objectClass retain];
	}
	
	return self;
}

DEALLOC_MACRO_1 (objectClass)

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

	GDataXMLElement *fieldValue = nil;
	NSString *sourceFieldName = [self realSourceFieldName];
	if (self.isAttribute) {
		return NO;
	} else {
		fieldValue = [XML firstChildWithName:sourceFieldName];
	}

	id value = [objectClass entityFromXML:fieldValue];
	[self setObjectValue:value forObject:object];
	
	return YES;
}
#endif

@end

@implementation KBAutoStringArrayField

- (void) setStringArrayValue: (NSArray *) value forObject: (id) object {
	SEL setter = [self setter];
	if ([object respondsToSelector:setter]) {
		[object performSelector:setter withObject:value];
	}
}

#if KBAPISUPPORT_JSON
- (BOOL) setFieldInObject:(id)object fromJSON:(id)JSON {
	if (![super setFieldInObject:object fromJSON:JSON]) {
		return NO;
	}
	
	NSString *sourceFieldName = [self realSourceFieldName];
	
	id fieldValue = [JSON objectForKey:sourceFieldName];
	if ([fieldValue isKindOfClass:[NSArray class]]) {
		NSMutableArray *value = [[NSMutableArray alloc] initWithCapacity:[fieldValue count]];
		for (id valueItem in fieldValue) {
			if ([valueItem isKindOfClass:[NSString class]]) {
				[value addObject:valueItem];
			}
		}
		[self setStringArrayValue:[[NSArray alloc] initWithArray:value] forObject:object];
	} else {
		[self setStringArrayValue:nil forObject:object];
	}
	
	return YES;
}
#endif

#if KBAPISUPPORT_XML
- (BOOL) setFieldInObject: (id) object fromXML: (GDataXMLElement *) XML {
	static dispatch_once_t onceToken;
	dispatch_once (&onceToken, ^{
    NSLog (@"===== KBAPISupport: WARNING! string arrays are not supported for XML yet! =====");
	});
	return NO;
}
#endif

@end

#endif // !__has_feature(objc_arc)
