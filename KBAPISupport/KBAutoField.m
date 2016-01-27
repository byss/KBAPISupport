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

#import "KBAutoField.h"

#import <objc/runtime.h>

#import "KBEntity.h"
#import "ARCSupport.h"
#import "KBAutoFieldMacros.gen.h"

#if KBAPISUPPORT_XML
#	import "GDataXMLElement+stuff.h"
#	define ADDN_ARGS isAttribute: (BOOL) isAttribute
#	define ADDN_DEFAULTS isAttribute:NO
#	define ADDN_INIT _attribute = isAttribute;
#	define ADDN_ARGS2 entityTag: (NSString *) entityTag
#	define ADDN_DEFAULTS2 entityTag:nil
#	define ADDN_INIT2 _entityTag = KB_RETAIN (entityTag);
#else
#	define ADDN_ARGS
#	define ADDN_DEFAULTS
#	define ADDN_INIT
#	define ADDN_ARGS2
#	define ADDN_DEFAULTS2
#	define ADDN_INIT2
#endif

#if KBAPISUPPORT_JSON
static inline NSString *stringValue (id object);
#endif
static inline NSNumber *numberValue (id object);

#pragma mark - KBAutoFieldBase

@interface KBAutoFieldBase () {
	NSString *_sourceFieldName;
}

@end

@implementation KBAutoFieldBase

AUTOFIELD_CONVINIENCE_CREATOR_1 (fieldName, FieldName, NSString *)
AUTOFIELD_CONVINIENCE_CREATOR_2 (fieldName, FieldName, NSString *, sourceFieldName, NSString *)

#if KBAPISUPPORT_XML
AUTOFIELD_CONVINIENCE_CREATOR_3 (fieldName, FieldName, NSString *, sourceFieldName, NSString *, isAttribute, BOOL)
#endif

DELEGATE_INITIALIZATION (WithFieldName:(NSString *)fieldName, sourceFieldName:nil ADDN_DEFAULTS)
#if KBAPISUPPORT_XML
DELEGATE_INITIALIZATION (WithFieldName:(NSString *)fieldName sourceFieldName:(NSString *) sourceFieldName, ADDN_DEFAULTS)
#endif

- (id) initWithFieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName ADDN_ARGS {
	if (!fieldName) {
		KB_RELEASE (self);
		@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"fieldName cannot be nil!" userInfo:nil];
	}
	
	if (self = [super init]) {
		_fieldName = KB_RETAIN (fieldName);
		_sourceFieldName = KB_RETAIN (sourceFieldName);
		ADDN_INIT
	}
	
	return self;
}

DEALLOC_MACRO_2(fieldName, sourceFieldName)

- (NSString *) sourceFieldName {
	return (_sourceFieldName ?: self.fieldName);
}

#if KBAPISUPPORT_JSON
- (BOOL) setFieldInObject: (id) object fromJSON: (id) JSON {
	if (![JSON isKindOfClass:[NSDictionary class]]) {
		return NO;
	}
	
	return YES;
}
#endif

#if KBAPISUPPORT_XML
- (BOOL) setFieldInObject: (id) object fromXML:(GDataXMLElement *)XML {
	return YES;
}
#endif

@end

#pragma mark - KBAutoTimestampField

@implementation KBAutoTimestampField

- (void) gotNumericValue: (NSNumber *) value forObject: (id) object {
	[object setValue:(value ? [[NSDate alloc] initWithTimeIntervalSince1970:value.integerValue] : nil) forKey:self.fieldName];
}

#if KBAPISUPPORT_JSON
- (BOOL) setFieldInObject: (id) object fromJSON: (NSDictionary *) JSON {
	if (![super setFieldInObject:object fromJSON:JSON]) {
		return NO;
	}
	
	NSNumber *numValue = numberValue (JSON [self.sourceFieldName]);
	[self gotNumericValue:numValue forObject:object];
	
	return YES;
}
#endif

