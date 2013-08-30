//
//  KBError.m
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 31.01.13.
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

#import "KBError.h"
#if KBAPISUPPORT_XML
#	import "GDataXMLNode.h"
#	import "GDataXMLElement+stuff.h"
#endif

#import "KBAPISupport-debug.h"

NSString *const kKBErrorDomain = @"ru.byss.KBAPISupport.KBError";

@implementation KBError

+ (NSString *) errorCodeField {
	return nil;
}

+ (NSString *) errorDescriptionField {
	return nil;
}

+ (NSString *) errorDomainField {
	return nil;
}

+ (NSString *) defaultErrorDomain {
	return nil;
}

#if KBAPISUPPORT_XML
+ (BOOL) errorCodeFieldIsAttribute {
	return NO;
}

+ (BOOL) errorDescriptionFieldIsAttribute {
	return NO;
}

+ (BOOL) errorDomainFieldIsAttribute {
	return NO;
}
#endif

#if KBAPISUPPORT_JSON
+ (instancetype) entityFromJSON:(id)JSON {
	NSString *errorCodeField = [self errorCodeField];
	NSString *errorDescriptionField = [self errorDescriptionField];
	if (!(errorCodeField && errorDescriptionField)) {
		return nil;
	}
	if (![JSON isKindOfClass:[NSDictionary class]]) {
		return nil;
	}
	
	NSString *errorDomainField = [self errorDomainField];
	NSString *errorDomain = nil;
	if (errorDomainField) {
		errorDomain = [JSON objectForKey:errorDomainField];
	}
	if (!errorDomain) {
		errorDomain = [self defaultErrorDomain];
	}
	if (!errorDomain) {
		errorDomain = kKBErrorDomain;
	}
	NSInteger errorCode = 0;
	id errorCodeObj = [JSON objectForKey:errorCodeField];
	if ([errorCodeObj isKindOfClass:[NSString class]] || [errorCodeObj isKindOfClass:[NSNumber class]]) {
		errorCode = [errorCodeObj integerValue];
	}
	NSString *errorDescription = [JSON objectForKey:errorDescriptionField];
	NSDictionary *userInfo = nil;
	if (errorDescription) {
		userInfo = @{NSLocalizedDescriptionKey: errorDescription};
	}
	
	return [self errorWithDomain:errorDomain code:errorCode userInfo:userInfo];
}
#endif

#if KBAPISUPPORT_XML
+ (instancetype) entityFromXML:(GDataXMLElement *)XML {
	NSString *errorCodeField = [self errorCodeField];
	NSString *errorDescriptionField = [self errorDescriptionField];
	if (!(errorCodeField && errorDescriptionField)) {
		return nil;
	}
	
	NSString *errorDomainField = [self errorDomainField];
	NSString *errorDomain = nil;
	if (errorDomainField) {
		errorDomain = ([self errorDomainFieldIsAttribute] ? ([XML attributeForName:errorDomainField].stringValue) : [XML childStringValue:errorDomainField]);
	}
	if (!errorDomain) {
		errorDomain = [self defaultErrorDomain];
	}
	if (!errorDomain) {
		errorDomain = kKBErrorDomain;
	}
	NSInteger errorCode = ([self errorCodeFieldIsAttribute] ? ([XML attributeForName:errorCodeField].stringValue.integerValue) : ([XML childStringValue:errorCodeField].integerValue));
	NSString *errorDescription = ([self errorDescriptionFieldIsAttribute] ? ([XML attributeForName:errorDescriptionField].stringValue) : [XML childStringValue:errorDescriptionField]);
	NSDictionary *userInfo = nil;
	if (errorDescription) {
		userInfo = @{NSLocalizedDescriptionKey: errorDescription};
	}
	
	return [self errorWithDomain:errorDomain code:errorCode userInfo:userInfo];
}
#endif

@end
