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

#import "KBAutoFieldMacros.gen.h"

#if KBAPISUPPORT_XML
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
