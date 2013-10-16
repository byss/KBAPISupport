//
//  KBAPIConnection.m
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 26.11.12.
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

#import "KBAPIConnection.h"
#import "KBAPIRequest.h"
#import "KBEntity.h"
#import "KBError.h"
#import "KBNetworkIndicator.h"
#import "ARCSupport.h"

#if KBAPISUPPORT_USE_SBJSON
#	import "SBJsonParser.h"
#endif
#if KBAPISUPPORT_XML
#	import "GDataXMLNode.h"
#endif

#import "KBAPISupport-debug.h"

#if KBAPISUPPORT_BOTH_FORMATS
NSString *const KBJSONErrorKey = @"KBJSONErrorKey";
NSString *const KBXMLErrorKey = @"KBXMLErrorKey";
#endif

static NSTimeInterval defaultTimeout = 30.0;

@interface KBAPIConnection () {
@private
	NSMutableData *_buffer;
	Class _expected;
	Class _error;
#if KBAPISUPPORT_USE_SBJSON
	SBJSonParser *_parser;
#endif
}

@property (nonatomic, retain) KBAPIRequest *_request;

+ (NSString *) methodName: (KBAPIRequestMethod) method;

@end

@implementation KBAPIConnection

+ (NSTimeInterval) defaultTimeout {
	return defaultTimeout;
}

+ (void) setDefaultTimeout:(NSTimeInterval)timeout {
	if (timeout < 1.0) {
		timeout = 1.0;
	}
	
	defaultTimeout = timeout;
}

+ (NSString *) methodName: (KBAPIRequestMethod) method {
	switch (method) {
		case KBAPIRequestMethodGET:
			return @"GET";
			
		case KBAPIRequestMethodPOST:
			return @"POST";
			
		case KBAPIRequestMethodPUT:
			return @"PUT";
			
		case KBAPIRequestMethodDELETE:
			return @"DELETE";
			
		default:
			return @"GET";
	}
}

#if KBAPISUPPORT_BOTH_FORMATS
+ (instancetype) connectionWithRequest: (KBAPIRequest *) request delegate: (id <KBAPIConnectionDelegate>) delegate responseType: (KBAPIConnectionResponseType) responseType {
	KBAPIConnection *result = [self connectionWithRequest:request delegate:delegate];
	result.responseType = responseType;
	return result;
}
#endif

+ (instancetype) connectionWithRequest:(KBAPIRequest *)request delegate:(id<KBAPIConnectionDelegate>)delegate {
	KBAPIConnection *result = [self new];
	result._request = request;
	result.delegate = delegate;
	return KB_AUTORELEASE (result);
}

- (id) init {
	if (self = [super init]) {
		_buffer = [NSMutableData new];
#if KBAPISUPPORT_USE_SBJSON
		_parser = [SBJSONParser new];
#endif
		_timeout = defaultTimeout;
	}
	return self;
}

#if !__has_feature(objc_arc)
- (void) dealloc {
	[_buffer release];
	[__request release];
	[_expected release];
	[_error release];
	[_delegate release];
#	if KBAPISUPPORT_USE_SBJSON
	[_parser release];
#	endif
	
	[super dealloc];
}
#endif

- (void) startForClass:(Class)clazz {
	[self startForClass:clazz error:nil];
}

- (void) startForClass:(Class)clazz error:(Class)error {
	if ([clazz conformsToProtocol:@protocol(KBEntity)]) {
		_expected = KB_RETAIN (clazz);
	}
	if ([error conformsToProtocol:@protocol(KBEntity)]) {
		_error = KB_RETAIN (error);
	}
	[self start];
}

