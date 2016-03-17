//
//  KBAPIConnection.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KBAPIRequest;
@interface KBAPIConnection: NSObject

@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, weak, null_resettable) NSOperationQueue *callbacksQueue;
@property (nonatomic, copy, nullable) NSDictionary *userInfo;

+ (NSTimeInterval) defaultTimeout;
+ (void) setDefaultTimeout: (NSTimeInterval) defaultTimeout;
+ (NSOperationQueue *_Nonnull) defaultCallbacksQueue;
+ (void) setDefaultCallbacksQueue: (NSOperationQueue *_Nullable) defaultCallbacksQueue;

+ (instancetype _Nullable) connectionWithRequest: (KBAPIRequest *_Nonnull) request;

- (instancetype _Nullable) initWithRequest: (KBAPIRequest *_Nonnull) request NS_DESIGNATED_INITIALIZER;

- (void) start;
- (void) cancel;

@end