#if KBAPISUPPORT_XML
- (BOOL) setFieldInObject: (id) object fromXML: (GDataXMLElement *) XML {
	if (![super setFieldInObject:object fromXML:XML]) {
		return NO;
	}
	
	NSString *strValue = nil;
	NSString *sourceFieldName = self.sourceFieldName;
	if (self.isAttribute) {
		for (GDataXMLNode *attr = [XML attributeForName:sourceFieldName]; attr; attr = nil) {
			strValue = attr.stringValue;
		}
	} else {
		strValue = [XML childStringValue:sourceFieldName];
	}
	
	[self gotNumericValue:numberValue (strValue) forObject:object];
	
	return YES;
}
#endif

@end

#pragma mark - KBAutoIntegerField

@implementation KBAutoIntegerField

AUTOFIELD_CONVINIENCE_CREATOR_2 (isUnsigned, Unsigned, BOOL, fieldName, NSString *)
AUTOFIELD_CONVINIENCE_CREATOR_3 (isUnsigned, Unsigned, BOOL, fieldName, NSString *, sourceFieldName, NSString *)

#if KBAPISUPPORT_XML
AUTOFIELD_CONVINIENCE_CREATOR_4 (isUnsigned, Unsigned, BOOL, fieldName, NSString *, sourceFieldName, NSString *, isAttribute, BOOL)
#endif

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

- (void) gotNumericValue:(NSNumber *)value forObject:(id)object {
	[object setValue:((self.isUnsigned && (value < 0)) ? nil : value) forKey:self.fieldName];
}

@end

#pragma mark - KBAutoStringField

@implementation KBAutoStringField

#if KBAPISUPPORT_JSON
- (BOOL) setFieldInObject: (id) object fromJSON: (NSDictionary *) JSON {
	if (![super setFieldInObject:object fromJSON:JSON]) {
		return NO;
	}
	
	NSString *strValue = stringValue (JSON [self.sourceFieldName]);
	[object setValue:strValue forKey:self.fieldName];
	
	return YES;
}
#endif

#if KBAPISUPPORT_XML
- (BOOL) setFieldInObject: (id) object fromXML: (GDataXMLElement *) XML {
	if (![super setFieldInObject:object fromXML:XML]) {
		return NO;
	}
	
	NSString *strValue = nil;
	NSString *sourceFieldName = self.sourceFieldName;
	if (self.isAttribute) {
		for (GDataXMLNode *attr = [XML attributeForName:sourceFieldName]; attr; attr = nil) {
			strValue = [attr stringValue];
		}
	} else {
		strValue = [XML childStringValue:sourceFieldName];
	}
	[object setValue:strValue forKey:self.fieldName];
	
	return YES;
}
#endif

@end

#pragma mark - KBAutoURLField

@implementation KBAutoURLField

AUTOFIELD_CONVINIENCE_CREATOR_2 (baseURL, BaseURL, NSURL *, fieldName, NSString *)
AUTOFIELD_CONVINIENCE_CREATOR_3 (baseURL, BaseURL, NSURL *, fieldName, NSString *, sourceFieldName, NSString *)

#if KBAPISUPPORT_XML
AUTOFIELD_CONVINIENCE_CREATOR_4 (baseURL, BaseURL, NSURL *, fieldName, NSString *, sourceFieldName, NSString *, isAttribute, BOOL)
#endif

DELEGATE_INITIALIZATION (WithBaseURL: (NSURL *) baseURL fieldName:(NSString *)fieldName, sourceFieldName:nil ADDN_DEFAULTS)
#if KBAPISUPPORT_XML
DELEGATE_INITIALIZATION (WithBaseURL: (NSURL *) baseURL fieldName:(NSString *)fieldName sourceFieldName:(NSString *) sourceFieldName, ADDN_DEFAULTS)
#endif

