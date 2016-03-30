//
//  KBAPIRequestOperation.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBOperation.h>

@class KBAPIRequest;
@interface KBAPIRequestOperation: KBOperation

@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, nullable, copy) void (^operationCompletionBlock) (NSData *_Nullable result, NSError *_Nullable error);

+ (NSTimeInterval) defaultTimeout;
+ (void) setDefaultTimeout: (NSTimeInterval) defaultTimeout;

- (instancetype _Nullable) initWithRequest: (KBAPIRequest *_Nonnull) request completion: (void (^_Nullable) (NSData *_Nullable responseData, NSError *_Nullable error)) completion NS_DESIGNATED_INITIALIZER;

@end
