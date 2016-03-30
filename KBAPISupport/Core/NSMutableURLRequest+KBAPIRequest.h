//
//  NSMutableURLRequest+KBAPIRequest.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/29/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KBAPIRequest;
@interface NSMutableURLRequest (KBAPIRequest)

- (instancetype _Nullable) initWithAPIRequest: (KBAPIRequest *_Nonnull) request;

@end
