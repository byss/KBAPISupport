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

+ (NSTimeInterval) defaultTimeout;
+ (void) setDefaultTimeout: (NSTimeInterval) defaultTimeout;

@property (nonatomic, assign) NSTimeInterval timeout;

- (instancetype _Nullable) initWithRequest: (KBAPIRequest *_Nonnull) request completion: (void (^_Nullable) (NSData *_Nullable responseData, NSError *_Nullable error)) completion NS_DESIGNATED_INITIALIZER;

@end
