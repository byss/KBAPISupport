//
//  KBAPIConnection+Delegates.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import "KBAPIConnection.h"

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
@class GDataXMLDocument;
#endif

#if __has_include (<KBAPISupport/KBAPISupport+Mapping.h>)
@protocol KBEntity;
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol KBAPIConnectionDelegate <NSObject>

@required
- (void) apiConnection: (KBAPIConnection *) connection didFailWithError:(NSError *) error;

@optional
- (void) apiConnection:(KBAPIConnection *) connection didReceiveData: (NSData *) data;

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
- (void) apiConnection:(KBAPIConnection *)connection didReceiveJSON: (id) JSON;
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
- (void) apiConnection:(KBAPIConnection *)connection didReceiveXML: (GDataXMLDocument *) XML;
#endif

#if __has_include (<KBAPISupport/KBAPISupport+Mapping.h>)
- (void) apiConnection:(KBAPIConnection *)connection didReceiveResponse: (id <KBEntity>) response;
#endif

@end

NS_ASSUME_NONNULL_END

@interface KBAPIConnection (Delegates)

@property (nonatomic, strong, nullable) id <KBAPIConnectionDelegate> delegate;

+ (instancetype _Nullable) connectionWithRequest: (KBAPIRequest *_Nonnull) request delegate: (id <KBAPIConnectionDelegate> _Nullable) delegate;

- (instancetype _Nullable) initWithRequest:(KBAPIRequest *_Nonnull) request delegate: (id <KBAPIConnectionDelegate> _Nullable) delegate;

@end
