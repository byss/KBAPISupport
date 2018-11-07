//
//  DispatchQueue+safeSync.mm
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/26/18.
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

#import "DispatchQueue+safeSync.h"
#import "DispatchQueue+identifier.h"

DISPATCH_NONNULL_ALL DISPATCH_NOTHROW DISPATCH_REFINED_FOR_SWIFT
void dispatch_sync_safe (dispatch_queue_t queue, DISPATCH_NOESCAPE dispatch_block_t block) {
	if (dispatch_queue_get_identifier (queue) == dispatch_current_queue_get_identifier ()) {
		block ();
	} else {
		dispatch_sync (queue, block);
	}
}
