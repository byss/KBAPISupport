//
//  KBArray.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 25/07/14.
//
//

#import "KBArray.h"

#import <objc/runtime.h>

#import "ARCSupport.h"
#import "KBAutoEntity.h"
#if KBAPISUPPORT_XML
#	import "GDataXMLElement+stuff.h"
#endif

static char const *const kAutoField = "auto-field";
static NSString *const kArraySourceField = @"array";

@interface KBArrayHelper: NSObject

@property (nonatomic, strong) NSArray *array;

@end

@implementation KBArray {
	NSArray *_backingArray;
}

+ (Class) entityClass {
	return nil;
}

#if KBAPISUPPORT_XML
+ (NSString *) entityTag {
	return nil;
}

#	define _ENTITY_TAG_ARG entityTag:self.entityTag
#else
#	define _ENTITY_TAG_ARG
#endif

+ (id <KBAutoField>) autoField {
	id <KBAutoField> result = objc_getAssociatedObject (self, kAutoField);
	if (__builtin_expect (!result, 0)) {
		@synchronized (self) {
			result = objc_getAssociatedObject (self, kAutoField);
			if (!result) {
				result = [KBAutoObjectArrayField autoFieldWithEntityClass:self.entityClass fieldName:kArraySourceField _ENTITY_TAG_ARG];
				objc_setAssociatedObject (self, kAutoField, result, OBJC_ASSOCIATION_RETAIN);
			}
		}
	}
	
	return result;
}

#if KBAPISUPPORT_JSON
+ (instancetype) entityFromJSON:(id)JSON {
	KBArrayHelper *helper = [KBArrayHelper new];
	id <KBAutoField> autoField = self.autoField;
	[autoField setFieldInObject:helper fromJSON:@{kArraySourceField: JSON}];
	KBArray *result = nil;
	if (helper.array) {
		result = [[self alloc] initWithArray:helper.array];
	}
	KB_RELEASE (helper);
	return KB_AUTORELEASE (result);
}
#endif

#if KBAPISUPPORT_XML
+ (instancetype) entityFromXML: (GDataXMLElement *) XML {
	KBArrayHelper *helper = [KBArrayHelper new];
	id <KBAutoField> autoField = self.autoField;
	[autoField setFieldInObject:helper fromXML:XML];
	KBArray *result = nil;
	if (helper.array) {
		result = [[self alloc] initWithArray:helper.array];
	}
	KB_RELEASE (helper);
	return KB_AUTORELEASE (result);
}
#endif

- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt {
	if (self = [super init]) {
		_backingArray = [[NSArray alloc] initWithObjects:objects count:cnt];
	}
	
	return self;
}

- (Class) classForCoder {
	return [self class];
}

- (Class) classForKeyedArchiver {
	return [self class];
}

- (id)copyWithZone:(NSZone *)zone {
	return [_backingArray copyWithZone:zone];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
	return [_backingArray mutableCopyWithZone:zone];
}

- (id) objectAtIndex:(NSUInteger)index {
	return [_backingArray objectAtIndex:index];
}

- (NSUInteger) count {
	return [_backingArray count];
}

@end

@implementation KBArrayHelper
@end
