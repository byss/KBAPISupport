//
//  KBArray_Protected.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/10/17.
//  Copyright © 2017 Kirill byss Bystrov. All rights reserved.
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

#import <KBAPISupport/KBArray.h>

NS_ASSUME_NONNULL_BEGIN

@interface KBArrayBase ()

+ (instancetype) kb_unsealedArrayWithCapacity: (NSUInteger) capacity;

- (NSUInteger) kb_capacity;
- (void) kb_addObject: (id _Nullable) object;
- (void) kb_addObjects: (__unsafe_unretained id const _Nonnull [_Nullable]) objects count: (NSUInteger) count;

- (void) kb_sealArray;

@end

@interface KBArray ()

@property (nonatomic, readonly, class, getter = kb_isMutable) BOOL kb_mutable;
@property (nonatomic, readonly, nullable) Class kb_classForMutableCopying;
@property (nonatomic, readonly, nullable) Class kb_classForImmutableCopying;

- (instancetype) initWithCapacity: (NSUInteger) capacity NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
