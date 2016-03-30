//
//  KBOperation.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KBAPIRequest;
@interface KBOperation: NSOperation

@property (nonatomic, nullable, readonly) NSArray <NSOperation *> *suboperations;
@property (nonatomic, nullable, copy) void (^operationCompletionBlock) (id _Nullable result, NSError *_Nullable error);

- (instancetype _Nullable) initWithCompletion: (void (^_Nullable) (id _Nullable result, NSError *_Nullable error)) completion NS_DESIGNATED_INITIALIZER;

- (void) addSuboperation: (NSOperation *_Nonnull) operation;

@end
