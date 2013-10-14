//
//  KBAPIRequest.h
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

typedef NS_ENUM (NSInteger, KBAPIRequestMethod) {
	/** HTTP GET. */
	KBAPIRequestMethodGET,
	/** HTTP POST. */
	KBAPIRequestMethodPOST,
	/** HTTP PUT. */
	KBAPIRequestMethodPUT,
	/** HTTP DELETE. */
	KBAPIRequestMethodDELETE,
};

/** Base class for API requests objects.
  *
  * Your subclass must override at least the URL property.
  */
@interface KBAPIRequest: NSObject

/** --------------------------
  * @name Request HTTP options
  * --------------------------
  */

/** The request's URL. */
@property (nonatomic, readonly) NSString *URL;
/** The request's HTTP method.
  * 
  * KBAPIRequestMethodGET by default.
  */
@property (nonatomic, readonly) KBAPIRequestMethod requestMethod;
/** The request's HTTP body, represented as string. */
@property (nonatomic, readonly) NSString *bodyString;
/** The request's HTTP body data.
  * 
  * By default is the value of bodyString encoded as UTF-8.
  */
@property (nonatomic, readonly) NSData *bodyData;
@property (nonatomic, readonly) NSDictionary *additionalHeaders;

/** ------------------------
  * @name Creating instances
  * ------------------------
  */

/** Creates and initializes instance.
  * 
  * @return Newly created instance.
  */
+ (instancetype) request;

/** Expected response object class.
  *
  * Override this method in child class to use reponse objects autoconstructing.
  */
+ (Class) expected;

/** Expected response error object class.
  *
  * Override this method in child class to use reponse errors autoconstructing.
  */
+ (Class) error;

@end
