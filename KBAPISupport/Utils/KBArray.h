//
//  KBArray.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/17/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KBArray <ObjectType>: NSArray <ObjectType>
@end

@interface KBArray <ObjectType> (methods)

+ (instancetype __nonnull) emptyArrayWithCapacity: (NSUInteger) capacity;

- (void) appendObject: (ObjectType __nullable) object;
- (void) appendObjects: (__unsafe_unretained ObjectType const __nonnull [__nonnull]) objects count: (NSUInteger) count;
- (void) sealArray;

@end