- (void) start {
	KBAPISUPPORT_F_START
	
	KBAPIRequest *theRequest = self._request;
	
	if (!_expected) {
		Class expected = [[theRequest class] expected];
		if ([expected conformsToProtocol:@protocol(KBEntity)]) {
			_expected = KB_RETAIN (expected);
		}
	}
	if (!_error) {
		Class error = [[theRequest class] error];
		if ([error conformsToProtocol:@protocol(KBEntity)]) {
			_error = KB_RETAIN (error);
		}
	}
	
	KBAPISUPPORT_LOG (@"request: %@", theRequest.URL);
	
	[KBNetworkIndicator requestStarted];
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:theRequest.URL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.timeout];
	req.HTTPMethod = [[self class] methodName:theRequest.requestMethod];
	NSData *bodyData = theRequest.bodyData;
	if (bodyData) {
		req.HTTPBody = bodyData;
	}
	NSDictionary *addnHeaders = theRequest.additionalHeaders;
	for (NSString *header in addnHeaders) {
		[req setValue:[addnHeaders objectForKey:header] forHTTPHeaderField:header];
	}
	
	[NSURLConnection connectionWithRequest:req delegate:self];
	
	KBAPISUPPORT_F_END
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	_buffer.length = 0;
	KBAPISUPPORT_LOG (@"HTTP code: %d", ((NSHTTPURLResponse *) response).statusCode);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_buffer appendData:data];
	KBAPISUPPORT_LOG (@"Received %d bytes", data.length);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[KBNetworkIndicator requestFinished];
	KBAPISUPPORT_LOG (@"error: %@", error);
	[self.delegate apiConnection:self didFailWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	KBAPISUPPORT_F_START
	
	KBAPISUPPORT_LOG (@"Request OK");
	[KBNetworkIndicator requestFinished];
	
#define PREPARED_JSON (_buffer) //// >1 ////
#if (defined (DEBUG) && KBAPISUPPORT_DEBUG) || KBAPISUPPORT_DECODE || KBAPISUPPORT_USE_SBJSON
	char *bytes = malloc (_buffer.length + 1);
	memcpy (bytes, _buffer.bytes, _buffer.length);
	bytes [_buffer.length] = 0;
#	if KBAPISUPPORT_DECODE
	NSString *decodedString = [NSString stringWithCString:bytes encoding:KBAPISUPPORT_DECODE_FROM];
	KBAPISUPPORT_LOG (@"response: %@", decodedString);
	// maybe there is some method like -(NSData *)dataWithData:(NSData *) fromEncoding:(NSStringEncoding)from toEncoding:(NSStringEncoding)to ?
#		if KBAPISUPPORT_JSON && !KBAPISUPPORT_USE_SBJSON
	unichar *decodedBytes = malloc (decodedString.length * sizeof (unichar));
	[decodedString getCharacters:decodedBytes range: NSMakeRange (0, decodedString.length)];
	NSData *decodedData = [NSData dataWithBytesNoCopy:decodedBytes length:(decodedString.length * sizeof (unichar)) freeWhenDone:YES];
	decodedBytes = NULL;
#			undef PREPARED_JSON
#			define PREPARED_JSON (decodedData) //// >1 ////
#		endif // KBAPISUPPORT_JSON && !KBAPISUPPORT_USE_SBJSON
#	elif KBAPISUPPORT_USE_SBJSON
	NSString *decodedString = [NSString stringWithUTF8String:bytes];
#	else // KBAPISUPPORT_DECODE
	KBAPISUPPORT_LOG (@"response: %s", bytes);
#	endif // KBAPISUPPORT_DECODE
	free (bytes);
#endif // (defined (DEBUG) && KBAPISUPPORT_DEBUG) || KBAPISUPPORT_DECODE
	
#if KBAPISUPPORT_JSON
	id JSONResponse = nil;
	NSError *JSONError = nil;
#endif
#if KBAPISUPPORT_XML
	GDataXMLDocument *XMLResponse = nil;
	NSError *XMLError = nil;
#endif

#if KBAPISUPPORT_JSON
#	if KBAPISUPPORT_BOTH_FORMATS
	if ((self.responseType == KBAPIConnectionResponseTypeJSON) || (self.responseType == KBAPIConnectionResponseTypeAuto)) {
#	endif
#	if KBAPISUPPORT_USE_SBJSON
		JSONResponse = [_parser objectWithString:decodedString error:&JSONError];
#	else
		JSONResponse = [NSJSONSerialization JSONObjectWithData:PREPARED_JSON options:NSJSONReadingAllowFragments error:&JSONError];
#	endif
#	if KBAPISUPPORT_BOTH_FORMATS
	}
#	endif
#endif

#undef PREPARED_JSON //// <1 ////

#if KBAPISUPPORT_XML
#	if KBAPISUPPORT_BOTH_FORMATS
	if ((self.responseType == KBAPIConnectionResponseTypeXML) || (self.responseType == KBAPIConnectionResponseTypeAuto)) {
#	endif
#	if KBAPISUPPORT_DECODE
		XMLResponse = [[GDataXMLDocument alloc] initWithXMLString:decodedString options:0 error:&XMLError];
#	else
		XMLResponse = [[GDataXMLDocument alloc] initWithData:_buffer options:0 error:&XMLError];
#	endif
#	if KBAPISUPPORT_BOTH_FORMATS
	}
#	endif
#endif

#if KBAPISUPPORT_BOTH_FORMATS
	if ((((self.responseType == KBAPIConnectionResponseTypeJSON) && !JSONResponse) ||
	    ((self.responseType == KBAPIConnectionResponseTypeXML) && !XMLResponse) ||
	    ((self.responseType == KBAPIConnectionResponseTypeAuto) && ((JSONResponse == nil) == (XMLResponse == nil)))
	   ) &&
#elif KBAPISUPPORT_JSON
	if (!JSONResponse &&
#elif KBAPISUPPORT_XML
	if (!XMLResponse &&
#else
#	error There is no error.
#endif
			(![self.delegate respondsToSelector:@selector(apiConnection:didReceiveData:)])) {

#if KBAPISUPPORT_JSON
		KBAPISUPPORT_LOG (@"JSON error: %@", JSONError);
#endif
#if KBAPISUPPORT_XML
		KBAPISUPPORT_LOG (@"XML error: %@", XMLError);
#endif

#if KBAPISUPPORT_BOTH_FORMATS
		NSError *cumulativeError = [NSError errorWithDomain:@"KBAPIConnection" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Response is neither JSON nor XML.", KBJSONErrorKey: (JSONError ? JSONError : [NSNull null]), KBXMLErrorKey: (XMLError ? XMLError : [NSNull null])}];
#	define REPORTED_ERROR (cumulativeError) //// >2 ////
#elif KBAPISUPPORT_JSON
#	define REPORTED_ERROR (JSONError) //// >2 ////
#elif	KBAPISUPPORT_XML
#	define REPORTED_ERROR (XMLError) //// >2 ////
#else
#define REPORTED_ERROR (nil) //// >2 ////
#	error You shall not pass!
#endif

		KBAPISUPPORT_LOG (@"error: %@", REPORTED_ERROR);
		[self.delegate apiConnection:self didFailWithError:REPORTED_ERROR];

#undef REPORTED_ERROR //// <2 ////

		KBAPISUPPORT_F_END
		return;
	}
	
	if (_expected) {
		if ([self.delegate respondsToSelector:@selector(apiConnection:didReceiveResponse:)]) {
			id <KBEntity> responseObject = nil;
#if KBAPISUPPORT_BOTH_FORMATS
			if (self.responseType == KBAPIConnectionResponseTypeAuto) {
				if (JSONResponse) {
#endif
#if KBAPISUPPORT_JSON
					responseObject = [_expected entityFromJSON:JSONResponse];
#endif
#if KBAPISUPPORT_BOTH_FORMATS
				} else if (XMLResponse) {
#endif
#if KBAPISUPPORT_XML
					responseObject = [_expected entityFromXML:XMLResponse.rootElement];
#endif
#if KBAPISUPPORT_BOTH_FORMATS
				} // else if () {
			}
#endif
			
			if (responseObject) {
				[self.delegate apiConnection:self didReceiveResponse:responseObject];
			} else {
				KBError *error = nil;
				if (_error) {
#if KBAPISUPPORT_BOTH_FORMATS
					if (JSONResponse) {
#endif
#if KBAPISUPPORT_JSON
						error = [_error entityFromJSON:JSONResponse];
#endif
#if KBAPISUPPORT_BOTH_FORMATS
					} else if (XMLResponse) {
#endif
#if KBAPISUPPORT_XML
						error = [_error entityFromXML:XMLResponse.rootElement];
#endif
#if KBAPISUPPORT_BOTH_FORMATS
					}
#endif
				}
				if (error) {
					[self.delegate apiConnection:self didFailWithError:error];
				} else {
					NSString *formatString = (
#if KBAPISUPPORT_BOTH_FORMATS
						JSONResponse ?
#endif
#if KBAPISUPPORT_JSON
							@"JSON"
#endif
#if KBAPISUPPORT_BOTH_FORMATS
						: (XMLResponse ?
#endif
#if KBAPISUPPORT_XML
							@"XML"
#endif
#if KBAPISUPPORT_BOTH_FORMATS
						:	@"this damn")
#endif
					);
					NSError *genericError = [NSError errorWithDomain:@"KBAPIConnection" code:-1 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Cannot build %@ from %@ object.", _expected, formatString]}];
					KBAPISUPPORT_LOG (@"error: %@", genericError);
					[self.delegate apiConnection:self didFailWithError:genericError];
				}
			}
#if KBAPISUPPORT_JSON
		} else if (JSONResponse && [self.delegate respondsToSelector:@selector(apiConnection:didReceiveJSON:)]) {
			[self.delegate apiConnection:self didReceiveJSON:JSONResponse];
#endif
#if KBAPISUPPORT_XML
		} else if (XMLResponse && [self.delegate respondsToSelector:@selector(apiConnection:didReceiveXML:)]) {
			[self.delegate apiConnection:self didReceiveXML:XMLResponse];
#endif
		} else if (self.delegate) {
			KBAPISUPPORT_BUG_HERE
		}

		KB_RELEASE (_expected);
		KB_RELEASE (_error);
		_expected = nil;
		_error = nil;
#if KBAPISUPPORT_JSON
	} else if (JSONResponse && [self.delegate respondsToSelector:@selector(apiConnection:didReceiveJSON:)]) {
		[self.delegate apiConnection:self didReceiveJSON:JSONResponse];
#endif
#if KBAPISUPPORT_XML
	} else if (XMLResponse && [self.delegate respondsToSelector:@selector(apiConnection:didReceiveXML:)]) {
		[self.delegate apiConnection:self didReceiveXML:XMLResponse];
#endif
	} else if ([self.delegate respondsToSelector:@selector(apiConnection:didReceiveData:)]) {
		[self.delegate apiConnection:self didReceiveData:_buffer];
	} else {
		NSError *error = [NSError errorWithDomain:@"KBAPIConnection" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"The delegate receives only error messages, so here's one."}];
		KBAPISUPPORT_LOG (@"error: %@", error);
		[self.delegate apiConnection:self didFailWithError:error];
	}

#if KBAPISUPPORT_XML
	KB_RELEASE (XMLResponse);
#endif
	_buffer.length = 0;
		
	KBAPISUPPORT_F_END
}

@end
