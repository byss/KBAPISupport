//
//  NADConcreteDataRequest.m
//  KBAPISupport-Non-ARC-Demo
//
//  Created by Kirill byss Bystrov on 01.12.12.
//  Copyright (c) 2012 Kirill byss Bystrov. All rights reserved.
//

#import "NADConcreteDataRequest.h"

@implementation NADConcreteDataRequest

- (NSString *) URL {
	return [baseAddress stringByAppendingString:self.basename];
}

@end
