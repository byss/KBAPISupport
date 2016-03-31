//
//  KBAPISessionConnection.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/31/16.
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

#import "KBAPISessionConnection.h"
#import "KBAPIConnection_Protected.h"

#import "KBAPISessionRequestOperation.h"

#if !__has_include (<KBAPISupport/KBAPISupport+NSURLConnection.h>)
@interface KBAPIConnection (NSURLSessionOnly)
@end

@implementation KBAPIConnection (NSURLSessionOnly)

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
	if (self == [KBAPIConnection class]) {
		return [KBAPISessionConnection allocWithZone:zone];
	} else {
		return [super allocWithZone:zone];
	}
}

@end
#endif

@implementation KBAPISessionConnection

+ (NSURLSession *_Nonnull) defaultSession {
	return [KBAPISessionRequestOperation defaultSession];
}

+ (void) setDefaultSession: (NSURLSession *_Nullable) session {
	[KBAPISessionRequestOperation setDefaultSession:session];
}

- (instancetype)initWithRequest:(KBAPIRequest *)request {
	return [self initWithRequest:request session:nil];
}

- (instancetype _Nullable) initWithRequest: (KBAPIRequest *_Nonnull) request session: (NSURLSession *_Nullable) session {
	if (self = [super initWithRequest:request]) {
		_session = session;
	}
	
	return self;
}

- (KBAPIRequestOperation *)createRequestOperationWithRequest:(KBAPIRequest *)request {
	KBAPIRequestOperation *result = [super createRequestOperationWithRequest:request];
	
	KBAPIRequestOperation *sessionRequestOperation = [[KBAPISessionRequestOperation alloc] initWithRequest:request session:self.session completion:NULL];
	sessionRequestOperation.timeout = result.timeout;
	[result addSuboperation:sessionRequestOperation];
	
	return result;
}

@end
