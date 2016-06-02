//
//  KBURLSessionDelegate.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 6/2/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KBAPISessionRequestOperation;
@interface KBURLSessionDelegate: NSObject <NSURLSessionDelegate>

@property (nonatomic, strong) id <NSURLSessionDelegate> sessionDelegate;

- (void) registerOperation: (KBAPISessionRequestOperation *) operation;
- (void) unregisterOperation: (KBAPISessionRequestOperation *) operation;

@end
