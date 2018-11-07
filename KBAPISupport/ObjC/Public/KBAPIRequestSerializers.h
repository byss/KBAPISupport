//
//  KBAPIRequestSerializers.h
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

#import <KBAPISupport/KBAPICoder.h>

NS_ASSUME_NONNULL_BEGIN

NS_REFINED_FOR_SWIFT
@interface KBAPIRequestSerializer: NSObject <KBAPICoder>

- (BOOL) shouldSerializeRequestParametersAsBodyDataForRequest: (KBAPIRequest *) request;
- (nullable NSURLRequest *) serializeRequest: (KBAPIRequest *) request error: (NSError *__autoreleasing *) error;
- (BOOL) serializeParameters: (NSDictionary <NSString *, id> *) parameters asBodyData: (BOOL) asBodyData intoRequest: (NSMutableURLRequest *) request error: (NSError *__autoreleasing *__nullable) error;

@end

NS_REFINED_FOR_SWIFT
@interface KBAPIURLEncodingSerializer: KBAPIRequestSerializer

@end

NS_REFINED_FOR_SWIFT
@interface KBAPIJSONSerializer: KBAPIURLEncodingSerializer

@end

NS_ASSUME_NONNULL_END
