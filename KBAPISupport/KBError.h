//
//  KBError.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 31.01.13.
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

#import "KBEntity.h"
#import "KBAPISupport-config.h"

/** Default error domain. */
extern NSString *const kKBErrorDomain;

/** This class is used to parse some API-related errors. Your error subclass
  * must override errorCodeField and errorDescriptionField methods.
  */
@interface KBError: NSError <KBEntity>

/** ---------------------
  * @name Response fields
  * ---------------------
  */

/** Returns name of the error code field in response. */
+ (NSString *) errorCodeField;

/** Returns name of the error description field in response. */
+ (NSString *) errorDescriptionField;

/** Returns name of the error domain field in response.
  *
  * If this method returns nil, value of defaultErrorDomain is used.
  */
+ (NSString *) errorDomainField;

/** Returns name of the error domain field in response.
 *
 * If this method returns nil, value of kKBErrorDomain is used.
 */
+ (NSString *) defaultErrorDomain;

#if KBAPISUPPORT_XML
/** Returns whether error code should be obtained from XML element attribute.
  *
  * This method is only defined if KBAPISupport is compiled with XML support.
  */
+ (BOOL) errorCodeFieldIsAttribute;

/** Returns whether error description should be obtained from XML element attribute.
 *
 * This method is only defined if KBAPISupport is compiled with XML support.
 */
+ (BOOL) errorDescriptionFieldIsAttribute;

/** Returns whether error domain should be obtained from XML element attribute.
 *
 * This method is only defined if KBAPISupport is compiled with XML support.
 */
+ (BOOL) errorDomainFieldIsAttribute;
#endif

@end
