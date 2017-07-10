//
//  KBCollection_Protected.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/10/17.
//  Copyright © 2017 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBCollection.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KBCollection_Protected <KBCollection>

+ (instancetype) kb_unsealedCollectionWithCapacity: (NSUInteger) capacity;

- (NSUInteger) kb_capacity;
- (void) kb_addObject: (id _Nullable) object;
- (void) kb_addObjects: (__unsafe_unretained id const _Nonnull [_Nullable]) objects count: (NSUInteger) count;
- (void) kb_sealCollection;

@end

NS_ASSUME_NONNULL_END
