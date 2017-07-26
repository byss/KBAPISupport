//
//  KBMappingProperty.m
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

#import "KBMappingProperty.h"

#import <objc/runtime.h>

#import "KBArray.h"
#import "KBObject.h"

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>) || __has_include (<KBAPISupport/KBAPISupport+XML.h>)
@interface NSObject (safeNilValues)

- (void) safeSetNilNumberValueForKeyPath: (NSString *) keyPath;

@end

@interface KBStringProxy: NSString <KBObject>
@end

NS_INLINE NSString *KBStringValueImpl (id object);
NS_INLINE NSNumber *KBNumberValueImpl (id object);
#endif

@implementation KBMappingProperty

@synthesize objectKeyPath = _objectKeyPath;
@synthesize sourceKeyPath = _sourceKeyPath;

+ (instancetype _Nullable) mappingPropertyWithKeyPath: (NSString *_Nonnull) keyPath {
	return [[self alloc] initWithKeyPath:keyPath];
}

+ (instancetype _Nullable) mappingPropertyWithKeyPath: (NSString *_Nonnull) keyPath sourceKeyPath: (NSString *_Nullable) sourceKeyPath {
	return [[self alloc] initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath];
}

- (instancetype) init {
	NSString *keyPath = nil;
	return [self initWithKeyPath:(id _Nonnull) keyPath sourceKeyPath:nil];
}

- (instancetype _Nullable) initWithKeyPath: (NSString *_Nonnull) keyPath {
	return [self initWithKeyPath:keyPath sourceKeyPath:nil];
}

- (instancetype _Nullable) initWithKeyPath: (NSString *_Nonnull) keyPath sourceKeyPath: (NSString *_Nullable) sourceKeyPath {
	if (!keyPath) {
		return nil;
	}
	
	if (self = [super init]) {
		_objectKeyPath = [keyPath copy];
		_sourceKeyPath = (NSString *) [(sourceKeyPath ?: keyPath) copy];
	}
	
	return self;
}

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
- (void)setValueInObject:(NSObject *)object fromJSONObject:(id)JSONObject mappingContext: (id _Nullable) mappingContext {
	[object setValue:[JSONObject JSONValueForKeyPath:self.sourceKeyPath] forKeyPath:self.objectKeyPath];
}
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
- (void) setValueInObject: (NSObject *_Nonnull) object fromXMLObject: (GDataXMLElement * _Nullable) XMLObject mappingContext: (id _Nullable) mappingContext {
	// TODO
	[self doesNotRecognizeSelector:_cmd];
}
#endif

@end

@implementation KBStringMappingProperty

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
- (void)setValueInObject:(NSObject *)object fromJSONObject:(id)JSONObject mappingContext: (id _Nullable) mappingContext {
	NSString *stringValue = KBStringValueImpl ([JSONObject JSONValueForKeyPath:self.sourceKeyPath]);
	[object setValue:stringValue forKeyPath:self.objectKeyPath];
}
#endif

@end

@implementation KBStringArrayMappingProperty

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
- (void) setValueInObject:(NSObject *)object fromJSONObject:(id)JSONObject mappingContext: (id _Nullable) mappingContext {
	id value = [JSONObject JSONValueForKeyPath:self.sourceKeyPath];
	NSArray *arrayValue = [KBArray arrayFromJSON:value mappingContext:mappingContext itemClass:[KBStringProxy class]];
	[object setValue:arrayValue forKeyPath:self.objectKeyPath];
}
#endif

@end

@implementation KBURLMappingProperty

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
- (void)setValueInObject:(NSObject *)object fromJSONObject:(id)JSONObject mappingContext: (id _Nullable) mappingContext {
	NSString *stringValue = KBStringValueImpl ([JSONObject JSONValueForKeyPath:self.sourceKeyPath]);
	NSURL *URLValue = (stringValue ? [[NSURL alloc] initWithString:stringValue] : nil);
	[object setValue:URLValue forKeyPath:self.objectKeyPath];
}
#endif

@end

@interface KBEnumMappingProperty ()

@property (nonatomic, readonly) NSDictionary <NSString *, NSNumber *> *enumValues;

@end

@implementation KBEnumMappingProperty

+ (instancetype _Nullable) mappingPropertyWithKeyPath: (NSString *_Nonnull) keyPath enumValues: (NSDictionary <NSString *, NSNumber *> *_Nonnull) enumValues {
	return [[self alloc] initWithKeyPath:keyPath enumValues:enumValues];
}

