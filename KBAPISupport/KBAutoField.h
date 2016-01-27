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
@property (nonatomic, readonly) NSString *fieldName;

#if KBAPISUPPORT_XML
/** Whether this KBAutoField should get field value from element's attributes.
  *
  * This method is obly defined when KBAPISupport is compiled with XML support.
  */
@property (nonatomic, readonly, getter = isAttribute) BOOL attribute;
#endif

@optional
/** Field name in the source JSON/XML object. */
@property (nonatomic, readonly) NSString *sourceFieldName;

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
@property (nonatomic, readonly, getter = isAttribute) BOOL attribute;
#endif

/** Object's field name. */
@property (nonatomic, readonly) NSString *fieldName;
/** Source JSON/XML object's field name. */
@property (nonatomic, readonly) NSString *sourceFieldName;

/** ------------------------
  * @name Creating instances
  * ------------------------
  */

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

- (instancetype) initWithFieldName: (NSString *) fieldName;
// designated initializer when XML is off
- (instancetype) initWithFieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName;
#if KBAPISUPPORT_XML
// designated initializer when XML is on
- (instancetype) initWithFieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName isAttribute: (BOOL) isAttribute;
#endif

@end

@interface KBAutoTimestampField: KBAutoFieldBase

- (void) gotNumericValue: (NSNumber *) value forObject: (id) object;

@end

@interface KBAutoIntegerField: KBAutoTimestampField

@property (nonatomic, readonly) BOOL isUnsigned;

+ (instancetype) autoFieldWithUnsigned: (BOOL) isUnsigned fieldName: (NSString *) fieldName;
+ (instancetype) autoFieldWithUnsigned: (BOOL) isUnsigned fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName;
#if KBAPISUPPORT_XML
+ (instancetype) autoFieldWithUnsigned: (BOOL) isUnsigned fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName isAttribute: (BOOL) isAttribute;
#endif

- (instancetype) initWithUnsigned: (BOOL) isUnsigned fieldName: (NSString *) fieldName;
// designated initializer when XML is off
- (instancetype) initWithUnsigned: (BOOL) isUnsigned fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName;
#if KBAPISUPPORT_XML
// designated initializer when XML is on
- (instancetype) initWithUnsigned: (BOOL) isUnsigned fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName isAttribute: (BOOL) isAttribute;
#endif

@end

@interface KBAutoStringField: KBAutoFieldBase

@end

@interface KBAutoURLField: KBAutoStringField

@property (nonatomic, readonly) NSURL *baseURL;

+ (instancetype) autoFieldWithBaseURL: (NSURL *) baseURL fieldName: (NSString *) fieldName;
+ (instancetype) autoFieldWithBaseURL: (NSURL *) baseURL fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName;
#if KBAPISUPPORT_XML
+ (instancetype) autoFieldWithBaseURL: (NSURL *) baseURL fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName isAttribute: (BOOL) isAttribute;
#endif

- (instancetype) initWithBaseURL: (NSURL *) baseURL fieldName: (NSString *) fieldName;
// designated initializer when XML is off
- (instancetype) initWithBaseURL: (NSURL *) baseURL fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName;
#if KBAPISUPPORT_XML
// designated initializer when XML is on
- (instancetype) initWithBaseURL: (NSURL *) baseURL fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName isAttribute: (BOOL) isAttribute;
#endif

@end

@interface KBAutoObjectField: KBAutoFieldBase

@property (nonatomic, unsafe_unretained) Class objectClass;

+ (instancetype) autoFieldWithObjectClass: (Class) objectClass fieldName: (NSString *) fieldName;
+ (instancetype) autoFieldWithObjectClass: (Class) objectClass fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName;

- (instancetype) initWithObjectClass: (Class) objectClass fieldName: (NSString *) fieldName;
- (instancetype) initWithObjectClass: (Class) objectClass fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName;

@end

@interface KBAutoStringArrayField: KBAutoFieldBase

@end

@interface KBAutoObjectCollectionField: KBAutoFieldBase

@property (nonatomic, readonly) BOOL isMutable;
@property (nonatomic, unsafe_unretained) Class entityClass;
@property (nonatomic, readonly) NSString *entityTag;

+ (Class) collectionClass;
+ (Class) mutableCollectionClass;

+ (instancetype) autoFieldWithEntityClass: (Class) entityClass fieldName:(NSString *)fieldName;
+ (instancetype) autoFieldWithEntityClass: (Class) entityClass fieldName:(NSString *)fieldName sourceFieldName:(NSString *)sourceFieldName;
+ (instancetype) autoFieldWithEntityClass: (Class) entityClass fieldName:(NSString *)fieldName sourceFieldName:(NSString *)sourceFieldName isMutable: (BOOL) isMutable;
#if KBAPISUPPORT_XML
+ (instancetype) autoFieldWithEntityClass: (Class) entityClass fieldName:(NSString *)fieldName entityTag: (NSString *) entityTag;
+ (instancetype) autoFieldWithEntityClass: (Class) entityClass fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName  entityTag: (NSString *) entityTag;
+ (instancetype) autoFieldWithEntityClass: (Class) entityClass fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName  isMutable: (BOOL) isMutable entityTag: (NSString *) entityTag;
#endif

- (instancetype) initWithEntityClass: (Class) entityClass fieldName:(NSString *)fieldName;
- (instancetype) initWithEntityClass: (Class) entityClass fieldName:(NSString *)fieldName sourceFieldName:(NSString *)sourceFieldName;
- (instancetype) initWithEntityClass: (Class) entityClass fieldName:(NSString *)fieldName sourceFieldName:(NSString *)sourceFieldName isMutable: (BOOL) isMutable;
#if KBAPISUPPORT_XML
- (instancetype) initWithEntityClass: (Class) entityClass fieldName:(NSString *)fieldName entityTag: (NSString *) entityTag;
- (instancetype) initWithEntityClass: (Class) entityClass fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName  entityTag: (NSString *) entityTag;
- (instancetype) initWithEntityClass: (Class) entityClass fieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName  isMutable: (BOOL) isMutable entityTag: (NSString *) entityTag;
#endif

@end

@interface KBAutoObjectArrayField: KBAutoObjectCollectionField

@end

@interface KBAutoObjectSetField: KBAutoObjectCollectionField

@end

@interface KBAutoObjectOrderedSetField: KBAutoObjectCollectionField

@end
