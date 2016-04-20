//
//  NSError+KBMapping.m
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

#import "NSError+KBMapping.h"

#import "KBMappingProperty.h"

@implementation NSError (KBMapping)

+ (NSString *_Nullable) errorCodeKeyPath {
	return nil;
}

+ (NSString *_Nullable) errorLocalizedDescriptionKeyPath {
	return nil;
}

+ (NSString *_Nullable) errorDomainKeyPath {
	return nil;
}

+ (NSString *_Nullable) defaultErrorDomain {
	return nil;
}

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
+ (instancetype)objectFromJSON:(id)JSON {
	NSString *codeKeyPath = [self errorCodeKeyPath];
	NSString *descriptionKeyPath = [self errorLocalizedDescriptionKeyPath];
	NSString *domainKeyPath = [self errorDomainKeyPath];
	NSString *defaultDomain = [self defaultErrorDomain];
	if (!(codeKeyPath && (domainKeyPath || defaultDomain))) {
		return nil;
	}
	
	NSInteger errorCodeValue = 0;
	id errorCode = [JSON JSONValueForKeyPath:codeKeyPath];
	if ([errorCode isKindOfClass:[NSString class]] || [errorCode isKindOfClass:[NSNumber class]]) {
		errorCodeValue = [errorCode integerValue];
	} else {
		return nil;
	}
	
	NSString *domain = nil;
	NSString *domainFromKeyPath = (domainKeyPath ? [JSON JSONValueForKeyPath:domainKeyPath] : nil);
	if ([domainFromKeyPath isKindOfClass:[NSString class]]) {
		domain = domainFromKeyPath;
	} else if (defaultDomain) {
		domain = defaultDomain;
	} else {
		return nil;
	}
	
	NSString *description = [JSON JSONValueForKeyPath:descriptionKeyPath];
	NSDictionary *userInfo = ([description isKindOfClass:[NSString class]] ? @{NSLocalizedDescriptionKey: description} : nil);
	
	return [[self alloc] initWithDomain:domain code:errorCodeValue userInfo:userInfo];
}
#endif

@end
