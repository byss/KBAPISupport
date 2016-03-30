//
//  KBAPIConnection_Protected.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/30/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBAPIConnection.h>

@class KBAPIRequest;
@class KBAPIRequestOperation;
@interface KBAPIConnection ()

@property (nonatomic, readonly, nonnull) KBAPIRequest *request;

+ (void) registerOperationSetupHandlerWithPriority: (NSUInteger) priority handlerBlock: (void (^_Nonnull) (KBAPIConnection *_Nonnull connection, KBAPIRequestOperation *_Nonnull operation)) handlerBlock;

- (KBAPIRequestOperation *_Nullable) createRequestOperationWithRequest: (KBAPIRequest *_Nonnull) request;

@end
