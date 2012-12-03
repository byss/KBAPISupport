//
//  KBAPIConnection.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 26.11.12.
//  Copyright (c) 2012 Kirill byss Bystrov. All rights reserved.
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

#import <Foundation/Foundation.h>

#ifndef IMPORTED_FROM_KBAPISUPPORT_H
#	warning Please #import "KBAPISupport.h".
#endif

@protocol KBEntity;
@class KBAPIRequest;
@class KBAPIConnection;
#if KBAPISUPPORT_XML
@class GDataXMLDocument;
#endif

#if KBAPISUPPORT_BOTH_FORMATS
typedef enum _KBAPIConnectionResponseType KBAPIConnectionResponseType;

enum _KBAPIConnectionResponseType {
	KBAPIConnectionResponseTypeAuto = 0,
	KBAPIConnectionResponseTypeJSON,
	KBAPIConnectionResponseTypeXML,
};
#endif

#if KBAPISUPPORT_BOTH_FORMATS
extern NSString *const KBJSONErrorKey;
extern NSString *const KBXMLErrorKey;
#endif

@protocol KBAPIConnectionDelegate <NSObject>
@required
- (void) connection: (KBAPIConnection *) connection didFailWithError:(NSError *)error;

// These methods are @optional. However, you should implement one of them to use KBAPIConnection.
@optional
#if KBAPISUPPORT_JSON
- (void) connection:(KBAPIConnection *)connection didReceiveJSON: (id) JSON;
#endif
#if KBAPISUPPORT_XML
- (void) connection:(KBAPIConnection *)connection didReceiveXML: (GDataXMLDocument *) XML;
#endif
- (void) connection:(KBAPIConnection *)connection didReceiveResponse: (id <KBEntity>) response;

@end

@interface KBAPIConnection : NSObject

@property (nonatomic, retain) id <KBAPIConnectionDelegate> delegate;
#if KBAPISUPPORT_BOTH_FORMATS
@property (nonatomic, assign) KBAPIConnectionResponseType responseType;
#endif

#if KBAPISUPPORT_BOTH_FORMATS
+ (instancetype) connectionWithRequest: (KBAPIRequest *) request delegate: (id <KBAPIConnectionDelegate>) delegate responseType: (KBAPIConnectionResponseType) responseType;
#endif
+ (instancetype) connectionWithRequest: (KBAPIRequest *) request delegate: (id <KBAPIConnectionDelegate>) delegate;

- (void) start;
- (void) startForClass: (Class) clazz;

@end
