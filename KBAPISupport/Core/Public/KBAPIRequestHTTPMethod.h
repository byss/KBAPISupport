//
//  KBAPIRequestHTTPMethod.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 8/14/18.
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

#if __cplusplus

namespace KB::APIRequest {
	using HTTPMethod = KBAPIRequestHTTPMethod;
}

#	define _HTTP_METHOD(_Meth) KBAPIRequestHTTPMethod const KBAPIRequestHTTPMethod ## _Meth

#	define HTTP_METHODS_FOREACH(args...) \
	args (HEAD); \
	args (GET); \
	args (POST); \
	args (PUT); \
	args (PATCH); \
	args (DELETE);

#	define DECLARE_HTTP_METHOD(_Meth) \
	extern _HTTP_METHOD(_Meth); \
	namespace KB::APIRequest { \
		HTTPMethod constexpr HTTPMethod ## _Meth = @ #_Meth; \
	}

NS_ASSUME_NONNULL_BEGIN

HTTP_METHODS_FOREACH (DECLARE_HTTP_METHOD)

NS_ASSUME_NONNULL_END

#endif
