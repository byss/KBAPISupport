//
//  KBOperation_Protected.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBOperation.h>

@interface KBOperation ()

@property (nonatomic, nullable, readonly) id result;
@property (nonatomic, nullable, copy) NSError *error;

@end
