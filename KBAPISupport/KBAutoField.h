//
//  KBAutoField.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 06.12.12.
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

#if KBAPISUPPORT_XML
@class GDataXMLElement;
#endif

/** This protocol defines generic AutoObject's field parsing behaviour.
  * Available only in non-ARC environment.
  */
@protocol KBAutoField <NSObject>
@required

/** ---------------------
  * @name Parsing options
  * ---------------------
  */

/** Object's field name */
- (NSString *) fieldName;
/** Sets object's field name
  *
  * @param fieldName New field name.
  */
- (void) setFieldName: (NSString *) fieldName;
#if KBAPISUPPORT_XML
/** Whether this KBAutoField should get field value from element's attributes.
  *
  * This method is obly defined when KBAPISupport is compiled with XML support.
  */
- (BOOL) isAttribute;
/** Sets value for isAttribute.
  * 
  * This method is obly defined when KBAPISupport is compiled with XML support.
  *
  * @param isAttribute New value.
  */
- (void) setIsAttribute: (BOOL) isAttribute;
#endif

@optional
/** Field name in the source JSON/XML object. */
- (NSString *) sourceFieldName;
/** Sets sourceFieldName
  *
  * @param sourceFieldName New source object field name.
  */
- (void) setSourceFieldName: (NSString *) sourceFieldName;

@required
/** --------------------
  * @name Setting fields
  * --------------------
  */

#if KBAPISUPPORT_JSON
/** Sets represented field in the object from JSON representation.
  *
  * This method is obly defined when KBAPISupport is compiled with JSON support.
  *
  * @param object Response object.
  * @param JSON Source JSON object.
  * @return Whether operation succeeded.
  */
- (BOOL) setFieldInObject: (id) object fromJSON: (id) JSON;
#endif
#if KBAPISUPPORT_XML
/** Sets represented field in the object from XML representation.
  *
  * This method is obly defined when KBAPISupport is compiled with XML support.
  *
  * @param object Response object.
  * @param XML Source XML element object.
  * @return Whether operation succeeded.
  */
- (BOOL) setFieldInObject: (id) object fromXML: (GDataXMLElement *) XML;
#endif

@end

/** Base class for predefined autofields, such as KBAutoIntegerField,
  * KBAutoObjectField, KBAutoStringField and KBAutoTimestampField.
  * Available only in non-ARC environment.
  */
@interface KBAutoFieldBase: NSObject <KBAutoField>

#if KBAPISUPPORT_XML
/** ---------------------
  * @name Parsing options
  * ---------------------
  */

/** Whether this autofield sould get field value from XML element attributes.
  *
  * This property is defined only if KBAPISupport is compiled with XML support.
  */
@property (nonatomic, assign) BOOL isAttribute;
#endif
/** Object's field name. */
@property (nonatomic, retain) NSString *fieldName;
/** Source JSON/XML object's field name. */
@property (nonatomic, retain) NSString *sourceFieldName;

/** ------------------------
  * @name Creating instances
  * ------------------------
  */

/** Calls autoFieldWithFieldName:sourceFieldName: with nil and nil.
  *
  * @see autoFieldWithFieldName:sourceFieldName:
  */
+ (instancetype) autoField;

/** Calls autoFieldWithFieldName:sourceFieldName: with fieldName and nil.
  *
  * @see autoFieldWithFieldName:sourceFieldName:
  */
+ (instancetype) autoFieldWithFieldName: (NSString *) fieldName;

/** Creates and initializes autofield.
  *
  * @param fieldName Object's field name.
  * @param sourceFieldName Source JSON/XML object's field name.
  * @return Newly created autofield instance.
  *
  * @sa autoFieldWithFieldName:
  * @sa autoField
  */
+ (instancetype) autoFieldWithFieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName;

#if KBAPISUPPORT_XML
/** First calls autoFieldWithFieldName:sourceFieldName: with fieldName and sourceFieldName, then sets isAttribute value.
  *
  * This method is only defined if KBAPISupport was compiled with XML support.
  *
  * @see autoFieldWithFieldName:sourceFieldName:
  */
+ (instancetype) autoFieldWithFieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName isAttribute: (BOOL) isAttribute;
#endif

- (id) initWithFieldName: (NSString *) fieldName;
// designated initializer when XML is off
- (id) initWithFieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName;
#if KBAPISUPPORT_XML
// designated initializer when XML is on
- (id) initWithFieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName isAttribute: (BOOL) isAttribute;
#endif

@end

@interface KBAutoTimestampField: KBAutoFieldBase

- (void) gotIntValue: (NSInteger) value forObject: (id) object;

@end

@interface KBAutoIntegerField: KBAutoTimestampField

@property (nonatomic, assign) BOOL isUnsigned;

+ (instancetype) autoFieldWithUnsigned: (BOOL) isUnsigned;
+ (instancetype) autoFieldWithUnsigned: (BOOL) isUnsigned fieldName: (NSString *) fieldName;
+ (instancetype) autoFieldWithUnsigned: (BOOL) isUnsigned fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName;
#if KBAPISUPPORT_XML
+ (instancetype) autoFieldWithUnsigned: (BOOL) isUnsigned fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName isAttribute: (BOOL) isAttribute;
#endif

- (id) initWithUnsigned: (BOOL) isUnsigned;
- (id) initWithUnsigned: (BOOL) isUnsigned fieldName: (NSString *) fieldName;
// designated initializer when XML is off
- (id) initWithUnsigned: (BOOL) isUnsigned fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName;
#if KBAPISUPPORT_XML
// designated initializer when XML is on
- (id) initWithUnsigned: (BOOL) isUnsigned fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName isAttribute: (BOOL) isAttribute;
#endif

@end

@interface KBAutoStringField: KBAutoFieldBase

@end

@interface KBAutoObjectField: KBAutoFieldBase

@property (nonatomic, retain) Class objectClass;

+ (instancetype) autoFieldWithObjectClass: (Class) objectClass;
+ (instancetype) autoFieldWithObjectClass: (Class) objectClass fieldName: (NSString *) fieldName;
+ (instancetype) autoFieldWithObjectClass: (Class) objectClass fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName;
#if KBAPISUPPORT_XML
+ (instancetype) autoFieldWithObjectClass: (Class) objectClass fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName isAttribute: (BOOL) isAttribute;
#endif

- (id) initWithObjectClass: (Class) objectClass;
- (id) initWithObjectClass: (Class) objectClass fieldName: (NSString *) fieldName;
// designated initializer when XML is off
- (id) initWithObjectClass: (Class) objectClass fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName;
#if KBAPISUPPORT_XML
// designated initializer when XML is on
- (id) initWithObjectClass: (Class) objectClass fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName isAttribute: (BOOL) isAttribute;
#endif

@end
