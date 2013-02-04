//
//  KBAPIConnectionDelegate.h
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

#import "KBAPISupport-config.h"

@protocol KBEntity;

@class KBAPIConnection;
#if KBAPISUPPORT_XML
@class GDataXMLDocument;
#endif

/** KBAPIConnection instances' delegates must implement this protocol to receive
  * connection-related events. Note, that all methods from "Handling responses"
  * section are optional, but the delegate should implement one of the methods
  * to actually use the KBAPIConnection instances.
  * 
  * Delegate's methods are checked in the following order:
  * 
  * 1. If the connection has expected response class, then the apiConnection:didReceiveResponse:
  * is tried.
  * 2. One of apiConnection:didReceiveJSON: and apiConnection:didReceiveXML: is tried,
  * depending on the response type.
  * 3. apiConnection:didReceiveData: is tried.
  */
@protocol KBAPIConnectionDelegate <NSObject>
@required

/** ---------------------
  * @name Errors handling
  * ---------------------
  */
  
/** Called when connection receives error.
  *
  * This method is called not only on network errors, but also on malformed JSON
  * or XML response or when object cannot be constructed from given source.
  *
  * @param connection Connection which received error.
  * @param error Error information.
  */
- (void) apiConnection: (KBAPIConnection *) connection didFailWithError:(NSError *)error;

@optional

/** ------------------------
  * @name Handling responses
  * ------------------------
  */

#if KBAPISUPPORT_JSON
/** Connection received JSON object.
  *
  * This method is only defined when KBAPISupport is compiled with JSON support.
  *
  * @param connection Connection which received response.
  * @param JSON The response object.
  */
- (void) apiConnection:(KBAPIConnection *)connection didReceiveJSON: (id) JSON;
#endif

#if KBAPISUPPORT_XML
/** Connection received XML object.
  *
  * This method is only defined when KBAPISupport is compiled with XML support.
  *
  * @param connection Connection which received response.
  * @param XML The response XML document.
  */
- (void) apiConnection:(KBAPIConnection *)connection didReceiveXML: (GDataXMLDocument *) XML;
#endif

/** Connection received some response and constructed response object.
  *
  * @param connection Connection which received response.
  * @param response Constructed response object.
  */
- (void) apiConnection:(KBAPIConnection *)connection didReceiveResponse: (id <KBEntity>) response;

/** Connection received arbitrary data.
  *
  * @param connection Connection which received response.
  * @param data Raw received data.
  */
- (void) apiConnection:(KBAPIConnection *)connection didReceiveData: (NSData *) data;

@end

