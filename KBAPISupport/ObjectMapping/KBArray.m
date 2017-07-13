//
//  KBArray.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 4/1/16.
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

#import "KBArray_Protected.h"

@interface KBArray0: KBArrayBase
@end
@interface KBArray2: KBArrayBase
@end
@interface KBArray6: KBArrayBase
@end
@interface KBArray14: KBArrayBase
@end
@interface KBArray30: KBArrayBase
@end
@interface KBArray62: KBArrayBase
@end
#if __LP64__
@interface KBArray126: KBArrayBase
@end
@interface KBArray254: KBArrayBase
@end
@interface KBArray510: KBArrayBase
@end
#endif

#pragma mark - Facade implementation

@interface KBArrayBase () {
	NSUInteger _count;
}

@property (nonatomic, readonly, class, getter = kb_isMutable) BOOL kb_mutable;
@property (nonatomic, readonly, nullable) Class kb_classForMutableCopying;
@property (nonatomic, readonly, nullable) Class kb_classForImmutableCopying;

- (instancetype) initWithCapacity: (NSUInteger) capacity NS_DESIGNATED_INITIALIZER;
- (__strong id *) kb_storage NS_RETURNS_INNER_POINTER;

@end

@implementation KBArrayBase

#pragma mark - Memory management

+ (instancetype) allocArrayWithCapacity: (NSUInteger) capacity {
	if ((self == [KBArrayBase class]) || (self == [KBArray class])) { // Plain KBArrayBase/KBArray, may instantiate specialized subclass
		switch (capacity) {
			case 0:
				return [KBArray0 alloc];
			case 1 ... 2:
				return [KBArray2 alloc];
			case 3 ... 6:
				return [KBArray6 alloc];
			case 7 ... 14:
				return [KBArray14 alloc];
			case 15 ... 30:
				return [KBArray30 alloc];
			case 31 ... 62:
				return [KBArray62 alloc];
#if __LP64__
			case 63 ... 126:
				return [KBArray126 alloc];
			case 127 ... 254:
				return [KBArray254 alloc];
			case 255 ... 510:
				return [KBArray510 alloc];
#endif
		}
	}
	
	return [self alloc];
}

+ (instancetype) allocWithZone: (struct _NSZone *) zone {
	if (self == [KBArrayBase class]) {
		return [KBArray allocWithZone:zone];
	}
	
	return [super allocWithZone:zone];
}

- (instancetype) initWithCapacity: (NSUInteger) capacity {
	// Actual storage is allocated by subclasses
	return [super init];
}

#pragma mark - Protected interface

+ (BOOL) kb_isMutable {
	return NO;
}

+ (instancetype) kb_unsealedArrayWithCapacity: (NSUInteger) capacity {
	return [(KBArrayBase *) [self allocArrayWithCapacity:capacity] initWithCapacity:capacity];
}

- (Class) kb_classForMutableCopying {
	return [NSMutableArray class];
}

- (Class) kb_classForImmutableCopying {
	return Nil;
}

- (__strong id *) kb_storage {
	[self doesNotRecognizeSelector:_cmd];
	return NULL; // To make compiler happy
}

- (void) kb_sealArray {
	// Nothing needs to be done here
}

#pragma mark - NSArray interface

+ (instancetype) arrayWithObjects: (__unsafe_unretained const id *) objects count: (NSUInteger) cnt {
	return [[self allocArrayWithCapacity:cnt] initWithObjects:objects count:cnt];
}

- (instancetype) init {
	return [self initWithCapacity:0];
}

- (instancetype) initWithObjects: (__unsafe_unretained id const []) objects count: (NSUInteger) cnt {
	if (self = [self initWithCapacity:cnt]) {
		if (self.kb_capacity < cnt) {
			[NSException raise:NSInvalidArgumentException format:@"%@ instance has insufficient capacity (%ld) to be initialized with %ld objects", self.class, (long) self.kb_capacity, (long) cnt];
		}
		
		[self kb_addObjects:objects count:cnt];
	}
	
	return self;
}

- (NSUInteger) count {
	return _count;
}

- (id) objectAtIndex: (NSUInteger) index {
	return self.kb_storage [index];
}

- (void) getObjects: (__unsafe_unretained id  _Nonnull *) objects range: (NSRange) range {
	memcpy (objects, (void const *) self.kb_storage + range.location, range.length * sizeof (id));
}

#pragma mark - NSArray protocols conformance (NSCoding, NSCopying, NSMutableCopying)

- (instancetype) initWithCoder: (NSCoder *) aDecoder {
	NSArray *objects = [[NSArray alloc] initWithCoder:aDecoder];
	if (!objects) {
		return nil;
	}
	
	self = [self.class allocArrayWithCapacity:objects.count];
	return [self initWithArray:objects];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[[[NSArray alloc] initWithObjects:self.kb_storage count:self.count] encodeWithCoder:aCoder];
}

- (id) copyWithZone: (NSZone *) zone {
	if ([self.class kb_isMutable]) {
		NSAssert (self.kb_classForImmutableCopying, @"Cannot create immutable copy: kb_classForImmutableCopying is nil");
		return [[self.kb_classForImmutableCopying alloc] initWithArray:self];
	}
	
	return self;
}

- (id) mutableCopyWithZone: (NSZone *) zone {
	NSAssert (self.kb_classForMutableCopying, @"Cannot create mutable copy: kb_classForMutableCopying is nil");
	return [[self.kb_classForMutableCopying alloc] initWithArray:self];
}

