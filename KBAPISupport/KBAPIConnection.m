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

#if KBAPISUPPORT_XML
#	if KBAPISUPPORT_PODS_BUILD
#		import <GDataXML-HTML/GDataXMLNode.h>
#	else
#		import "GDataXMLNode.h"
#	endif
#endif
#if KBAPISUPPORT_USE_DELEGATES
#	define _KBAPISUPPORT_DELEGATE_ARG_VALUE delegate:delegate
#else
#	define _KBAPISUPPORT_DELEGATE_ARG_VALUE
#endif

#import "KBAPISupport-debug.h"

#if KBAPISUPPORT_BOTH_FORMATS
NSString *const KBJSONErrorKey = @"KBJSONErrorKey";
NSString *const KBXMLErrorKey = @"KBXMLErrorKey";
#endif

static NSTimeInterval defaultTimeout = 30.0;

@interface KBAPIConnection () {
@private
	KBAPIRequest *_request;
	NSURLConnection *_connection;
	NSMutableData *_buffer;
	__unsafe_unretained Class _expected;
	__unsafe_unretained Class _error;
}

#if KBAPISUPPORT_USE_BLOCKS
@property (nonatomic, copy) KBAPICompletionBlock completionBlock;
@property (nonatomic, copy) KBAPIRawObjectCompletionBlock rawObjectCompletionBlock;
@property (nonatomic, copy) KBAPIRawDataCompletionBlock rawDataCompletionBlock;
#endif

+ (NSString *) methodName: (KBAPIRequestMethod) method;

- (instancetype) initWithRequest: (KBAPIRequest *) request;

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
+ (instancetype) connectionWithRequest: (KBAPIRequest *) request _KBAPISUPPORT_DELEGATE_ARG responseType: (KBAPIConnectionResponseType) responseType {
	return [self connectionWithRequest:request _KBAPISUPPORT_DELEGATE_ARG_VALUE responseType:responseType userInfo:nil];
}

+ (instancetype) connectionWithRequest:(KBAPIRequest *)request _KBAPISUPPORT_DELEGATE_ARG responseType:(KBAPIConnectionResponseType)responseType userInfo:(NSDictionary *)userInfo {
	KBAPIConnection *result = [self connectionWithRequest:request _KBAPISUPPORT_DELEGATE_ARG_VALUE];
	result.responseType = responseType;
	result.userInfo = userInfo;
	return result;
}
#endif

+ (instancetype) connectionWithRequest:(KBAPIRequest *)request _KBAPISUPPORT_DELEGATE_ARG {
	return [self connectionWithRequest:request _KBAPISUPPORT_DELEGATE_ARG_VALUE userInfo:nil];
}

+ (instancetype) connectionWithRequest:(KBAPIRequest *)request _KBAPISUPPORT_DELEGATE_ARG userInfo:(NSDictionary *)userInfo {
	KBAPIConnection *result = [[self alloc] initWithRequest:request];
#if KBAPISUPPORT_USE_DELEGATES
	result.delegate = delegate;
#endif
	result.userInfo = userInfo;
	return KB_AUTORELEASE (result);
}

- (instancetype)init {
	return [self initWithRequest:nil];
}

- (instancetype)initWithRequest:(KBAPIRequest *)request {
	if (!request) {
		KB_RELEASE (self);
		return nil;
	}
	
	if (self = [super init]) {
		_request = KB_RETAIN (request);
		_buffer = [NSMutableData new];
		_timeout = defaultTimeout;
	}
	
	return self;
}

#if !__has_feature(objc_arc)
- (void) dealloc {
	[_buffer release];
	[_request release];
	[_delegate release];
	[_userInfo release];
	
	[super dealloc];
}
#endif

- (void) startForClass:(Class)clazz {
	[self startForClass:clazz error:nil];
}

- (void) startForClass:(Class)clazz error:(Class)error {
	if ([clazz conformsToProtocol:@protocol(KBEntity)]) {
		_expected = clazz;
	}
	if ([error conformsToProtocol:@protocol(KBEntity)]) {
		_error = error;
	}
	[self start];
}

