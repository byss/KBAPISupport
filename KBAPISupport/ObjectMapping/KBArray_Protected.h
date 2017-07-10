//
//  KBArray_Protected.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/10/17.
//  Copyright © 2017 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBArray.h>
#import <KBAPISupport/KBCollection_Protected.h>

NS_ASSUME_NONNULL_BEGIN

@interface KBArrayBase () <KBCollection_Protected>

+ (instancetype) kb_unsealedArrayWithCapacity: (NSUInteger) capacity;

- (void) kb_sealArray;

@end

@interface KBArray ()

@property (nonatomic, readonly, class, getter = kb_isMutable) BOOL kb_mutable;
@property (nonatomic, readonly, nullable) Class kb_classForMutableCopying;
@property (nonatomic, readonly, nullable) Class kb_classForImmutableCopying;

- (instancetype) initWithCapacity: (NSUInteger) capacity NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