- (instancetype)initWithFieldName:(NSString *)fieldName sourceFieldName:(NSString *)sourceFieldName ADDN_ARGS {
	return [self initWithBaseURL:nil fieldName:fieldName sourceFieldName:sourceFieldName ADDN_ARGS];
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL fieldName:(NSString *)fieldName sourceFieldName:(NSString *)sourceFieldName ADDN_ARGS {
	if (self = [super initWithFieldName:fieldName sourceFieldName:sourceFieldName ADDN_ARGS]) {
		_baseURL = baseURL;
	}
	
	return self;
}

#if KBAPISUPPORT_JSON
- (BOOL) setFieldInObject: (id) object fromJSON: (NSDictionary *) JSON {
	if (![super setFieldInObject:object fromJSON:JSON]) {
		return NO;
	}
	
	NSString *strValue = stringValue (JSON [self.sourceFieldName]);
	NSURL *urlValue = (strValue ? [[NSURL alloc] initWithString:strValue relativeToURL:self.baseURL] : nil);
	[object setValue:urlValue forKey:self.fieldName];
	
	return YES;
}
#endif

#if KBAPISUPPORT_XML
- (BOOL) setFieldInObject: (id) object fromXML: (GDataXMLElement *) XML {
	if (![super setFieldInObject:object fromXML:XML]) {
		return NO;
	}
	
	NSString *strValue = nil;
	NSString *sourceFieldName = self.sourceFieldName;
	if (self.isAttribute) {
		for (GDataXMLNode *attr = [XML attributeForName:sourceFieldName]; attr; attr = nil) {
			strValue = [attr stringValue];
		}
	} else {
		strValue = [XML childStringValue:sourceFieldName];
	}
	NSURL *urlValue = (strValue ? [[NSURL alloc] initWithString:strValue relativeToURL:self.baseURL] : nil);
	[object setValue:urlValue forKey:self.fieldName];
	
	return YES;
}
#endif

@end

#pragma mark - KBAutoObjectField

@implementation KBAutoObjectField

AUTOFIELD_CONVINIENCE_CREATOR_2 (objectClass, ObjectClass, Class, fieldName, NSString *)
AUTOFIELD_CONVINIENCE_CREATOR_3 (objectClass, ObjectClass, Class, fieldName, NSString *, sourceFieldName, NSString *)

DELEGATE_INITIALIZATION (WithObjectClass: (Class) objectClass fieldName:(NSString *)fieldName, sourceFieldName:nil)

- (id) initWithFieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName ADDN_ARGS {
#if KBAPISUPPORT_XML
	if (isAttribute) {
		KB_RELEASE (self);
		@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot build objects from attributes!" userInfo:nil];
	}
#endif
	return [self initWithObjectClass:nil fieldName:fieldName sourceFieldName:sourceFieldName];
}

- (id) initWithObjectClass: (Class) objectClass fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName {
	if (![objectClass conformsToProtocol:@protocol (KBEntity)]) {
		KB_RELEASE (self);
		@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Object class must conform to KBEntity!" userInfo:nil];
	}

	if (self = [super initWithFieldName:fieldName sourceFieldName:sourceFieldName ADDN_DEFAULTS]) {
		_objectClass = objectClass;
	}
	
	return self;
}

#if KBAPISUPPORT_JSON
- (BOOL) setFieldInObject: (id) object fromJSON: (NSDictionary *) JSON {
	if (![super setFieldInObject:object fromJSON:JSON]) {
		return NO;
	}

	Class objectClass = self.objectClass;
	id objValue = [objectClass entityFromJSON:JSON [self.sourceFieldName]];
	[object setValue:objValue forKey:self.fieldName];
	
	return YES;
}
#endif

#if KBAPISUPPORT_XML
- (BOOL) setFieldInObject: (id) object fromXML: (GDataXMLElement *) XML {
	if (![super setFieldInObject:object fromXML:XML]) {
		return NO;
	}

	Class objectClass = self.objectClass;
	NSString *sourceFieldName = self.sourceFieldName;
	GDataXMLElement *fieldValue = [XML firstChildWithName:sourceFieldName];
	id objValue = [objectClass entityFromXML:fieldValue];
	[object setValue:objValue forKey:self.fieldName];
	
	return YES;
}
#endif

@end

#pragma mark - KBAutoStringArrayField

@implementation KBAutoStringArrayField

#if KBAPISUPPORT_JSON
- (BOOL) setFieldInObject:(id)object fromJSON:(NSDictionary *)JSON {
	if (![super setFieldInObject:object fromJSON:JSON]) {
		return NO;
	}
	
	NSArray *fieldValue = JSON [self.sourceFieldName];
	__strong id *strings = NULL;
	NSUInteger stringsCount = 0;
	if ([fieldValue isKindOfClass:[NSArray class]]) {
		strings = (__strong id *) calloc (fieldValue.count, sizeof (*strings));
		for (id valueItem in fieldValue) {
			for (NSString *strValue = stringValue (valueItem); strValue; strValue = nil) {
				strings [stringsCount++] = strValue;
			}
		}
	}
	
	NSArray *strArrValue = (strings ? [[NSArray alloc] initWithObjects:strings count:stringsCount] : nil);
	if (strings) {
		free (strings);
	}
	[object setValue:strArrValue forKey:self.fieldName];
	
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

#pragma mark - KBAutoObjectCollectionField

@implementation KBAutoObjectCollectionField

+ (Class) collectionClass {
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Collection class is not defined!" userInfo:nil];
}

+ (Class) mutableCollectionClass {
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Mutable collection class is not defined!" userInfo:nil];
}

AUTOFIELD_CONVINIENCE_CREATOR_2 (entityClass, EntityClass, Class, fieldName, NSString *)
AUTOFIELD_CONVINIENCE_CREATOR_3 (entityClass, EntityClass, Class, fieldName, NSString *, sourceFieldName, NSString *)
AUTOFIELD_CONVINIENCE_CREATOR_4 (entityClass, EntityClass, Class, fieldName, NSString *, sourceFieldName, NSString *, isMutable, BOOL)

#if KBAPISUPPORT_XML
AUTOFIELD_CONVINIENCE_CREATOR_3 (entityClass, EntityClass, Class, fieldName, NSString *, entityTag, NSString *)
AUTOFIELD_CONVINIENCE_CREATOR_4 (entityClass, EntityClass, Class, fieldName, NSString *, sourceFieldName, NSString *, entityTag, NSString *)
AUTOFIELD_CONVINIENCE_CREATOR_5 (entityClass, EntityClass, Class, fieldName, NSString *, sourceFieldName, NSString *, isMutable, BOOL, entityTag, NSString *)
#endif

DELEGATE_INITIALIZATION (WithEntityClass: (Class) entityClass fieldName:(NSString *)fieldName, sourceFieldName:nil);
DELEGATE_INITIALIZATION (WithEntityClass: (Class) entityClass fieldName:(NSString *)fieldName sourceFieldName:(NSString *)sourceFieldName, isMutable:NO);
#if KBAPISUPPORT_XML
DELEGATE_INITIALIZATION (WithEntityClass: (Class) entityClass fieldName:(NSString *)fieldName sourceFieldName:(NSString *)sourceFieldName isMutable: (BOOL) isMutable, entityTag:nil);
- (instancetype) initWithEntityClass: (Class) entityClass fieldName:(NSString *)fieldName entityTag: (NSString *) entityTag {
	return [self initWithEntityClass:entityClass fieldName:fieldName sourceFieldName:nil isMutable:NO entityTag:entityTag];
}
- (instancetype) initWithEntityClass: (Class) entityClass fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName  entityTag: (NSString *) entityTag {
	return [self initWithEntityClass:entityClass fieldName:fieldName sourceFieldName:sourceFieldName isMutable:NO entityTag:entityTag];
}
- (id) initWithFieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName ADDN_ARGS {
	return [self initWithEntityClass:nil fieldName:fieldName sourceFieldName:sourceFieldName ADDN_DEFAULTS2];
}
#endif

- (id) initWithEntityClass: (Class) entityClass fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName isMutable: (BOOL) isMutable ADDN_ARGS2 {
	if (![entityClass conformsToProtocol:@protocol (KBEntity)]) {
		KB_RELEASE (self);
		@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Object class must conform to KBEntity!" userInfo:nil];
	}
#if KBAPISUPPORT_XML
	if (!entityTag) {
		KB_RELEASE (self);
		@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Entity tag cannot be nil!" userInfo:nil];
	}
#endif
	
	if (self = [super initWithFieldName:fieldName sourceFieldName:sourceFieldName ADDN_DEFAULTS]) {
		_entityClass = entityClass;
		_isMutable = isMutable;
		ADDN_INIT2
	}
	
	return self;
}

DEALLOC_MACRO_1 (entityTag);

#if KBAPISUPPORT_JSON
- (BOOL) setFieldInObject:(id)object fromJSON:(NSDictionary *)JSON {
	if (![super setFieldInObject:object fromJSON:JSON]) {
		return NO;
	}
	
	NSArray *fieldValue = JSON [self.sourceFieldName];
	__strong id *objects = NULL;
	NSUInteger objectsCount = 0;
	if ([fieldValue isKindOfClass:[NSArray class]]) {
		objects = (__strong id *) calloc (fieldValue.count, sizeof (*objects));
		Class entityClass = self.entityClass;
		for (id valueItem in fieldValue) {
			for (id objValue = [entityClass entityFromJSON:valueItem]; objValue; objValue = nil) {
				objects [objectsCount++] = objValue;
			}
		}
	}
	
	[self setFieldInObject:object withObjects:objects count:objectsCount];
	
	return YES;
}
#endif

#if KBAPISUPPORT_XML
- (BOOL)setFieldInObject:(id)object fromXML:(GDataXMLElement *)XML {
	if (![super setFieldInObject:object fromXML:XML]) {
		return NO;
	}
	
	NSString *entityTag = self.entityTag;
	Class entityClass = self.entityClass;
	NSArray *elements = [XML elementsForName:entityTag];
	__strong id *objects = (__strong id *) calloc (elements.count, sizeof (*objects));
	NSUInteger objectsCount = 0;
	for (GDataXMLElement *element in elements) {
		for (id objValue = [entityClass entityFromXML:element]; objValue; objValue = nil) {
			objects [objectsCount++] = objValue;
		}
	}

	[self setFieldInObject:object withObjects:objects count:objectsCount];
	
	return YES;
}
#endif

- (void) setFieldInObject: (id) object withObjects: (__strong id *) objects count: (NSUInteger) objectCount {
	id objCollectionValue = nil;
	@try {
		Class collectionClass = (self.isMutable ? [self.class mutableCollectionClass] : [self.class collectionClass]);
		objCollectionValue = (objects ? [[collectionClass alloc] initWithObjects:objects count:objectCount] : nil);
	}
	@finally {
		free (objects);
	}
	
	[object setValue:objCollectionValue forKey:self.fieldName];
}

@end

#if KBAPISUPPORT_JSON
static inline NSString *stringValue (id object) {
	if ([object isKindOfClass:[NSString class]]) {
		return object;
	} else if ([object isKindOfClass:[NSNumber class]]) {
		return [object description];
	} else {
		return nil;
	}
}
#endif

static inline NSNumber *numberValue (id object) {
	if ([object isKindOfClass:[NSNumber class]]) {
		return object;
	} else if ([object isKindOfClass:[NSString class]]) {
		return [[NSDecimalNumber alloc] initWithString:object];
	} else {
		return nil;
	}
}

#pragma mark - KBAutoObjectCollectionField subclasses

@implementation KBAutoObjectArrayField

+ (Class) collectionClass {
	return [NSArray class];
}

+ (Class) mutableCollectionClass {
	return [NSMutableArray class];
}

@end

@implementation KBAutoObjectSetField

+ (Class) collectionClass {
	return [NSSet class];
}

+ (Class) mutableCollectionClass {
	return [NSMutableSet class];
}

@end

@implementation KBAutoObjectOrderedSetField

+ (Class) collectionClass {
	return [NSOrderedSet class];
}

+ (Class) mutableCollectionClass {
	return [NSMutableOrderedSet class];
}

@end