- (void) start {
	KBAPISUPPORT_F_START
	
	if (!_expected) {
		Class expected = [_request.class expected];
		if ([expected conformsToProtocol:@protocol (KBEntity)]) {
			_expected = expected;
		}
	}
	if (!_error) {
		Class error = [_request.class error];
		if ([error conformsToProtocol:@protocol (KBEntity)]) {
			_error = error;
		}
	}
	
	KBAPISUPPORT_LOG (@"request: %@", _request.URL);
	
	[KBNetworkIndicator requestStarted];
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_request.URL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.timeout];
	req.HTTPMethod = [[self class] methodName:_request.requestMethod];
	if (_request.bodyStreamed) {
		req.HTTPBodyStream = _request.bodyStream;
	} else {
		req.HTTPBody = _request.bodyData;
	}
	NSDictionary *addnHeaders = _request.additionalHeaders;
	for (NSString *header in addnHeaders) {
		[req setValue:[addnHeaders objectForKey:header] forHTTPHeaderField:header];
	}
	
	_connection = [NSURLConnection connectionWithRequest:req delegate:self];
	
	KBAPISUPPORT_F_END
}

#if KBAPISUPPORT_USE_BLOCKS
- (void) startForClass:(Class)clazz error:(Class)error completion: (KBAPICompletionBlock) completion rawObjectCompletion: (KBAPIRawObjectCompletionBlock) rawObjectCompletion rawDataCompletion: (KBAPIRawDataCompletionBlock) rawDataCompletion {
	self.completionBlock = completion;
	self.rawObjectCompletionBlock = rawObjectCompletion;
	self.rawDataCompletionBlock = rawDataCompletion;
	[self startForClass:clazz error:error];
}

- (void) startWithCompletion: (KBAPICompletionBlock) completion {
	[self startForClass:nil error:nil completion:completion rawObjectCompletion:NULL rawDataCompletion:NULL];
}

- (void) startForClass: (Class) clazz withCompletion: (KBAPICompletionBlock) completion {
	[self startForClass:clazz error:nil completion:completion rawObjectCompletion:NULL rawDataCompletion:NULL];
}

- (void) startForClass: (Class) clazz error: (Class) error withCompletion: (KBAPICompletionBlock) completion {
	[self startForClass:clazz error:error completion:completion rawObjectCompletion:NULL rawDataCompletion:NULL];
}

- (void) startWithRawObjectCompletion: (KBAPIRawObjectCompletionBlock) completion {
	[self startForClass:nil error:nil completion:NULL rawObjectCompletion:completion rawDataCompletion:NULL];
}

- (void) startForClass: (Class) clazz withRawObjectCompletion: (KBAPIRawObjectCompletionBlock) completion {
	[self startForClass:clazz error:nil completion:NULL rawObjectCompletion:completion rawDataCompletion:NULL];
}

- (void) startForClass: (Class) clazz error: (Class) error withRawObjectCompletion: (KBAPIRawObjectCompletionBlock) completion {
	[self startForClass:clazz error:error completion:NULL rawObjectCompletion:completion rawDataCompletion:NULL];
}

- (void) startWithRawDataCompletion: (KBAPIRawDataCompletionBlock) completion {
	[self startForClass:nil error:nil completion:NULL rawObjectCompletion:NULL rawDataCompletion:completion];
}

- (void) startForClass: (Class) clazz withRawDataCompletion: (KBAPIRawDataCompletionBlock) completion {
	[self startForClass:clazz error:nil completion:NULL rawObjectCompletion:NULL rawDataCompletion:completion];
}

- (void) startForClass: (Class) clazz error: (Class) error withRawDataCompletion: (KBAPIRawDataCompletionBlock) completion {
	[self startForClass:clazz error:error completion:NULL rawObjectCompletion:NULL rawDataCompletion:completion];
}
#endif

- (void) cancel {
	[_connection cancel];
	_connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	_buffer.length = 0;
	KBAPISUPPORT_LOG (@"HTTP code: %zd", ((NSHTTPURLResponse *) response).statusCode);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_buffer appendData:data];
	KBAPISUPPORT_LOG (@"Received %zd bytes", data.length);
}

- (void) notifyAboutError: (NSError *) error {
	dispatch_sync (dispatch_get_main_queue (), ^{
#if KBAPISUPPORT_USE_DELEGATES
		[self.delegate apiConnection:self didFailWithError:error];
#endif
		
#if KBAPISUPPORT_USE_BLOCKS
		if (self.completionBlock) {
			self.completionBlock (nil, error);
		}
		
		if (self.rawObjectCompletionBlock) {
#if KBAPISUPPORT_BOTH_FORMATS
			self.rawObjectCompletionBlock (nil, nil, error);
#else
			self.rawObjectCompletionBlock (nil, error);
#endif
		}
		
		if (self.rawDataCompletionBlock) {
			self.rawDataCompletionBlock (nil, error);
		}
#endif
	});
}