#pragma mark - KBObject conformance

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
+ (instancetype) objectFromJSON: (id) JSON mappingContext: (id) mappingContext {
	return [self objectFromJSON:JSON mappingContext:mappingContext itemClass:self.itemClass];
}

+ (instancetype) objectFromJSON: (NSArray *) JSON mappingContext: (id) mappingContext itemClass: (Class) itemClass {
	if (![itemClass conformsToProtocol:@protocol (KBObject)]) {
		return nil;
	}
	if (![JSON isKindOfClass:[NSArray class]]) {
		return nil;
	}
	
	KBArray *result = [self kb_unsealedArrayWithCapacity:JSON.count];
	for (id arrayItem in JSON) {
		[result kb_addObject:[itemClass objectFromJSON:arrayItem mappingContext:mappingContext]];
	}
	[result kb_sealArray];
	return result;
}
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
+ (instancetype) objectFromXML: (GDataXMLElement *) XML mappingContext: (id) mappingContext {
	[self doesNotRecognizeSelector:_cmd];
	return [self objectFromXML:XML mappingContext:mappingContext itemClass:self.itemClass];
}

+ (instancetype) objectFromXML: (GDataXMLElement *) XML mappingContext: (id) mappingContext itemClass: (Class) itemClass {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}
#endif

#pragma mark - KBCollection conformance

+ (Class) itemClass {
	[self doesNotRecognizeSelector:_cmd];
	return self; // To make compiler happy
}

#pragma mark - KBCollection_Protected conformance

+ (instancetype) kb_unsealedCollectionWithCapacity: (NSUInteger) capacity {
	return [self kb_unsealedArrayWithCapacity:capacity];
}

- (NSUInteger) kb_capacity {
	[self doesNotRecognizeSelector:_cmd];
	return 0; // To make compiler happy
}

- (void) kb_addObject: (id) object {
	if (self.count >= self.kb_capacity) {
		[NSException raise:NSRangeException format:@"Array capacity (%ld) exceeded", (long) self.kb_capacity];
	}
	
	if (!object) {
		return;
	}
	
	self.kb_storage [_count++] = object;
}

- (void) kb_addObjects: (__unsafe_unretained id const _Nonnull [_Nullable]) objects count: (NSUInteger) count {
	__unsafe_unretained id const *const objectsEnd = objects + count;
	for (__unsafe_unretained id const *objectPtr = objects; objectPtr < objectsEnd; objectPtr++) {
		[self kb_addObject:*objectPtr];
	}
}

- (void) kb_sealCollection {
	[self kb_sealArray];
}

@end

#pragma mark - Fallback/subclassable implementation

@interface KBArray () {
	NSUInteger _capacity;
	__strong id *_storage;
}

@end

@implementation KBArray

@dynamic kb_classForImmutableCopying;

+ (BOOL) kb_isMutable {
	return NO;
}

- (instancetype) init {
	return [self initWithCapacity:0];
}

- (instancetype) initWithCoder: (NSCoder *) aDecoder {
	NSArray *objects = [[NSArray alloc] initWithCoder:aDecoder];
	return (objects ? [self initWithArray:objects] : nil);
}

- (instancetype) initWithObjects: (__unsafe_unretained id const []) objects count: (NSUInteger) cnt {
	if (self = [self initWithCapacity:cnt]) {
		[self kb_addObjects:objects count:cnt];
	}
	
	return self;
}

- (instancetype) initWithCapacity: (NSUInteger) capacity {
	if (self = [super initWithCapacity:capacity]) {
		_capacity = capacity;
		if (_capacity) {
			_storage = (__strong id *) calloc (capacity, sizeof (id));
		}
	}
	
	return self;
}

- (void) dealloc {
	NSUInteger const count = self.count;
	for (NSUInteger i = 0; i < count; i++) {
		_storage [i] = nil;
	}
	
	free (_storage);
}

- (Class) kb_classForMutableCopying {
	if (self.class == [KBArray class]) {
		return [super kb_classForMutableCopying];
	}
	
	return Nil;
}

- (NSUInteger) kb_capacity {
	return _capacity;
}

- (__strong id *) kb_storage {
	return _storage;
}

@end

#pragma mark - Empty implementation

#define KBArrayCommonSized(size) \
	- (NSUInteger) kb_capacity { \
		return size; \
	} \
	\
	- (Class) classForCoder { \
		return [KBArrayBase class]; \
	}

@implementation KBArray0

+ (instancetype) new {
	static KBArray0 *instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once (&onceToken, ^{
		instance = [super new];
	});
	
	return instance;
}

- (__strong id *) kb_storage {
	return NULL;
}

KBArrayCommonSized (0)

@end

#pragma mark - Implementations with inline storage

#define KBArraySized(size) \
	@implementation KBArray ## size { \
		__strong id _storage [size]; \
	} \
  \
	- (void) dealloc { \
		NSUInteger const count = self.count; \
		for (NSUInteger i = 0; i < count; i++) { \
			_storage [i] = nil; \
		} \
	} \
	 \
	- (__strong id *) kb_storage { \
		return _storage; \
	} \
	\
	KBArrayCommonSized (size) \
	\
	@end

KBArraySized (2);
KBArraySized (6);
KBArraySized (14);
KBArraySized (30);
KBArraySized (62);
#if __LP64__
KBArraySized (126);
KBArraySized (254);
KBArraySized (510);
#endif
