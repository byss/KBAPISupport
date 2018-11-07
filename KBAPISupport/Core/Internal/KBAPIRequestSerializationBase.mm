//
//  KBAPIRequestSerializationBase.m
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
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

#import "KBAPIRequestSerializationBase.h"

#import <mutex>
#import <atomic>
#import <shared_mutex>
#import <sys/utsname.h>
#import <objc/runtime.h>

@interface KBAPIStaticDictionary: NSDictionary <NSString *, NSString *>
@end

template <std::size_t _N, std::size_t _M, void (*_Recalc) (std::size_t, NSString **)>
struct KBAPIStaticDictionaryObject {
public:
	static std::size_t constexpr count = _N;
	
	KBAPIStaticDictionaryObject (NSString *const *keys, NSString *const *immutableValues): keys (keys), immutableValues (immutableValues), isDirty (true) {
		object_setClass ((id) this, [KBAPIStaticDictionary class]);
		[[NSNotificationCenter defaultCenter] addObserverForName:NSCurrentLocaleDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
			this->setDirty ();
		}];
	}
	
	NSString *key (size_t const index) const {
		return this->keys [index];
	}
	
	void getKeys (NSString **buffer, size_t const cnt) const {
		memcpy (buffer, this->keys, sizeof (id) * cnt);
	}
	
	std::size_t indexForKey (NSString *const key) {
		for (std::size_t i = 0; i < _N; i++) {
			if ([this->keys [i] isEqualToString:key]) {
				return i;
			}
		}
		return _N;
	}
	
	NSString *value (size_t const index) {
		if (index < (_N - _M)) {
			return this->immutableValues [index];
		} else {
			this->updateMutableValuesIfNeeded ();
			return this->mutableValues [index - (_N - _M)];
		}
	}
	
	void getValues (NSString **const buffer, size_t const cnt) {
		switch (cnt) {
			case _M ... _N:
				this->updateMutableValuesIfNeeded ();
				std::memcpy (buffer + _N - _M, this->mutableValues, (cnt - (_N - _M)) * sizeof (id));
			case 1 ... _M - 1:
				std::memcpy (buffer, immutableValues, (cnt - _M) * sizeof (id));
			case 0:
				break;
		}
	}
	
	void setDirty () {
		std::scoped_lock lock (this->valuesMutex);
		this->isDirty = true;
	}
	
private:
	void updateMutableValuesIfNeeded () {
		std::shared_lock rlock (this->valuesMutex);
		if (this->isDirty) {
			if (this->updatingValues.test_and_set (std::memory_order_acquire)) {
				std::shared_lock (this->valuesMutex);
			} else {
				rlock.unlock ();
				std::scoped_lock lock (this->valuesMutex);
				for (size_t i = 0; i < _M; i++) {
					_Recalc (i, this->mutableValues + i);
				}
				this->updatingValues.clear (std::memory_order_release);
				this->isDirty = false;
			}
		}
	}
	
	Class isa;
	NSString *const *const keys;
	NSString *const *const immutableValues;
	NSString *mutableValues [_M];
	std::atomic_flag updatingValues = ATOMIC_FLAG_INIT;
	std::shared_mutex valuesMutex;
	bool isDirty;
};

static NSString *const KBAPIRequestDefaultHeaderNames [] = {
	@"Accept", @"Accept-Encoding", @"Accept-Language", @"User-Agent",
};
static NSString *const KBAPIRequestDefaultHeaderValues [] = {
	@"application/json", @"gzip, deflate",
};
void KBAPIRequestDefaultHeaderRecalculateValue (size_t const index, NSString **output);

static KBAPIStaticDictionaryObject <
	sizeof (KBAPIRequestDefaultHeaderNames) / sizeof (*KBAPIRequestDefaultHeaderNames),
	sizeof (KBAPIRequestDefaultHeaderNames) / sizeof (*KBAPIRequestDefaultHeaderNames) - sizeof (KBAPIRequestDefaultHeaderValues) / sizeof (*KBAPIRequestDefaultHeaderValues),
	KBAPIRequestDefaultHeaderRecalculateValue
> KBAPIRequestDefaultHeadersInstance { KBAPIRequestDefaultHeaderNames, KBAPIRequestDefaultHeaderValues };