- (BOOL) notifyAboutResponseObject: (id <KBEntity>) responseObject {
	__block BOOL result = NO;
	dispatch_sync (dispatch_get_main_queue (), ^{
#if KBAPISUPPORT_USE_DELEGATES
		if ([self.delegate respondsToSelector:@selector(apiConnection:didReceiveResponse:)]) {
			[self.delegate apiConnection:self didReceiveResponse:responseObject];
			result = YES;
		}
#endif
		
#if KBAPISUPPORT_USE_BLOCKS
		if (self.completionBlock) {
			self.completionBlock (responseObject, nil);
			result = YES;
		}
#endif
	});
	
	return result;
}

#if KBAPISUPPORT_BOTH_FORMATS
- (BOOL) notifyAboutRawObject: (id) JSONResponse :(GDataXMLDocument *) XMLResponse {
#elif KBAPISUPPORT_JSON
- (BOOL) notifyAboutRawObject: (id) JSONResponse {
#elif KBAPISUPPORT_XML
- (BOOL) notifyAboutRawObject: (GDataXMLDocument *) XMLResponse {
#else
#	error WUUUUUUUUT?
#endif
	__block BOOL result = NO;
	dispatch_sync (dispatch_get_main_queue (), ^{
#if KBAPISUPPORT_USE_DELEGATES
#	if KBAPISUPPORT_JSON
		if (JSONResponse && [self.delegate respondsToSelector:@selector (apiConnection:didReceiveJSON:)]) {
			[self.delegate apiConnection:self didReceiveJSON:JSONResponse];
			result = YES;
		}
#	endif
#	if KBAPISUPPORT_XML
		if (XMLResponse && [self.delegate respondsToSelector:@selector (apiConnection:didReceiveXML:)]) {
			[self.delegate apiConnection:self didReceiveXML:XMLResponse];
			result = YES;
		}
#	endif
#endif
		
#if KBAPISUPPORT_USE_BLOCKS
		if (self.rawObjectCompletionBlock) {
#	if KBAPISUPPORT_BOTH_FORMATS
			self.rawObjectCompletionBlock (JSONResponse, XMLResponse, nil);
#	elif KBAPISUPPORT_JSON
			self.rawObjectCompletionBlock (JSONResponse, nil);
#	elif KBAPISUPPORT_XML
			self.rawObjectCompletionBlock (XMLResponse, nil);
#	else
#		error =(
#	endif
			result = YES;
		}
#endif
	});
	
	return result;
}
	
- (BOOL) notifyAboutRawData: (NSData *) data {
	__block BOOL result = NO;
	dispatch_sync (dispatch_get_main_queue (), ^{
#if KBAPISUPPORT_USE_DELEGATES
		if ([self.delegate respondsToSelector:@selector(apiConnection:didReceiveData:)]) {
			[self.delegate apiConnection:self didReceiveData:_buffer];
			result = YES;
		}
#endif
#if KBAPISUPPORT_USE_BLOCKS
		if (self.rawDataCompletionBlock) {
			self.rawDataCompletionBlock (_buffer, nil);
			result = YES;
		}
#endif
	});
	
	return result;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	_connection = nil;
	[KBNetworkIndicator requestFinished];
	KBAPISUPPORT_LOG (@"error: %@", error);
	dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self notifyAboutError:error];
	});
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	KBAPISUPPORT_F_START
	_connection = nil;
	
	KBAPISUPPORT_LOG (@"Request OK");
	[KBNetworkIndicator requestFinished];
	
	dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#define PREPARED_JSON (_buffer) //// >1 ////
#if (defined (DEBUG) && KBAPISUPPORT_DEBUG) || KBAPISUPPORT_DECODE
		char *bytes = malloc (_buffer.length + 1);
		memcpy (bytes, _buffer.bytes, _buffer.length);
		bytes [_buffer.length] = 0;
