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

#if !__has_feature(objc_arc)

#import <Foundation/Foundation.h>

#ifndef IMPORTED_FROM_KBAPISUPPORT_H
#	warning Please #import "KBAPISupport.h".
#endif

#if KBAPISUPPORT_XML
@class GDataXMLElement;
#endif

@protocol KBAutoField <NSObject>
@required

- (NSString *) fieldName;
- (void) setFieldName: (NSString *) fieldName;
#if KBAPISUPPORT_XML
- (BOOL) isAttribute;
- (void) setIsAttribute: (BOOL) isAttribute;
#endif

#if KBAPISUPPORT_JSON
- (BOOL) setFieldInObject: (id) object fromJSON: (id) JSON;
#endif
#if KBAPISUPPORT_XML
- (BOOL) setFieldInObject: (id) object fromXML: (GDataXMLElement *) XML;
#endif

@optional
- (NSString *) sourceFieldName;
- (void) setSourceFieldName: (NSString *) sourceFieldName;

@end

///////////////////////// Some standart field types /////////////////////////

@interface KBAutoFieldBase: NSObject <KBAutoField>

#if KBAPISUPPORT_XML
@property (nonatomic, assign) BOOL isAttribute;
#endif
@property (nonatomic, retain) NSString *fieldName;
@property (nonatomic, retain) NSString *sourceFieldName;

+ (instancetype) autoField;
+ (instancetype) autoFieldWithFieldName: (NSString *) fieldName;
+ (instancetype) autoFieldWithFieldName: (NSString *) fieldName sourceFieldName: (NSString *) sourceFieldName;
#if KBAPISUPPORT_XML
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

#endif // !__has_feature(objc_arc)
