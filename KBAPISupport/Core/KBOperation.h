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

- (instancetype _Nullable) initWithCompletion: (void (^_Nullable) (id _Nullable result, NSError *_Nullable error)) completion NS_DESIGNATED_INITIALIZER;

@end
