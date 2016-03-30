//
//  KBAPIConnection+Blocks.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBAPIConnection.h>

#if __has_include (<KBAPISupport/KBAPISupport+Mapping.h>)
@protocol KBEntity;
#endif

@interface KBAPIConnection (Blocks)

- (void) startWithRawDataCompletion: (void (^_Nullable) (NSData *_Nullable responseData, NSError *_Nullable error)) completion;

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
- (void) startWithRawObjectCompletion: (void (^_Nullable) (id _Nullable JSONResponse, NSError *_Nullable error)) completion;
#endif

#if __has_include (<KBAPISupport/KBAPISupport+Mapping.h>)
- (void) startWithCompletion: (void (^_Nonnull) (id <KBEntity> _Nullable responseObject, NSError *_Nullable error)) completion;
#endif

@end
