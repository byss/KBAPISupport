//
//  KBAPIRequestOperation+NSURLSession.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBAPISupport.h>

@interface KBAPIRequestOperation (NSURLSession)

@property (nonatomic, weak, readonly) NSURLSession *session;

+ (NSURLSession *_Nonnull) defaultSession;
+ (void) setDefaultSession: (NSURLSession *_Nullable) session;

- (instancetype _Nullable) initWithRequest: (KBAPIRequest *_Nonnull) request session: (NSURLSession *_Nonnull) session completion: (void (^_Nullable) (NSData *_Nullable responseData, NSError *_Nullable error)) completion;

@end
