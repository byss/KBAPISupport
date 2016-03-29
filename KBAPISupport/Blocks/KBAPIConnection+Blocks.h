//
//  KBAPIConnection+Blocks.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBAPIConnection.h>

@interface KBAPIConnection (Blocks)

- (void) startWithRawDataCompletion: (void (^_Nullable) (NSData *_Nullable responseData, NSError *_Nullable error)) completion;

@end