+ (instancetype _Nullable) mappingPropertyWithKeyPath: (NSString *_Nonnull) keyPath sourceKeyPath: (NSString *_Nullable) sourceKeyPath enumValues: (NSDictionary <NSString *, NSNumber *> *_Nonnull) enumValues {
	return [[self alloc] initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath enumValues:enumValues];
}

- (instancetype)initWithKeyPath:(NSString *)keyPath sourceKeyPath:(NSString *)sourceKeyPath {
	NSDictionary *enumValues = nil;
	return [self initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath enumValues:enumValues];
}

- (instancetype _Nullable) initWithKeyPath: (NSString *_Nonnull) keyPath enumValues: (NSDictionary <NSString *, NSNumber *> *_Nonnull) enumValues {
	return [self initWithKeyPath:keyPath sourceKeyPath:nil enumValues:enumValues];
}

- (instancetype _Nullable) initWithKeyPath: (NSString *_Nonnull) keyPath sourceKeyPath: (NSString *_Nullable) sourceKeyPath enumValues: (NSDictionary <NSString *, NSNumber *> *_Nonnull) enumValues {
	if (!enumValues.count) {
		return nil;
	}
	
	if (self = [super initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath]) {
		_enumValues = [enumValues copy];
	}
	
	return self;
}

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
- (void)setValueInObject:(NSObject *)object fromJSONObject:(id)JSONObject mappingContext: (id _Nullable) mappingContext {
	NSString *stringValue = KBStringValueImpl ([JSONObject JSONValueForKeyPath:self.sourceKeyPath]);
	NSNumber *enumValue = (stringValue ? self.enumValues [stringValue] : nil);
	if (enumValue) {
		[object setValue:enumValue forKeyPath:self.objectKeyPath];
	} else {
		[object safeSetNilNumberValueForKeyPath:self.objectKeyPath];
	}
}
#endif

@end

@implementation KBNumberMappingProperty

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
- (void)setValueInObject:(NSObject *)object fromJSONObject:(id)JSONObject mappingContext: (id _Nullable) mappingContext {
	NSNumber *numberValue = KBNumberValueImpl ([JSONObject JSONValueForKeyPath:self.sourceKeyPath]);
	if (numberValue) {
		[object setValue:numberValue forKeyPath:self.objectKeyPath];
	} else {
		[object safeSetNilNumberValueForKeyPath:self.objectKeyPath];
	}
}
#endif

@end

@implementation KBTimestampMappingProperty

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
- (void)setValueInObject:(NSObject *)object fromJSONObject:(id)JSONObject mappingContext: (id _Nullable) mappingContext {
	NSNumber *numberValue = KBNumberValueImpl ([JSONObject JSONValueForKeyPath:self.sourceKeyPath]);
	NSDate *dateValue = (numberValue ? [[NSDate alloc] initWithTimeIntervalSince1970:numberValue.doubleValue] : nil);
	[object setValue:dateValue forKeyPath:self.objectKeyPath];
}
#endif

@end

@interface KBMappingPropertyWithBlock ()

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
@property (nonatomic, readonly) void (^JSONMappingBlock) (NSObject *object, id JSONObject, id _Nullable mappingContext);
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
@property (nonatomic, readonly) void (^XMLMappingBlock) (NSObject *object, GDataXMLElement *XMLObject, id _Nullable mappingContext);
#endif

@end

@implementation KBMappingPropertyWithBlock

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
+ (instancetype _Nullable) mappingPropertyWithKeyPath: (NSString *_Nonnull) keyPath JSONMappingBlock: (void (^_Nonnull) (NSObject *_Nonnull object, id _Nullable JSON, id _Nullable mappingContext)) JSONMappingBlock {
	return [[self alloc] initWithKeyPath:keyPath JSONMappingBlock:JSONMappingBlock];
}

+ (instancetype _Nullable) mappingPropertyWithKeyPath: (NSString *_Nonnull) keyPath sourceKeyPath: (NSString *_Nullable) sourceKeyPath JSONMappingBlock: (void (^_Nonnull) (NSObject *_Nonnull object, id _Nullable JSON, id _Nullable mappingContext)) JSONMappingBlock {
	return [[self alloc] initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath JSONMappingBlock:JSONMappingBlock];
}

- (instancetype)initWithKeyPath:(NSString *)keyPath sourceKeyPath:(NSString *)sourceKeyPath {
	void (^JSONMappingBlock) (NSObject *, id, id) = NULL;
	return [self initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath JSONMappingBlock:JSONMappingBlock];
}

