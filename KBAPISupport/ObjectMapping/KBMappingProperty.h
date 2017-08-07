//
//  KBMappingProperty.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/31/16.
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

#import <Foundation/Foundation.h>

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
@interface NSObject (KBJSONMapping)

- (id _Nullable) JSONValueForKeyPath: (NSString *_Nonnull) keyPath;

@end
#endif

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>) || __has_include (<KBAPISupport/KBAPISupport+XML.h>)
FOUNDATION_EXPORT NSString *_Nullable KBStringValue (id _Nullable object);
FOUNDATION_EXPORT NSNumber *_Nullable KBNumberValue (id _Nullable object);
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
@class GDataXMLElement;
#endif
@protocol KBMappingProperty <NSObject>

@required
@property (nonatomic, copy, nonnull) NSString *objectKeyPath;
@property (nonatomic, copy, nonnull) NSString *sourceKeyPath;

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
- (void) setValueInObject: (NSObject *_Nonnull) object fromJSONObject: (id _Nullable) JSONObject mappingContext: (id _Nullable) mappingContext;
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
- (void) setValueInObject: (NSObject *_Nonnull) object fromXMLObject: (GDataXMLElement * _Nullable) XMLObject mappingContext: (id _Nullable) mappingContext;
#endif

@end

@interface KBMappingProperty: NSObject <KBMappingProperty>

+ (instancetype _Nullable) mappingPropertyWithKeyPath: (NSString *_Nonnull) keyPath;
+ (instancetype _Nullable) mappingPropertyWithKeyPath: (NSString *_Nonnull) keyPath sourceKeyPath: (NSString *_Nullable) sourceKeyPath;

- (instancetype _Nullable) initWithKeyPath: (NSString *_Nonnull) keyPath;
- (instancetype _Nullable) initWithKeyPath: (NSString *_Nonnull) keyPath sourceKeyPath: (NSString *_Nullable) sourceKeyPath NS_DESIGNATED_INITIALIZER;

@end

@interface KBStringMappingProperty: KBMappingProperty

@end

@interface KBStringArrayMappingProperty: KBMappingProperty

@end

@interface KBURLMappingProperty: KBMappingProperty

@end

@interface KBEnumMappingProperty: KBMappingProperty

+ (instancetype _Nullable) mappingPropertyWithKeyPath: (NSString *_Nonnull) keyPath enumValues: (NSDictionary <NSString *, NSNumber *> *_Nonnull) enumValues;
+ (instancetype _Nullable) mappingPropertyWithKeyPath: (NSString *_Nonnull) keyPath sourceKeyPath: (NSString *_Nullable) sourceKeyPath enumValues: (NSDictionary <NSString *, NSNumber *> *_Nonnull) enumValues;

- (instancetype _Nullable) initWithKeyPath: (NSString *_Nonnull) keyPath enumValues: (NSDictionary <NSString *, NSNumber *> *_Nonnull) enumValues;
- (instancetype _Nullable) initWithKeyPath: (NSString *_Nonnull) keyPath sourceKeyPath: (NSString *_Nullable) sourceKeyPath enumValues: (NSDictionary <NSString *, NSNumber *> *_Nonnull) enumValues NS_DESIGNATED_INITIALIZER;

@end

@interface KBNumberMappingProperty: KBMappingProperty

@end

@interface KBTimestampMappingProperty: KBMappingProperty

@end

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
@class GDataXMLElement;
#endif
@interface KBMappingPropertyWithBlock: KBMappingProperty

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
+ (instancetype _Nullable) mappingPropertyWithKeyPath: (NSString *_Nonnull) keyPath JSONMappingBlock: (void (^_Nonnull) (NSObject *_Nonnull object, id _Nullable JSON, id _Nullable mappingContext)) JSONMappingBlock;
+ (instancetype _Nullable) mappingPropertyWithKeyPath: (NSString *_Nonnull) keyPath sourceKeyPath: (NSString *_Nullable) sourceKeyPath JSONMappingBlock: (void (^_Nonnull) (NSObject *_Nonnull object, id _Nullable JSON, id _Nullable mappingContext)) JSONMappingBlock;

