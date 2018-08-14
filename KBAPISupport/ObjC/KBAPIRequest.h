//
//  KBAPIRequest.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/19/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KBAPISupport/KBAPIRequestHTTPMethod.h>

NS_ASSUME_NONNULL_BEGIN

NS_REFINED_FOR_SWIFT
@interface KBAPIRequest: NSObject

@property (nonatomic, readonly) KBAPIRequestHTTPMethod HTTPMethod NS_REFINED_FOR_SWIFT;
@property (nonatomic, readonly) NSDictionary <NSString *, NSString *> *HTTPHeaders;
@property (nonatomic, readonly) NSURL *baseURL;
@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly) NSDictionary <NSString *, id> *parameters;

@end

NS_ASSUME_NONNULL_END