- (instancetype _Nullable) initWithKeyPath: (NSString *_Nonnull) keyPath JSONMappingBlock: (void (^_Nonnull) (NSObject *_Nonnull object, id _Nullable JSON, id _Nullable mappingContext)) JSONMappingBlock {
	return [self initWithKeyPath:keyPath sourceKeyPath:nil JSONMappingBlock:JSONMappingBlock];
}

- (instancetype _Nullable) initWithKeyPath: (NSString *_Nonnull) keyPath sourceKeyPath: (NSString *_Nullable) sourceKeyPath JSONMappingBlock: (void (^_Nonnull) (NSObject *_Nonnull object, id _Nullable JSON, id _Nullable mappingContext)) JSONMappingBlock {
	if (!JSONMappingBlock) {
		return nil;
	}
	
	if (self = [super initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath]) {
		_JSONMappingBlock = [JSONMappingBlock copy];
	}
	
	return self;
}

- (void)setValueInObject:(NSObject *)object fromJSONObject:(id)JSONObject mappingContext: (id _Nullable) mappingContext {
	self.JSONMappingBlock (object, JSONObject, mappingContext);
}
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
+ (instancetype _Nullable) mappingPropertyWithKeyPath: (NSString *_Nonnull) keyPath XMLMappingBlock: (void (^_Nonnull) (NSObject *_Nonnull object, GDataXMLElement *_Nullable XML, id _Nullable mappingContext)) XMLMappingBlock {
	return [[self alloc] initWithKeyPath:keyPath XMLMappingBlock:XMLMappingBlock];
}

+ (instancetype _Nullable) mappingPropertyWithKeyPath: (NSString *_Nonnull) keyPath sourceKeyPath: (NSString *_Nullable) sourceKeyPath XMLMappingBlock: (void (^_Nonnull) (NSObject *_Nonnull object, GDataXMLElement *_Nullable XML, id _Nullable mappingContext)) XMLMappingBlock {
	return [[self alloc] initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath XMLMappingBlock:XMLMappingBlock];
}

- (instancetype)initWithKeyPath:(NSString *)keyPath sourceKeyPath:(NSString *)sourceKeyPath {
	void (^JSONMappingBlock) (NSObject *, GDataXMLElement *, id) = NULL;
	return [self initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath XMLMappingBlock:XMLMappingBlock];
}

- (instancetype _Nullable) initWithKeyPath: (NSString *_Nonnull) keyPath XMLMappingBlock: (void (^_Nonnull) (NSObject *_Nonnull object, GDataXMLElement *_Nullable XML, id _Nullable mappingContext)) XMLMappingBlock {
	return [self initWithKeyPath:keyPath sourceKeyPath:nil XMLMappingBlock:XMLMappingBlock];
}

- (instancetype _Nullable) initWithKeyPath: (NSString *_Nonnull) keyPath sourceKeyPath: (NSString *_Nullable) sourceKeyPath XMLMappingBlock: (void (^_Nonnull) (NSObject *_Nonnull object, GDataXMLElement *_Nullable XML, id _Nullable mappingContext)) XMLMappingBlock {
	if (!XMLMappingBlock) {
		return nil;
	}
	
	if (self = [super initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath]) {
		_XMLMappingBlock = [XMLMappingBlock copy];
	}
	
	return self;
}

- (void) setValueInObject: (NSObject *) object fromXMLObject: (GDataXMLElement *) XMLObject mappingContext: (id _Nullable) mappingContext {
	self.XMLMappingBlock (object, XMLObject, mappingContext);
}
#endif

@end

@interface KBObjectMappingProperty ()

@property (nonatomic, unsafe_unretained) Class valueClass;

@end

@implementation KBObjectMappingProperty

+ (instancetype _Nullable) mappingPropertyWithKeyPath:(NSString *_Nonnull) keyPath valueClass: (Class _Nonnull) valueClass {
	return [[self alloc] initWithKeyPath:keyPath valueClass:valueClass];
}

+ (instancetype _Nullable) mappingPropertyWithKeyPath:(NSString *_Nonnull) keyPath sourceKeyPath:(NSString * _Nullable)sourceKeyPath valueClass: (Class _Nonnull) valueClass {
	return [[self alloc] initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath valueClass:valueClass];
}

- (instancetype)initWithKeyPath:(NSString *)keyPath sourceKeyPath:(NSString *)sourceKeyPath {
	Class valueClass = NULL;
	return [self initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath valueClass:(id _Nonnull) valueClass];
}

- (instancetype _Nullable) initWithKeyPath:(NSString *_Nonnull) keyPath valueClass: (Class _Nonnull) valueClass {
	return [self initWithKeyPath:keyPath sourceKeyPath:nil valueClass:valueClass];
}