#	if KBAPISUPPORT_DECODE
		NSString *decodedString = [NSString stringWithCString:bytes encoding:KBAPISUPPORT_DECODE_FROM];
		KBAPISUPPORT_LOG (@"response: %@", decodedString);
			// maybe there is some method like -(NSData *)dataWithData:(NSData *) fromEncoding:(NSStringEncoding)from toEncoding:(NSStringEncoding)to ?
#		if KBAPISUPPORT_JSON
		unichar *decodedBytes = malloc (decodedString.length * sizeof (unichar));
		[decodedString getCharacters:decodedBytes range: NSMakeRange (0, decodedString.length)];
		NSData *decodedData = [NSData dataWithBytesNoCopy:decodedBytes length:(decodedString.length * sizeof (unichar)) freeWhenDone:YES];
		decodedBytes = NULL;
#			undef PREPARED_JSON
#			define PREPARED_JSON (decodedData) //// >1 ////
#		endif // KBAPISUPPORT_JSON
#	else // KBAPISUPPORT_DECODE
		KBAPISUPPORT_LOG (@"response: %@", [[NSString alloc] initWithUTF8String:bytes]);
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
			JSONResponse = [NSJSONSerialization JSONObjectWithData:PREPARED_JSON options:NSJSONReadingAllowFragments error:&JSONError];
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
			XMLResponse = [[GDataXMLDocument alloc] initWithXMLString:decodedString error:&XMLError];
#	else
			XMLResponse = [[GDataXMLDocument alloc] initWithData:_buffer error:&XMLError];
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
#if KBAPISUPPORT_USE_DELEGATES
#	if KBAPISUPPORT_USE_BLOCKS
		   (
#	endif
		   	![self.delegate respondsToSelector:@selector(apiConnection:didReceiveData:)]
#endif
#if KBAPISUPPORT_USE_DELEGATES && KBAPISUPPORT_USE_BLOCKS
		   	||
#endif
#if KBAPISUPPORT_USE_BLOCKS
		   	!self.rawDataCompletionBlock
#	if KBAPISUPPORT_USE_DELEGATES
		   )
#	endif
#endif
#if !(KBAPISUPPORT_USE_DELEGATES || KBAPISUPPORT_USE_BLOCKS)
#	error Error is coming!
				NO
#endif
		) {
							
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
			[self notifyAboutError:REPORTED_ERROR];
							
#undef REPORTED_ERROR //// <2 ////
							
			KBAPISUPPORT_F_END
			return;
		}
		
		BOOL notified = NO;
		if (_expected) {
			if (
#if KBAPISUPPORT_USE_DELEGATES
				[self.delegate respondsToSelector:@selector(apiConnection:didReceiveResponse:)]
#endif
#if KBAPISUPPORT_USE_BLOCKS && KBAPISUPPORT_USE_DELEGATES
				||
#endif
#if KBAPISUPPORT_USE_BLOCKS
				self.completionBlock
#endif
#if !(KBAPISUPPORT_USE_DELEGATES || KBAPISUPPORT_USE_BLOCKS)
#	error Y U NO WRITE GOOD CFG?
					NO
#endif
				) {
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
					notified = [self notifyAboutResponseObject:responseObject];
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
						[self notifyAboutError:error];
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
						[self notifyAboutError:genericError];
					}
					notified = YES;
				}
			}
		}

		if (!notified) {
			if (
#if KBAPISUPPORT_JSON
					JSONResponse
#endif
#if KBAPISUPPORT_BOTH_FORMATS
					||
#endif
#if KBAPISUPPORT_XML
					XMLResponse
#endif
				) {
#if KBAPISUPPORT_BOTH_FORMATS
				notified = [self notifyAboutRawObject:JSONResponse :XMLResponse];
#elif KBAPISUPPORT_JSON
				notified = [self notifyAboutRawObject:JSONResponse];
#elif KBAPISUPPORT_XML
				notified = [self notifyAboutRawObject:XMLResponse];
#else
#	error Damn
#endif
			}
		}

		if (!notified) {
			notified = [self notifyAboutRawData:_buffer];
		}
		
		if (!notified) {
			NSError *error = [NSError errorWithDomain:@"KBAPIConnection" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"The delegate receives only error messages, so here's one."}];
			KBAPISUPPORT_LOG (@"error: %@", error);
			[self notifyAboutError:error];
		}

#if KBAPISUPPORT_XML
		KB_RELEASE (XMLResponse);
#endif
		_buffer.length = 0;
				
		KBAPISUPPORT_F_END
	});
}

@end
