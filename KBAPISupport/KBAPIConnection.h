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

#import "KBAPISupport-config.h"
#import "KBAPIConnectionDelegate.h"

@class KBAPIRequest;

#if KBAPISUPPORT_BOTH_FORMATS
typedef enum _KBAPIConnectionResponseType KBAPIConnectionResponseType;

/** @enum Expected connection response type.
  *
  * Defined only if KBAPISupport was compiled with both JSON and XML support.
  */
enum _KBAPIConnectionResponseType {
	/** Let the connection to automatically decide of response type. */
	KBAPIConnectionResponseTypeAuto = 0,
	/** Response type is JSON. */
	KBAPIConnectionResponseTypeJSON,
	/** Response type is XML. */
	KBAPIConnectionResponseTypeXML,
};
#endif

#if KBAPISUPPORT_BOTH_FORMATS
extern NSString *const KBJSONErrorKey;
extern NSString *const KBXMLErrorKey;
#endif

/** This is the most important class in the library. To use it you must first
  * create KBAPIRequest, then you should create KBAPIConnection with this request
  * and set the delegate to receive API events such as errors, JSON, XML or
  * autoconstructed objects receiving.
  */
@interface KBAPIConnection: NSObject

/** The connection's delegate which receives connection responses and errors. */
@property (nonatomic, retain) id <KBAPIConnectionDelegate> delegate;
#if KBAPISUPPORT_BOTH_FORMATS
/** Expected response type.
  *
  * You may set this property to speed up response parsing. Note that this
  * property is defined only if KBAPISupport was compiled with bot JSON and
  * XML support.
  */
@property (nonatomic, assign) KBAPIConnectionResponseType responseType;
#endif

/** Connection timeout.
  *
  */
@property (nonatomic, assign) NSTimeInterval timeout;

/** Default connection timeout.
  *
  * @return Default connection timeout.
  */
+ (NSTimeInterval) defaultTimeout;

/** Sets new default connection timeout.
 *
 * @param timeout New default connection timeout.
 */
+ (void) setDefaultTimeout: (NSTimeInterval) timeout;

/** ----------------------------------------
  * @name Creating KBAPIConnection instances
  * ----------------------------------------
  */

#if KBAPISUPPORT_BOTH_FORMATS
/** Creates and initializes API connection with specified response type for some API request.
  *
  * This method is available only if KBAPISupport was compiled with both JSON and XML support.
  *
  * @param request API request for this connection.
  * @param delegate Connection delegate which receives connection status events.
  * @param responseType Expected response type.
  * @return Initialized KBAPIConnection instance.
  *
  * @sa KBAPIConnectionResponseType
  * @sa connectionWithRequest:delegate:
  * @sa delegate
  */
+ (instancetype) connectionWithRequest: (KBAPIRequest *) request delegate: (id <KBAPIConnectionDelegate>) delegate responseType: (KBAPIConnectionResponseType) responseType;
#endif

/** Creates and initializes API connection for some API request.
  *
  * @param request API request for this connection.
  * @param delegate Connection delegate which receives connection status events.
  * @return Initialized KBAPIConnection instance.
  *
  * @sa delegate
  * @sa start
  */
+ (instancetype) connectionWithRequest: (KBAPIRequest *) request delegate: (id <KBAPIConnectionDelegate>) delegate;

/** -------------------------
  * @name Starting connection
  * -------------------------
  */

/** Starts sending and receiving data over network.
  *
  * Call to this method begins actual API request. If the associated KBAPIRequest
  * defines non-nil expected and error then they would be used to auto-construct
  * response object.
  *
  * @sa startForClass:
  * @sa startForClass:error:
  */
- (void) start;

/** Starts API request for specified response class.
  *
  * Overrides the request expected response class. The clazz parameter is used
  * only if it conforms to KBEntity protocol.
  * 
  * @param clazz Expected response class.
  */
- (void) startForClass: (Class) clazz;

/** Starts API request for specified response and error classes.
  *
  * Overrides the request expected response and error class. Parameters are used
  * only if they conform to KBEntity protocol.
  * 
  * @param clazz Expected response class.
  * @param error Expected response error class.
  */
- (void) startForClass: (Class) clazz error: (Class) error;

@end