- (instancetype _Nullable) initWithKeyPath:(NSString *_Nonnull) keyPath sourceKeyPath:(NSString * _Nullable)sourceKeyPath valueClass: (Class _Nonnull) valueClass {
	if (![valueClass conformsToProtocol:@protocol (KBObject)]) {
		return nil;
	}
	
	if (self = [super initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath]) {
		_valueClass = valueClass;
	}
	
	return self;
}

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
- (void)setValueInObject:(NSObject *)object fromJSONObject:(id)JSONObject mappingContext: (id _Nullable) mappingContext {
	id JSONValue = [JSONObject JSONValueForKeyPath:self.sourceKeyPath];
	id <KBObject> objectValue = [self.valueClass objectFromJSON:JSONValue mappingContext:mappingContext];
	[object setValue:objectValue forKeyPath:self.objectKeyPath];
}
#endif

@end

@interface KBCollectionMappingProperty ()

@property (nonatomic, unsafe_unretained) Class itemClass;

+ (id) collectionValueWithArrayValue: (NSArray *) arrayValue;

@end

@implementation KBCollectionMappingProperty

+ (instancetype _Nullable) mappingPropertyWithKeyPath:(NSString *_Nonnull) keyPath itemClass: (Class _Nonnull) itemClass {
	return [[self alloc] initWithKeyPath:keyPath itemClass:itemClass];
}

+ (instancetype _Nullable) mappingPropertyWithKeyPath:(NSString *_Nonnull) keyPath sourceKeyPath:(NSString * _Nullable)sourceKeyPath itemClass: (Class _Nonnull) itemClass {
	return [[self alloc] initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath itemClass:itemClass];
}

