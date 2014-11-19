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

#import "KBAutoEntity.h"

#import <objc/runtime.h>

#if KBAPISUPPORT_XML
#	if KBAPISUPPORT_PODS_BUILD
#		import <GDataXML-HTML/GDataXMLNode.h>
#	else
#		import "GDataXMLNode.h"
#	endif
#endif
#import "KBAPISupport-debug.h"

static char const *const kAutoFieldsInitialized = "auto-fields-initialized";
static char const *const kAutoFieldsArray = "auto-fields";
#if DEBUG
static char const *const kKnownUndefinedKeys = "known-undefined-keys";
#endif

static inline Method class_getMethod (Class class, SEL selector, BOOL isClassMethod);
static inline void _setupAutoEntityMethod (SEL selector, BOOL isClassMethod, Class objectClass);

@implementation KBAutoEntity

+ (NSArray *) autoFields {
	NSArray *autoFields = nil;
	if (__builtin_expect (!objc_getAssociatedObject (self, kAutoFieldsInitialized), 0)) {
		@synchronized (self) {
			if (!objc_getAssociatedObject (self, kAutoFieldsInitialized)) {
				autoFields = [self initializeAutoFields];
				objc_setAssociatedObject (self, kAutoFieldsInitialized, @YES, OBJC_ASSOCIATION_ASSIGN);
				objc_setAssociatedObject (self, kAutoFieldsArray, autoFields, OBJC_ASSOCIATION_COPY);
			}
		}
	} else {
		autoFields = objc_getAssociatedObject (self, kAutoFieldsArray);
	}
	
	return autoFields;
}

+ (NSArray *)initializeAutoFields {
	return nil;
}

+ (instancetype) createEntity {
	return [self new];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
#if DEBUG
	@synchronized (self.class) {
		NSMutableSet *knownUndefinedKeys = objc_getAssociatedObject (self.class, kKnownUndefinedKeys);
		if (![knownUndefinedKeys containsObject:key]) {
			if (__builtin_expect (!knownUndefinedKeys, 0)) {
				knownUndefinedKeys = [[NSMutableSet alloc] initWithObjects:key, nil];
				objc_setAssociatedObject (self.class, kKnownUndefinedKeys, knownUndefinedKeys, OBJC_ASSOCIATION_RETAIN);
			} else {
				[knownUndefinedKeys addObject:key];
			}
			KBAPISUPPORT_LOG (@"Warning: undefined auto entity key: \"%@\"; value: %@; entity class: %@", key, value, self.class);
		}
	}
#endif
}

- (void)setNilValueForKey:(NSString *)key {
	// do nothing: init-time default value is 0, NO or nil already
}

#pragma mark - KBEntity implementation

#if KBAPISUPPORT_JSON
+ (instancetype) entityFromJSON: (id) JSON {
	id <KBEntity> result = [self createEntity];
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
	id <KBEntity> result = [self createEntity];
	for (id <KBAutoField> autoField in [self autoFields]) {
		if (![autoField setFieldInObject:result fromXML:XML]) {
			return nil;
		}
	}
	return result;
}
#endif

#pragma mark - Setting another class as AutoEntity

+ (void) _setupAutoEntityMethods {
	class_addProtocol (self, @protocol (KBEntity));
	_setupAutoEntityMethod (@selector (autoFields), YES, self);
	_setupAutoEntityMethod (@selector (initializeAutoFields), YES, self);
	_setupAutoEntityMethod (@selector (setValue:forUndefinedKey:), NO, self);
	_setupAutoEntityMethod (@selector (setNilValueForKey:), NO, self);
#if KBAPISUPPORT_JSON
	_setupAutoEntityMethod (@selector (entityFromJSON:), YES, self);
#endif
#if KBAPISUPPORT_XML
	_setupAutoEntityMethod (@selector (entityFromXML:), YES, self);
#endif
}

+ (void)setupAutoEntityMethodsForObjectClass:(Class)objectClass {
	_setupAutoEntityMethod (@selector (_setupAutoEntityMethods), YES, objectClass);
	[objectClass _setupAutoEntityMethods];
}

@end

#pragma mark - Helpers

static inline Method class_getMethod (Class objClass, SEL selector, BOOL isClassMethod) {
	return (isClassMethod ? class_getClassMethod : class_getInstanceMethod) (objClass, selector);
}

static inline void _setupAutoEntityMethod (SEL selector, BOOL isClassMethod, Class objectClass) {
	static Class standardClass = nil;
	static dispatch_once_t onceToken;
	dispatch_once (&onceToken, ^{
		standardClass = [KBAutoEntity class];
	});
	
	Method method = class_getMethod (standardClass, selector, isClassMethod);
	IMP standardImpl = method_getImplementation (method);
	IMP objectClassImpl = method_getImplementation (class_getMethod (objectClass, selector, isClassMethod));
	
	if (standardImpl != objectClassImpl) {
		char const *const typeEncoding = method_getTypeEncoding (method);
		Class destClass = (isClassMethod ? object_getClass (objectClass) : objectClass);

		if (objectClassImpl) {
			class_replaceMethod (destClass, selector, standardImpl, typeEncoding);
		} else {
			class_addMethod (destClass, selector, standardImpl, typeEncoding);
		}
	}
}
