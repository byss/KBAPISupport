//
//  KBAPIConnection+Delegates.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "KBAPIConnection.h"

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
@class GDataXMLDocument;
#endif

#if __has_include (<KBAPISupport/KBAPISupport+Mapping.h>)
@protocol KBObject;
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
- (void) apiConnection:(KBAPIConnection *)connection didReceiveResponse: (id <KBObject>) response;
#endif

@end

NS_ASSUME_NONNULL_END

@interface KBAPIConnection (Delegates)

@property (nonatomic, strong, nullable) id <KBAPIConnectionDelegate> delegate;

+ (instancetype _Nullable) connectionWithRequest: (KBAPIRequest *_Nonnull) request delegate: (id <KBAPIConnectionDelegate> _Nullable) delegate;

- (instancetype _Nullable) initWithRequest:(KBAPIRequest *_Nonnull) request delegate: (id <KBAPIConnectionDelegate> _Nullable) delegate;

@end
