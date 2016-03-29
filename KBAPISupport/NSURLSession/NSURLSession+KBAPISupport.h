//
//  NSURLSession+KBAPISupport.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KBAPIRequest;
@class KBAPIConnection;
@interface NSURLSession (KBAPISupport)

- (KBAPIConnection *_Nullable) connectionWithRequest:  (KBAPIRequest *_Nonnull) request;

@end
