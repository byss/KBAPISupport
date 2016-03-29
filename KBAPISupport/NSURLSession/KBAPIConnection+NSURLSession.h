//
//  KBAPIConnection+NSURLSession.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBAPIConnection.h>

@interface KBAPIConnection (NSURLSession)

@property (nonatomic, weak, nullable, readonly) NSURLSession *session;

+ (instancetype _Nullable) connectionWithRequest: (KBAPIRequest *_Nonnull) request session: (NSURLSession *_Nonnull) session;

- (instancetype _Nullable) initWithRequest: (KBAPIRequest *_Nonnull) request session: (NSURLSession *_Nonnull) session;

@end
