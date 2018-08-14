//
//  KBAPIRequestHTTPMethod.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 8/14/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *KBAPIRequestHTTPMethod NS_TYPED_EXTENSIBLE_ENUM NS_REFINED_FOR_SWIFT;

extern KBAPIRequestHTTPMethod const KBAPIRequestHTTPMethodHEAD;
extern KBAPIRequestHTTPMethod const KBAPIRequestHTTPMethodGET;
extern KBAPIRequestHTTPMethod const KBAPIRequestHTTPMethodPOST;
extern KBAPIRequestHTTPMethod const KBAPIRequestHTTPMethodPUT;
extern KBAPIRequestHTTPMethod const KBAPIRequestHTTPMethodPATCH;
extern KBAPIRequestHTTPMethod const KBAPIRequestHTTPMethodDELETE;

NS_ASSUME_NONNULL_END