NSDictionary <NSString *, NSString *> const *const KBAPIRequestDefaultHeaders = (id) &KBAPIRequestDefaultHeadersInstance;

@interface KBAPIStaticDictionary () {
	char const opaque [sizeof (KBAPIRequestDefaultHeaders) - sizeof (Class)];
}

@end

@interface KBAPIStaticDictionaryKeysEnumerator: NSEnumerator <NSString *>
@end

@implementation KBAPIStaticDictionary

- (NSUInteger) retainCount {
	return NSUIntegerMax;
}

- (instancetype) retain {
	return self;
}

- (oneway void) release {}

- (NSUInteger) count {
	return decltype (KBAPIRequestDefaultHeadersInstance)::count;
}

- (NSString *) objectForKey: (NSString *) aKey {
	auto const keyIndex = ((decltype (KBAPIRequestDefaultHeadersInstance) *) self)->indexForKey (aKey);
	return ((keyIndex < decltype (KBAPIRequestDefaultHeadersInstance)::count) ? ((decltype (KBAPIRequestDefaultHeadersInstance) *) self)->value (keyIndex) : nil);
}

- (NSEnumerator *) keyEnumerator {
	return [[KBAPIStaticDictionaryKeysEnumerator new] autorelease];
}

- (id) copyWithZone: (NSZone *) zone {
	return self;
}

- (id) mutableCopyWithZone: (NSZone *) zone {
	static id const sharedKeySet = [NSDictionary sharedKeySetForKeys:[NSArray <NSString *> arrayWithObjects:KBAPIRequestDefaultHeaderNames count:decltype (KBAPIRequestDefaultHeadersInstance)::count]];
	auto const result = [[NSMutableDictionary <NSString *, NSString *> dictionaryWithSharedKeySet:sharedKeySet] retain];
	[result setDictionary:self];
	return result;
}

- (void) getObjects: (id []) objects andKeys: (id []) keys count: (NSUInteger) count {
	auto const thisValue = ((decltype (KBAPIRequestDefaultHeadersInstance) *) self);
	if (keys) {
		thisValue->getKeys (keys, count);
	}
	if (objects) {
		thisValue->getValues (objects, count);
	}
}

@end

@implementation KBAPIStaticDictionaryKeysEnumerator {
	std::size_t _index;
}

- (NSString *) nextObject {
	return (_index < decltype (KBAPIRequestDefaultHeadersInstance)::count) ? KBAPIRequestDefaultHeaderNames [_index++] : nil;
}

@end

void KBAPIRequestDefaultHeaderRecalculateValue (size_t const index, NSString **output) {
	switch (index) {
		case 0: {
			auto const preferredLocalizations = [[NSBundle mainBundle] preferredLocalizations];
			if (auto const preferred = preferredLocalizations.firstObject) {
				NSMutableString *result = [[NSMutableString alloc] initWithString:preferred];
				[result appendString:@"; q = 1.0"];
				for (NSUInteger i = 1; i < preferredLocalizations.count; i++) {
					[result appendFormat:@"%@; q = %.1f", preferredLocalizations [i], 1.0 / (1 << i)];
				}
				*output = [[NSString alloc] initWithString:result];
				[result release];
			} else {
				*output = [NSLocale currentLocale].localeIdentifier;
			}
		} break;
			
		case 1: {
			auto const mainBundleInfo = [NSBundle mainBundle].infoDictionary;
			auto const thisBundleInfo = [NSBundle bundleForClass:[KBAPIStaticDictionary class]].infoDictionary;
			utsname uts;
			uname (&uts);
			*output = [[NSString alloc] initWithFormat:@"%@/%@ (%s; U; %@; %@) %@/%@ CFNetwork/%.2f Darwin/%s",
				mainBundleInfo [(id) kCFBundleNameKey], mainBundleInfo [(id) kCFBundleVersionKey],
				uts.machine, [NSProcessInfo processInfo].operatingSystemVersionString, [NSLocale currentLocale].localeIdentifier,
				thisBundleInfo [(id) kCFBundleNameKey], thisBundleInfo [(id) kCFBundleVersionKey],
				kCFCoreFoundationVersionNumber,
				uts.version];
		} break;
			
		default:
			*output = nil;
		}
}
