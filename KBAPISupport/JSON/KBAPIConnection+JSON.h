//
//  KBAPIConnection+JSON.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBAPIConnection.h>

@interface KBAPIConnection (JSON)

#if __has_include (<KBAPISupport/KBAPISupport+Blocks.h>)
- (void) startWithRawObjectCompletion: (void (^_Nullable) (id _Nullable JSONResponse, NSError *_Nullable error)) completion;
#endif

@end
