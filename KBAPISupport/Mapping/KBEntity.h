//
//  KBEntity.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/30/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
@class GDataXMLElement;
#endif

@protocol KBEntity <NSObject>

@required

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
+ (instancetype _Nullable) entityFromJSON: (id _Nonnull) JSON;
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
+ (instancetype _Nullable) entityFromXML: (GDataXMLElement *_Nonnull) XML;
#endif

@end
