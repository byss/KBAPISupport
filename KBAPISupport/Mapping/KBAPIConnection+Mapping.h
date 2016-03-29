//
//  KBAPIConnection+Mapping.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/29/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBAPIConnection.h>

#if __has_include (<KBAPISupport/KBAPISupport+Blocks.h>)
@protocol KBEntity;
#endif

@interface KBAPIConnection (Mapping)

#if __has_include (<KBAPISupport/KBAPISupport+Blocks.h>)
- (void) startWithCompletion: (void (^_Nonnull) (id <KBEntity> _Nullable responseObject, NSError *_Nullable error)) completion;
#endif

@end
