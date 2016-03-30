//
//  KBAPIRequest+Mapping.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/30/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBAPIRequest.h>

@interface KBAPIRequest (Mapping)

+ (Class _Nullable) expectedEntityClass;
+ (Class _Nullable) errorClass;

@end
