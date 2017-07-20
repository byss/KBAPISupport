//
//  KBURLSessionDelegate.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 6/2/16.
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

#import "KBURLSessionDelegate.h"

#import "KBAPISessionRequestOperation_Protected.h"

@interface KBURLSessionDelegate () <NSURLSessionDataDelegate> {
	NSMapTable <NSURLSessionTask *, KBAPISessionRequestOperation *> *_registeredOperations;
}

@end

@implementation KBURLSessionDelegate

- (instancetype)init {
	if (self = [super init]) {
		_registeredOperations = [[NSMapTable alloc] initWithKeyOptions:(NSPointerFunctionsOptions) (NSPointerFunctionsObjectPointerPersonality | NSPointerFunctionsWeakMemory) valueOptions:(NSPointerFunctionsOptions) (NSPointerFunctionsObjectPointerPersonality | NSPointerFunctionsWeakMemory) capacity:5];
	}
	
	return self;
}

- (void)registerOperation:(KBAPISessionRequestOperation *)operation {
	@synchronized (self) {
		[_registeredOperations setObject:operation forKey:operation.task];
	}
}

- (void)unregisterOperation:(KBAPISessionRequestOperation *)operation {
	@synchronized (self) {
		[_registeredOperations removeObjectForKey:operation.task];
	}
}

- (NSObject *) responderForSelector: (SEL) aSelector {
	if ([self.sessionDelegate respondsToSelector:aSelector]) {
		return self.sessionDelegate;
	}
	
	@synchronized (self) {
		for (NSURLSessionTask *task in _registeredOperations) {
			KBAPISessionRequestOperation *operation = [_registeredOperations objectForKey:task];
			if ([operation respondsToSelector:aSelector]) {
				return operation;
			}
		}
	}
	
	return nil;
}

- (BOOL) respondsToSelector:(SEL)aSelector {
	if ([self responderForSelector:aSelector]) {
		return YES;
	} else {
		return [super respondsToSelector:aSelector];
	}
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	return [[self responderForSelector:aSelector] methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	NSMethodSignature *const methodSignature = anInvocation.methodSignature;
	NSUInteger const argCount = methodSignature.numberOfArguments;
	SEL selector = anInvocation.selector;
	
	if ((argCount > 2) && !strcmp ([methodSignature getArgumentTypeAtIndex:2], @encode (NSURLSession *))) {
		__unsafe_unretained id firstArg;
		[anInvocation getArgument:&firstArg atIndex:2];
		if ([firstArg isKindOfClass:[NSURLSession class]]) { // NSURLSession delegate method
			if ((argCount > 3) && !strcmp ([methodSignature getArgumentTypeAtIndex:3], @encode (NSURLSessionTask *))) {
				__unsafe_unretained id secondArg;
				[anInvocation getArgument:&secondArg atIndex:3];
				if ([secondArg isKindOfClass:[NSURLSessionTask class]]) { // NSURLSessionTask delegate method
					KBAPISessionRequestOperation *operation = [_registeredOperations objectForKey:secondArg];
					if ([operation respondsToSelector:selector]) {
						[anInvocation invokeWithTarget:operation];
						return;
					}
				}
			}
			if ([self.sessionDelegate respondsToSelector:selector]) {
				[anInvocation invokeWithTarget:self.sessionDelegate];
				return;
			}
		}
	}
	
	[super forwardInvocation:anInvocation];
}

@end
