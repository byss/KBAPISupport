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
#import "NSObject+KBMapping.h"

@interface NSError (KBMappingDeprecatedSupport)

+ (void) enableDeprecatedClassPropertiesSupportIfNeeded;

@end

KBErrorMappingKeyPath const KBErrorCodeMappingKeyPath = @"_kb_error_key_path_code";
KBErrorMappingKeyPath const KBErrorLocalizedDescriptionMappingKeyPath = @"_kb_error_key_path_localized_description";
KBErrorMappingKeyPath const KBErrorDomainMappingKeyPath = @"_kb_error_key_path_domain";

@implementation NSError (KBMapping)

+ (NSString *_Nullable) defaultErrorDomain {
	return nil;
}

+ (instancetype) newInstanceForJSONObject: (id) JSONObject mappingContext: (id) mappingContext {
	if ([JSONObject isKindOfClass:[NSDictionary class]]) {
		return (id) [NSMutableDictionary <NSString *, id> new];
	} else {
		return nil;
	}
}

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
+ (instancetype) objectFromJSON:(id)JSON mappingContext: (id _Nullable) mappingContext {
	[self enableDeprecatedClassPropertiesSupportIfNeeded];
	
	NSMutableDictionary <NSString *, id> *mappedUserInfo = (id) [super objectFromJSON:JSON mappingContext:mappingContext];
	
	NSNumber *code = mappedUserInfo [KBErrorCodeMappingKeyPath];
	[mappedUserInfo removeObjectForKey:KBErrorCodeMappingKeyPath];
	
	NSString *domain = mappedUserInfo [KBErrorDomainMappingKeyPath];
	[mappedUserInfo removeObjectForKey:KBErrorDomainMappingKeyPath];
	if (!domain) {
		domain = [self defaultErrorDomain];
	}
	
	if (!(code && domain)) {
		return nil;
	}
	
	NSString *localizedDescription = mappedUserInfo [KBErrorLocalizedDescriptionMappingKeyPath];
	if (localizedDescription) {
		[mappedUserInfo removeObjectForKey:KBErrorLocalizedDescriptionMappingKeyPath];
		mappedUserInfo [NSLocalizedDescriptionKey] = localizedDescription;
	}
	
	return [[self alloc] initWithDomain:domain code:code.integerValue userInfo:mappedUserInfo];
}
#endif

@end

#import <objc/runtime.h>

@implementation NSError (KBMappingDeprecatedSupport)

+ (void) enableDeprecatedClassPropertiesSupportIfNeeded {
	if (objc_getAssociatedObject (self, _cmd)) {
		return;
	}
	
	@synchronized (self) {
		if (objc_getAssociatedObject (self, _cmd)) {
			return;
		}
		
		if ([self respondsToSelector:@selector (errorCodeKeyPath)] ||
		    [self respondsToSelector:@selector (errorLocalizedDescriptionKeyPath)] ||
		    [self respondsToSelector:@selector (errorDomainKeyPath)]) {
			Class metaclass = object_getClass (self);
			Method originalMethod = class_getInstanceMethod (metaclass, @selector (initializeMappingProperties));
			Method swizzledMethod = class_getInstanceMethod (metaclass, @selector (kb_deprecated_support_initializeMappingProperies));
			if (class_addMethod (metaclass, @selector (initializeMappingProperties), method_getImplementation (swizzledMethod), method_getTypeEncoding (swizzledMethod))) {
				class_replaceMethod (metaclass, @selector (kb_deprecated_support_initializeMappingProperies), method_getImplementation (originalMethod), method_getTypeEncoding (originalMethod));
			} else {
				method_exchangeImplementations (originalMethod, swizzledMethod);
			}
		}
		
		objc_setAssociatedObject (self, _cmd, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
}

+ (NSArray <id <KBMappingProperty>> *) kb_deprecated_support_initializeMappingProperies {
	NSMutableArray <id <KBMappingProperty>> *mappingProperties = [[NSMutableArray <id <KBMappingProperty>> alloc] initWithCapacity:3];
	if ([self respondsToSelector:@selector (errorCodeKeyPath)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
		NSString *errorCodeKeyPath = [self errorCodeKeyPath];
#pragma clang diagnostic pop
		if (errorCodeKeyPath) {
			[mappingProperties addObject:(id) [[KBNumberMappingProperty alloc] initWithKeyPath:KBErrorCodeMappingKeyPath sourceKeyPath:errorCodeKeyPath]];
		}
	}
	if ([self respondsToSelector:@selector (errorLocalizedDescriptionKeyPath)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
		NSString *errorLocalizedDescriptionKeyPath = [self errorLocalizedDescriptionKeyPath];
#pragma clang diagnostic pop
		if (errorLocalizedDescriptionKeyPath) {
			[mappingProperties addObject:(id) [[KBNumberMappingProperty alloc] initWithKeyPath:KBErrorLocalizedDescriptionMappingKeyPath sourceKeyPath:errorLocalizedDescriptionKeyPath]];
		}
	}
	if ([self respondsToSelector:@selector (errorDomainKeyPath)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
		NSString *errorDomainKeyPath = [self errorDomainKeyPath];
#pragma clang diagnostic pop
		if (errorDomainKeyPath) {
			[mappingProperties addObject:(id) [[KBNumberMappingProperty alloc] initWithKeyPath:KBErrorDomainMappingKeyPath sourceKeyPath:errorDomainKeyPath]];
		}
	}
	
	NSArray <id <KBMappingProperty>> *otherProperties = [self kb_deprecated_support_initializeMappingProperies];
	if (otherProperties) {
		[mappingProperties addObjectsFromArray:otherProperties];
	}
	return mappingProperties;
}

@end
