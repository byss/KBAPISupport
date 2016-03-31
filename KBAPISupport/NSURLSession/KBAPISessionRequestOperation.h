//
//  KBAPISessionRequestOperation.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/31/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBAPIRequestOperation.h>

@interface KBAPISessionRequestOperation: KBAPIRequestOperation

@property (nonatomic, nullable, weak, readonly) NSURLSession *session;

+ (NSURLSession *_Nonnull) defaultSession;
+ (void) setDefaultSession: (NSURLSession *_Nullable) session;

- (instancetype _Nullable) initWithRequest: (KBAPIRequest *_Nonnull) request session: (NSURLSession *_Nullable) session completion: (void (^_Nullable) (NSData *_Nullable responseData, NSError *_Nullable error)) completion;

@end
