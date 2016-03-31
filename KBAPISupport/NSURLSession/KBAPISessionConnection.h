//
//  KBAPISessionConnection.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/31/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBAPIConnection+NSURLSession.h>

@interface KBAPISessionConnection: KBAPIConnection

@property (nonatomic, nullable, weak, readonly) NSURLSession *session;

- (instancetype _Nullable) initWithRequest: (KBAPIRequest *_Nonnull) request session: (NSURLSession *_Nullable) session NS_DESIGNATED_INITIALIZER;

@end
