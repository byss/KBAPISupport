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

#import <objc/message.h>
#import <objc/runtime.h>

#import "KBArray_Protected.h"
#import "KBMappingProperty.h"

static void const *const KBMappingPropertiesInitializedKey = "mapping-properties-initialized";

@implementation NSObject (KBMapping)

+ (NSArray <id <KBMappingProperty>> *) mappingProperties {
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

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
+ (instancetype) newInstanceForJSONObject: (id) JSONObject mappingContext: (id _Nullable) mappingContext {
	if ([JSONObject isKindOfClass:[NSDictionary class]]) {
		return [self new];
	} else {
		return nil;
	}
}

+ (instancetype)objectFromJSON:(id)JSON mappingContext: (id _Nullable) mappingContext {
	NSObject <KBObject> *result = [self newInstanceForJSONObject:JSON mappingContext:mappingContext];
	if (!result) {
		return nil;
	}
	
	NSArray <id <KBMappingProperty>> *mappingProperties = self.mappingProperties;
	for (id <KBMappingProperty> mappingProperty in mappingProperties) {
		[mappingProperty setValueInObject:result fromJSONObject:JSON mappingContext:mappingContext];
	}
	
	return result;
}
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
+ (instancetype) newInstanceForXMLObject: (GDataXMLElement *) XMLObject mappingContext: (id _Nullable) mappingContext {
	if ([JSONObject isKindOfClass:[NSDictionary class]]) {
		return [self new];
	} else {
		return nil;
	}
}

+ (instancetype)objectFromXML:(GDataXMLElement *) XML mappingContext: (id _Nullable) mappingContext {
	NSObject <KBObject> *result = [self newInstanceForXMLObject:XML mappingContext:mappingContext];
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

@interface KBCamelCaseToSnakeCaseStringTransformer: NSValueTransformer

@end

NSValueTransformerName const KBCamelCaseToSnakeCaseStringTransformerName = @OS_STRINGIFY (KBCamelCaseToSnakeCaseStringTransformer);

@implementation KBCamelCaseToSnakeCaseStringTransformer

+ (Class) transformedValueClass {
	return [NSString class];
}

+ (BOOL) allowsReverseTransformation {
	return YES;
}

- (NSString *) transformedValue: (NSString *) value {
	if (!value.length) {
		return value;
	}
	
	NSUInteger const valueLen = value.length;
	unichar *const resultChars = malloc ((valueLen + (valueLen / 2)) * sizeof (unichar));
	unichar *resultCharsEnd = resultChars;
	BOOL prevCharIsUpper = YES;
	NSUInteger lastCopiedCharIdx = 0;
	for (NSUInteger i = 0; i < valueLen; i++) {
		unichar const currentChar = [value characterAtIndex:i];
		if (isupper (currentChar)) {
			if (lastCopiedCharIdx + 1 < i) {
				NSUInteger const copiedCharactersCount = i - lastCopiedCharIdx - 1;
				[value getCharacters:resultCharsEnd range:NSMakeRange (lastCopiedCharIdx, copiedCharactersCount)];
				resultCharsEnd += copiedCharactersCount;
			}
			if (!prevCharIsUpper) {
				*resultCharsEnd++ = '_';
			}
			*resultCharsEnd++ = (unichar) tolower (currentChar);
			prevCharIsUpper = YES;
			lastCopiedCharIdx = i;
		} else {
			prevCharIsUpper = NO;
		}
	}
	if (lastCopiedCharIdx + 1 < valueLen) {
		NSUInteger const copiedCharactersCount = valueLen - lastCopiedCharIdx;
		[value getCharacters:resultCharsEnd range:NSMakeRange (lastCopiedCharIdx, copiedCharactersCount)];
		resultCharsEnd += copiedCharactersCount;
	}
	
	return [[NSString alloc] initWithCharactersNoCopy:resultChars length:(NSUInteger) (resultCharsEnd - resultChars) freeWhenDone:YES];
}

- (NSString *) reverseTransformedValue: (NSString *) value {
	if (!value.length) {
		return value;
	}
	
	NSUInteger const valueLen = value.length;
	unichar *const resultChars = malloc (valueLen * sizeof (unichar));
	unichar *resultCharsEnd = resultChars;
	NSUInteger lastCopiedCharIdx = 0;
	BOOL prevCharIsUnderscore = NO;
	for (NSUInteger i = 0; i < valueLen; i++) {
		unichar const currentChar = [value characterAtIndex:i];
		if (currentChar == '_') {
			if (lastCopiedCharIdx + 1 < i) {
				NSUInteger const copiedCharactersCount = i - lastCopiedCharIdx - 1;
				[value getCharacters:resultCharsEnd range:NSMakeRange (lastCopiedCharIdx, copiedCharactersCount)];
				resultCharsEnd += copiedCharactersCount;
			}
			lastCopiedCharIdx = i;
			prevCharIsUnderscore = YES;
		} else if (prevCharIsUnderscore) {
			*resultCharsEnd++ = (unichar) toupper (currentChar);
			lastCopiedCharIdx = i;
			prevCharIsUnderscore = NO;
		}
	}
	if (lastCopiedCharIdx + 1 < valueLen) {
		NSUInteger const copiedCharactersCount = valueLen - lastCopiedCharIdx;
		[value getCharacters:resultCharsEnd range:NSMakeRange (lastCopiedCharIdx, copiedCharactersCount)];
		resultCharsEnd += copiedCharactersCount;
	}
	
	return [[NSString alloc] initWithCharactersNoCopy:resultChars length:(NSUInteger) (resultCharsEnd - resultChars) freeWhenDone:YES];
}

@end

static NSValueTransformer *KBDefaultPropertyNamesTransformer = nil;

static char const KBInitializeMappingPropertiesEncoding [] = { _C_ID, _C_ID, _C_SEL, '\0' };
static char const KBInitializeMappingPropertiesCustomImplementation [] = "$_initializeMappingProperties";
static NSArray <id <KBMappingProperty>> *KBInstallProperMappingPropertiesMethodImplementation (Class clazz, SEL _cmd);
static NSArray <id <KBMappingProperty>> *KBDefaultInitializeMappingProperties (__unused Class clazz, __unused SEL _cmd) __attribute__((const));
static NSArray <id <KBMappingProperty>> *KBDefaultInitializeMappingPropertiesQueryingOriginalImplementation (Class clazz, SEL _cmd);
static NSArray <id <KBMappingProperty>> *KBDefaultInitializeMappingPropertiesIgnoringOriginalImplementation (Class clazz, SEL _cmd);

@implementation NSObject (KBAutoMapping)

+ (void) load {
	sel_registerName (KBInitializeMappingPropertiesCustomImplementation);
	class_addMethod (self, @selector (initializeMappingProperties), (IMP) KBInstallProperMappingPropertiesMethodImplementation, KBInitializeMappingPropertiesEncoding);
}

+ (BOOL) shouldAutomaticallyInitializeMappingProperties {
	return NO;
}

+ (NSValueTransformer *) defaultPropertyNamesTransformer {
	return KBDefaultPropertyNamesTransformer;
}

+ (void) setDefaultPropertyNamesTransformer: (NSValueTransformer *) defaultPropertyNamesTransformer {
	KBDefaultPropertyNamesTransformer = defaultPropertyNamesTransformer;
}

+ (BOOL) shouldAutomaticallyMapProperty: (NSString *) propertyKeyPath {
	return YES;
}

+ (NSString *) sourceKeyPathForKeyPath: (NSString *) keyPath {
	NSValueTransformer *transformer = self.defaultPropertyNamesTransformer;
	return (transformer ? (NSString *) [transformer transformedValue:keyPath] : keyPath);
}

+ (id <KBMappingProperty>) mappingPropertyForKeyPath: (NSString *) keyPath sourceKeyPath: (NSString *) sourceKeyPath {
	return nil;
}

+ (Class <KBObject>) mappedCollectionItemClassForKeyPath: (NSString *) keyPath {
	return Nil;
}

@end

static NSArray <id <KBMappingProperty>> *KBInstallProperMappingPropertiesMethodImplementation (Class const clazz, SEL const _cmd) {
	static Class NSObjectClass = Nil;
	static SEL customImplementationSel = NULL;
	static dispatch_once_t onceToken;
	dispatch_once (&onceToken, ^{
		NSObjectClass = [NSObject class];
		customImplementationSel = sel_registerName (KBInitializeMappingPropertiesCustomImplementation);
	});
	if (clazz == NSObjectClass) {
		return nil;
	}
	
	Class const metaclass = object_getClass (clazz);
	BOOL const useAutoInitialization = [clazz shouldAutomaticallyInitializeMappingProperties];
	if (useAutoInitialization) {
		if (!class_addMethod (metaclass, _cmd, (IMP) KBDefaultInitializeMappingPropertiesIgnoringOriginalImplementation, KBInitializeMappingPropertiesEncoding)) {
			Method const existingMethod = class_getClassMethod (metaclass, _cmd);
			class_addMethod (metaclass, customImplementationSel, method_getImplementation (existingMethod), method_getTypeEncoding (existingMethod));
			method_setImplementation (existingMethod, (IMP) KBDefaultInitializeMappingPropertiesQueryingOriginalImplementation);
		}
	} else {
		if (!class_addMethod (clazz, _cmd, (IMP) KBDefaultInitializeMappingProperties, KBInitializeMappingPropertiesEncoding)) {
			Method const existingMethod = class_getClassMethod (metaclass, _cmd);
			method_setImplementation (existingMethod, (IMP) KBDefaultInitializeMappingProperties);
		}
	}

	return [clazz initializeMappingProperties];
}

static NSArray <id <KBMappingProperty>> *KBDefaultInitializeMappingProperties (__unused Class const clazz, __unused SEL const _cmd) {
	return nil;
}

NS_INLINE NSArray <id <KBMappingProperty>> *KBAutomaticallyFindMappingProperties (Class const clazz, __unused SEL const _cmd, BOOL const queryOriginalImplementation) {
	static NSArray <id <KBMappingProperty>> *(*const objc_msgSend_customImpl) (Class, SEL) = (id (*) (Class, SEL)) objc_msgSend;
	unsigned propertiesCount = 0;
	objc_property_t *const properties = class_copyPropertyList (clazz, &propertiesCount);
	KBArray <id <KBMappingProperty>> *mappingProperties = nil;
	
	if (queryOriginalImplementation) {
		NSArray <id <KBMappingProperty>> *originalMappingProperties = objc_msgSend_customImpl (clazz, sel_registerName (KBInitializeMappingPropertiesCustomImplementation));
		mappingProperties = [KBArray kb_unsealedArrayWithCapacity:originalMappingProperties.count + propertiesCount];
		for (id <KBMappingProperty> mappingProperty in originalMappingProperties) {
			[mappingProperties kb_addObject:mappingProperty];
		}
	} else {
		mappingProperties = [KBArray kb_unsealedArrayWithCapacity:propertiesCount];
	}
	
	for (unsigned i = 0; i < propertiesCount; i++) {
		char const *const propertyName = property_getName (properties [i]);
		char *const readonlyValue = property_copyAttributeValue (properties [i], "R");
		BOOL const isReadonly = !!readonlyValue;
		free (readonlyValue);
		if (isReadonly) {
			continue;
		}
		
		NSString *const keyPath = @(propertyName);
		if (![clazz shouldAutomaticallyMapProperty:keyPath]) {
			continue;
		}
		NSString *const sourceKeyPath = [clazz sourceKeyPathForKeyPath:keyPath];
		
		id <KBMappingProperty> mappingProperty = [clazz mappingPropertyForKeyPath:keyPath sourceKeyPath:sourceKeyPath];
		if (mappingProperty) {
			[mappingProperties kb_addObject:mappingProperty];
			continue;
		}
		
		char *const propertyType = property_copyAttributeValue (properties [i], "T");
		switch (*propertyType) {
			case _C_CHR: case _C_UCHR:
			case _C_SHT: case _C_USHT:
			case _C_INT: case _C_UINT:
			case _C_LNG: case _C_ULNG:
			case _C_LNG_LNG: case _C_ULNG_LNG:
			case _C_FLT: case _C_DBL: case _C_BFLD:
			case _C_BOOL:
				mappingProperty = [[KBNumberMappingProperty alloc] initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath];
				break;
			
			case _C_ID: {
				unsigned long const typeLength = strlen (propertyType);
				if (!((typeLength > 3) && (propertyType [1] == '"') && (propertyType [typeLength - 1] == '"'))) {
					break;
				}
				propertyType [typeLength - 1] = '\0';
				Class const valueClass = objc_getClass (propertyType + 2);
				if (!valueClass) {
					break;
				}
				
				if ([valueClass isSubclassOfClass:[NSNumber class]]) {
					mappingProperty = [[KBNumberMappingProperty alloc] initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath];
				} else if ([valueClass isSubclassOfClass:[NSString class]]) {
					mappingProperty = [[KBStringMappingProperty alloc] initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath];
				} else if ([valueClass isSubclassOfClass:[NSURL class]]) {
					mappingProperty = [[KBURLMappingProperty alloc] initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath];
				} else if ([valueClass isSubclassOfClass:[NSDate class]]) {
					mappingProperty = [[KBTimestampMappingProperty alloc] initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath];
				} else if ([valueClass isSubclassOfClass:[NSArray class]]) {
					Class const itemClass = [clazz mappedCollectionItemClassForKeyPath:keyPath];
					if ([itemClass isSubclassOfClass:[NSString class]]) {
						mappingProperty = [[KBStringArrayMappingProperty alloc] initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath];
					} else if (itemClass) {
						mappingProperty = [[KBArrayMappingProperty alloc] initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath itemClass:itemClass];
					}
				} else if ([valueClass isSubclassOfClass:[NSSet class]]) {
					Class const itemClass = [clazz mappedCollectionItemClassForKeyPath:keyPath];
					mappingProperty = [[KBSetMappingProperty alloc] initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath itemClass:itemClass];
				} else if ([valueClass isSubclassOfClass:[NSOrderedSet class]]) {
					Class const itemClass = [clazz mappedCollectionItemClassForKeyPath:keyPath];
					mappingProperty = [[KBOrderedSetMappingProperty alloc] initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath itemClass:itemClass];
				} else if ([valueClass conformsToProtocol:@protocol (KBObject)]) {
					mappingProperty = [[KBObjectMappingProperty alloc] initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath valueClass:valueClass];
				}
			} break;
		}
		
		free (propertyType);
		[mappingProperties kb_addObject:mappingProperty];
	}
	
	free (properties);
	[mappingProperties kb_sealArray];
	
	NSArray <id <KBMappingProperty>> *superProperties = [class_getSuperclass (clazz) mappingProperties];
	if (superProperties.count) {
		return [superProperties arrayByAddingObjectsFromArray:mappingProperties];
	} else {
		return mappingProperties;
	}
}

static NSArray <id <KBMappingProperty>> *KBDefaultInitializeMappingPropertiesQueryingOriginalImplementation (Class const clazz, __unused SEL const _cmd) {
	return KBAutomaticallyFindMappingProperties (clazz, _cmd, YES);
}

static NSArray <id <KBMappingProperty>> *KBDefaultInitializeMappingPropertiesIgnoringOriginalImplementation (Class const clazz, __unused SEL const _cmd) {
	return KBAutomaticallyFindMappingProperties (clazz, _cmd, NO);
}
