//
//  NSError+KBMapping.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 4/20/16.
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
#import <KBAPISupport/KBObject.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *KBErrorMappingKeyPath NS_STRING_ENUM;

FOUNDATION_EXPORT KBErrorMappingKeyPath const KBErrorCodeMappingKeyPath;
FOUNDATION_EXPORT KBErrorMappingKeyPath const KBErrorLocalizedDescriptionMappingKeyPath;
FOUNDATION_EXPORT KBErrorMappingKeyPath const KBErrorDomainMappingKeyPath;

NS_ASSUME_NONNULL_END

@interface NSError (KBMapping) <KBObject>

@property (nonatomic, nullable, readonly, class) NSString *defaultErrorDomain;

@end

@interface NSError (KBMappingDeprecated)

@property (nonatomic, nullable, readonly, class) NSString *errorCodeKeyPath NS_DEPRECATED (10_10, 10_10, 2_0, 2_0,  "Please use +initalizeMappingProperties and return one for KBErrorCodeMapppingKeyPath");
@property (nonatomic, nullable, readonly, class) NSString *errorLocalizedDescriptionKeyPath NS_DEPRECATED (10_10, 10_10, 2_0, 2_0, "Please use +initalizeMappingProperties and return one for KBErrorLocalizedDescriptionMapppingKeyPath");
@property (nonatomic, nullable, readonly, class) NSString *errorDomainKeyPath NS_DEPRECATED (10_10, 10_10, 2_0, 2_0, "Please use +initalizeMappingProperties and return one for KBErrorDomainMapppingKeyPath");

@end
