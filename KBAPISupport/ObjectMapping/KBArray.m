//
//  KBArray.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 4/1/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import "KBArray.h"

#import "KBMappingProperty.h"

@interface KBArrayHelper: NSObject

@property (nonatomic, strong) NSArray *array;

@end

@interface KBArray () {
	NSArray *_backingArray;
}

@end

@implementation KBArray

+ (Class) itemClass {
	return nil;
}

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
+ (instancetype)objectFromJSON:(id)JSON {
	KBArrayHelper *helper = [KBArrayHelper new];
	KBMappingProperty *property = [[KBArrayMappingProperty alloc] initWithKeyPath:NSStringFromSelector (@selector (array)) itemClass:self.itemClass];
	[property setValueInObject:helper fromJSONObject:JSON];
	if (helper.array) {
		return [[self alloc] initWithArray:helper.array];
	} else {
		return nil;
	}
}
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
+ (instancetype) objectFromXML: (GDataXMLElement *) XML {
	[self doesNotRecognizeSelector:_cmd];
}
#endif

- (instancetype)initWithObjects:(const id  _Nonnull __unsafe_unretained *)objects count:(NSUInteger)cnt {
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
