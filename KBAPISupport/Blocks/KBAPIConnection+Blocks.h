//
//  KBAPIConnection+Blocks.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
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

#import <KBAPISupport/KBAPIConnection.h>

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
@class GDataXMLDocument;
#endif

#if __has_include (<KBAPISupport/KBAPISupport+Mapping.h>)
@protocol KBEntity;
#endif

@interface KBAPIConnection (Blocks)

- (KBOperation *) startWithRawDataCompletion: (void (^_Nullable) (NSData *_Nullable responseData, NSError *_Nullable error)) completion;

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
- (KBOperation *) startWithRawObjectCompletion: (void (^_Nullable) (id _Nullable JSONResponse, NSError *_Nullable error)) completion;
#endif

#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
- (KBOperation *) startWithRawObjectCompletion: (void (^_Nullable) (GDataXMLDocument *_Nullable XMLResponse, NSError *_Nullable error)) completion;
#endif

#if __has_include (<KBAPISupport/KBAPISupport+Mapping.h>)
- (KBOperation *) startWithCompletion: (void (^_Nonnull) (id <KBEntity> _Nullable responseObject, NSError *_Nullable error)) completion;
#endif

@end
