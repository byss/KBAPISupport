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
	return (Class _Nonnull) nil;
}

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
+ (instancetype)objectFromJSON:(id)JSON mappingContext: (id _Nullable) mappingContext {
	KBArrayHelper *helper = [KBArrayHelper new];
	KBMappingProperty *property = [[KBArrayMappingProperty alloc] initWithKeyPath:@"array" sourceKeyPath:@"" itemClass:self.itemClass];
	[property setValueInObject:helper fromJSONObject:JSON mappingContext:mappingContext];
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
