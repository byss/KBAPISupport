//
//  KBAPIRequestSerializers.m
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

#import "KBAPIRequestSerializers.h"

#import "KBAPIRequest.h"
#import "KBAPIRequestSerializationBase.h"

@implementation KBAPIRequestSerializer

@synthesize userInfo = _userInfo;

- (void) dealloc {
	[_userInfo release];
	[super dealloc];
}

- (BOOL) shouldSerializeRequestParametersAsBodyDataForRequest: (KBAPIRequest *) request {
	KBAPIRequestHTTPMethod const method = request.HTTPMethod;
	return !([method isEqualToString:KBAPIRequestHTTPMethodGET] || [method isEqualToString:KBAPIRequestHTTPMethodDELETE]);
}

- (NSURLRequest *) serializeRequest: (KBAPIRequest *) request error: (NSError **) error {
	NSMutableURLRequest *const serializedRequest = [[NSMutableURLRequest alloc] initWithURL:request.URL];
	serializedRequest.HTTPMethod = request.HTTPMethod;
	// TODO: log method & URL
	
	NSMutableDictionary <NSString *, NSString *> *headers = [KBAPIRequestDefaultHeaders mutableCopy];
	[headers addEntriesFromDictionary:request.HTTPHeaders];
	serializedRequest.allHTTPHeaderFields = headers;
	[headers release];
	// TODO: log resulting headers
	
	NSError *encodingError = nil;
	if ([self serializeParameters:request.parameters asBodyData:[self shouldSerializeRequestParametersAsBodyDataForRequest:request] intoRequest:serializedRequest error:&encodingError]) {
		NSURLRequest *const result = [serializedRequest copy];
		[serializedRequest release];
		return [result autorelease];
	} else {
		// TODO: log encoding error
		if (error) {
			*error = encodingError;
		}
		[serializedRequest release];
		return nil;
	}
}

- (BOOL) serializeParameters: (NSDictionary <NSString *, id> *) parameters asBodyData: (BOOL) asBodyData intoRequest: (NSMutableURLRequest *) request error: (NSError **) error {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

@end