- (instancetype _Nullable) initWithKeyPath: (NSString *_Nonnull) keyPath JSONMappingBlock: (void (^_Nonnull) (NSObject *_Nonnull object, id _Nullable JSON, id _Nullable mappingContext)) JSONMappingBlock;
- (instancetype _Nullable) initWithKeyPath: (NSString *_Nonnull) keyPath sourceKeyPath: (NSString *_Nullable) sourceKeyPath JSONMappingBlock: (void (^_Nonnull) (NSObject *_Nonnull object, id _Nullable JSON, id _Nullable mappingContext)) JSONMappingBlock NS_DESIGNATED_INITIALIZER;
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
+ (instancetype _Nullable) mappingPropertyWithKeyPath: (NSString *_Nonnull) keyPath XMLMappingBlock: (void (^_Nonnull) (NSObject *_Nonnull object, GDataXMLElement *_Nullable XML, id _Nullable mappingContext)) XMLMappingBlock;
+ (instancetype _Nullable) mappingPropertyWithKeyPath: (NSString *_Nonnull) keyPath sourceKeyPath: (NSString *_Nullable) sourceKeyPath XMLMappingBlock: (void (^_Nonnull) (NSObject *_Nonnull object, GDataXMLElement *_Nullable XML, id _Nullable mappingContext)) XMLMappingBlock;

- (instancetype _Nullable) initWithKeyPath: (NSString *_Nonnull) keyPath XMLMappingBlock: (void (^_Nonnull) (NSObject *_Nonnull object, GDataXMLElement *_Nullable XML, id _Nullable mappingContext)) XMLMappingBlock;
- (instancetype _Nullable) initWithKeyPath: (NSString *_Nonnull) keyPath sourceKeyPath: (NSString *_Nullable) sourceKeyPath XMLMappingBlock: (void (^_Nonnull) (NSObject *_Nonnull object, GDataXMLElement *_Nullable XML, id _Nullable mappingContext)) XMLMappingBlock NS_DESIGNATED_INITIALIZER;
#endif

@end

@protocol KBObject;
@interface KBObjectMappingProperty: KBMappingProperty

+ (instancetype _Nullable) mappingPropertyWithKeyPath:(NSString *_Nonnull) keyPath valueClass: (Class <KBObject> _Nonnull) valueClass;
+ (instancetype _Nullable) mappingPropertyWithKeyPath:(NSString *_Nonnull) keyPath sourceKeyPath:(NSString * _Nullable)sourceKeyPath valueClass: (Class <KBObject> _Nonnull) valueClass;

- (instancetype _Nullable) initWithKeyPath:(NSString *_Nonnull) keyPath valueClass: (Class <KBObject> _Nonnull) valueClass;
- (instancetype _Nullable) initWithKeyPath:(NSString *_Nonnull) keyPath sourceKeyPath:(NSString * _Nullable)sourceKeyPath valueClass: (Class <KBObject> _Nonnull) valueClass NS_DESIGNATED_INITIALIZER;

@end

@interface KBCollectionMappingProperty: KBMappingProperty

+ (instancetype _Nullable) mappingPropertyWithKeyPath:(NSString *_Nonnull) keyPath itemClass: (Class <KBObject> _Nonnull) itemClass;
+ (instancetype _Nullable) mappingPropertyWithKeyPath:(NSString *_Nonnull) keyPath sourceKeyPath:(NSString * _Nullable)sourceKeyPath itemClass: (Class <KBObject> _Nonnull) itemClass;

- (instancetype _Nullable) initWithKeyPath:(NSString *_Nonnull) keyPath itemClass: (Class <KBObject> _Nonnull) itemClass;
- (instancetype _Nullable) initWithKeyPath:(NSString *_Nonnull) keyPath sourceKeyPath:(NSString * _Nullable)sourceKeyPath itemClass: (Class <KBObject> _Nonnull) itemClass NS_DESIGNATED_INITIALIZER;

@end

@interface KBArrayMappingProperty: KBCollectionMappingProperty

@end

@interface KBSetMappingProperty: KBCollectionMappingProperty

@end

@interface KBOrderedSetMappingProperty: KBCollectionMappingProperty

@end