+ (id) collectionValueWithArrayValue: (NSArray *) arrayValue {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (instancetype) initWithKeyPath:(NSString *)keyPath sourceKeyPath:(NSString *)sourceKeyPath {
	Class itemClass = NULL;
	return [self initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath itemClass:(id _Nonnull) itemClass];
}

- (instancetype _Nullable) initWithKeyPath:(NSString *_Nonnull) keyPath itemClass: (Class _Nonnull) itemClass {
	return [self initWithKeyPath:keyPath sourceKeyPath:nil itemClass:itemClass];
}

- (instancetype _Nullable) initWithKeyPath:(NSString *_Nonnull) keyPath sourceKeyPath:(NSString * _Nullable)sourceKeyPath itemClass: (Class _Nonnull) itemClass {
	if (![itemClass conformsToProtocol:@protocol (KBObject)]) {
		return nil;
	}
	
	if (self = [super initWithKeyPath:keyPath sourceKeyPath:sourceKeyPath]) {
		_itemClass = itemClass;
	}
	
	return self;
}

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
- (void) setValueInObject:(NSObject *)object fromJSONObject:(id)JSONObject mappingContext: (id _Nullable) mappingContext {
	id value = [JSONObject JSONValueForKeyPath:self.sourceKeyPath];
	NSArray *arrayValue = [KBArray arrayFromJSON:value mappingContext:mappingContext itemClass:self.itemClass];
	id collectionValue = [self.class collectionValueWithArrayValue:arrayValue];
	[object setValue:collectionValue forKeyPath:self.objectKeyPath];
}
#endif

@end

@implementation KBArrayMappingProperty

+ (id) collectionValueWithArrayValue: (NSArray *) arrayValue {
	return arrayValue;
}

@end

@implementation KBSetMappingProperty

+ (id) collectionValueWithArrayValue: (NSArray *) arrayValue {
	return [[NSSet alloc] initWithArray:arrayValue];
}

@end

@implementation KBOrderedSetMappingProperty

+ (id) collectionValueWithArrayValue: (NSArray *) arrayValue {
	return [[NSOrderedSet alloc] initWithArray:arrayValue];
}

@end

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
@implementation NSObject (KBJSONMapping)

- (id) JSONValueForUnescapedKey: (NSString *) unescapedKey {
	if ([unescapedKey hasPrefix:@"@"]) {
		NSString *funcName = [unescapedKey substringFromIndex:1];
		if ([funcName isEqualToString:@"first"] && [self isKindOfClass:[NSArray class]]) {
			return [(NSArray *) self firstObject];
		} else if ([funcName isEqualToString:@"last"] && [self isKindOfClass:[NSArray class]]) {
			return [(NSArray *) self lastObject];
		} else if ([funcName isEqualToString:@"any"]) {
			if ([self isKindOfClass:[NSArray class]]) {
				NSArray *array = (NSArray *) self;
				if (array.count > 1) {
					return array [arc4random_uniform ((u_int32_t) array.count)];
				} else {
					return array.firstObject;
				}
			}
			if ([self isKindOfClass:[NSDictionary class]]) {
				NSDictionary *dict = (NSDictionary *) self;
				NSArray *keys = dict.allKeys;
				if (keys.count > 1) {
					return dict [keys [arc4random_uniform ((u_int32_t) keys.count)]];
				} else if (keys.count == 1) {
					id key = keys.firstObject;
					return dict [key];
				} else {
					return nil;
				}
			}
		}
	}
	
	if ([unescapedKey hasPrefix:@"#"] && [self isKindOfClass:[NSArray class]]) {
		NSArray *array = (NSArray *) self;
		NSString *indexString = [unescapedKey substringFromIndex:1];
		if (indexString.length && ([indexString rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound)) {
			NSUInteger index = (NSUInteger) [indexString integerValue];
			if (index < array.count) {
				return array [index];
			} else {
				return nil;
			}
		}
	}
	
	if ([self isKindOfClass:[NSDictionary class]]) {
		return ((NSDictionary *) self) [unescapedKey];
	} else {
		@try {
			return [self valueForKey:unescapedKey];
		}
		@catch (NSException *e) {
			return nil;
		}
	}
}

- (id) JSONValueForKey: (NSString *) key {
	return [self JSONValueForUnescapedKey:[key stringByReplacingOccurrencesOfString:@"\\." withString:@"."]];
}

- (id)JSONValueForKeyPath:(NSString *) keyPath {
	if (!keyPath.length) {
		return self;
	}
	
	if ([keyPath rangeOfString:@"."].location == NSNotFound) {
		return [self JSONValueForUnescapedKey:keyPath];
	}
	
	static NSRegularExpression *keyRE = nil;
	static dispatch_once_t onceToken;
	dispatch_once (&onceToken, ^{
		keyRE = [[NSRegularExpression alloc] initWithPattern:@"^(.+?)(?<!\\\\)\\.|^(.+)$" options:(NSRegularExpressionOptions) 0 error:NULL];
	});
	
	NSTextCheckingResult *keyResult = [keyRE firstMatchInString:keyPath options:(NSMatchingOptions) 0 range:NSMakeRange (0, keyPath.length)];
	NSRange keyRange = NSMakeRange (NSNotFound, 0);
	if (keyResult) {
		if ([keyResult rangeAtIndex:1].location != NSNotFound) {
			keyRange = [keyResult rangeAtIndex:1];
		} else if ([keyResult rangeAtIndex:2].location != NSNotFound) {
			keyRange = [keyResult rangeAtIndex:2];
		}
	}
	
	if (keyRange.location != NSNotFound) {
		NSString *key = [keyPath substringWithRange:keyRange];
		id valueForKey = [self JSONValueForKey:key];
		NSString *remainingPath = [keyPath substringFromIndex:NSMaxRange (keyResult.range)];
		return [valueForKey JSONValueForKeyPath:remainingPath];
	} else {
		return nil;
	}
}

@end
#endif

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>) || __has_include (<KBAPISupport/KBAPISupport+XML.h>)
FOUNDATION_EXTERN NSString *_Nullable KBStringValue (id _Nullable object) {
	return KBStringValueImpl (object);
}

FOUNDATION_EXTERN NSNumber *_Nullable KBNumberValue (id _Nullable object) {
	return KBNumberValueImpl (object);
}

NS_INLINE NSString *KBStringValueImpl (id object) {
	if ([object isKindOfClass:[NSString class]]) {
		return object;
	} else if ([object isKindOfClass:[NSNumber class]]) {
		return [(NSNumber *) object stringValue];
	} else {
		return nil;
	}
}

NS_INLINE NSNumber *KBNumberValueImpl (id object) {
	if ([object isKindOfClass:[NSNumber class]]) {
		return object;
	} else if ([object isKindOfClass:[NSString class]]) {
		return [[NSDecimalNumber alloc] initWithString:object];
	} else {
		return nil;
	}
}

@implementation NSObject (safeNilValues)

- (void) safeSetNilNumberValueForKeyPath: (NSString *) keyPath {
	@try {
		[self setValue:nil forKeyPath:keyPath];
	}
	@catch (NSException *e) {
		if ([e.name isEqualToString:NSInvalidArgumentException]) {
			[self setValue:@0 forKeyPath:keyPath];
		} else {
			@throw e;
		}
	}
}

@end

@implementation KBStringProxy

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
+ (instancetype) objectFromJSON: (id) JSON mappingContext: (id) mappingContext {
	return (id) KBStringValueImpl (JSON);
}
#endif

@end
#endif
