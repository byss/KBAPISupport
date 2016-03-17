//
//  KBAPIRequest.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, KBAPIRequestMethod) {
	KBAPIRequestMethodGET,
	KBAPIRequestMethodPOST,
	KBAPIRequestMethodPUT,
	KBAPIRequestMethodDELETE,
};

@interface KBAPIRequest: NSObject

@property (nonatomic, readonly, nullable) NSURL *URL;
@property (nonatomic, readonly, nonnull) NSString *URLString;
@property (nonatomic, readonly) KBAPIRequestMethod HTTPMethodType;
@property (nonatomic, readonly, nonnull) NSString *HTTPMethod;
@property (nonatomic, readonly, nullable) NSString *bodyString;
@property (nonatomic, readonly, nullable) NSData *bodyData;
@property (nonatomic, readonly, nullable) NSDictionary *additionalHeaders;

@end
