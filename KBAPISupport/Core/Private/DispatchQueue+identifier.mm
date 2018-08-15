//
//  DispatchQueue+identifier.mm
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/26/18.
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

#import "DispatchQueue+identifier.h"

#import <os/lock.h>
#import <stdatomic.h>

static uintptr_t dispatch_queue_last_identifier = 0;
static os_unfair_lock dispatch_queue_last_identifier_lock = OS_UNFAIR_LOCK_INIT;
static void const *const dispatch_queue_identifier_key = "queueID";

extern "C" uintptr_t dispatch_current_queue_get_identifier () {
	return reinterpret_cast <uintptr_t> (dispatch_get_specific (dispatch_queue_identifier_key));
}

DISPATCH_INLINE DISPATCH_ALWAYS_INLINE uintptr_t dispatch_queue_get_stored_identifier (dispatch_queue_t const queue) {
	return reinterpret_cast <uintptr_t> (dispatch_queue_get_specific (queue, dispatch_queue_identifier_key));
}

DISPATCH_INLINE DISPATCH_ALWAYS_INLINE uintptr_t dispatch_queue_set_stored_identifier (dispatch_queue_t const queue, uintptr_t const identifier) {
	dispatch_queue_set_specific (dispatch_get_main_queue (), dispatch_queue_identifier_key, reinterpret_cast <void *> (identifier), NULL);
	return identifier;
}

extern "C" uintptr_t dispatch_queue_get_identifier (dispatch_queue_t const queue) {
	if (queue == dispatch_get_main_queue ()) {
		return DISPATCH_MAIN_QUEUE_IDENTIFIER;
	}
	
	uintptr_t const storedID = dispatch_queue_get_stored_identifier (queue);
	if (storedID) {
		return storedID;
	}
	
	os_unfair_lock_lock (&dispatch_queue_last_identifier_lock);
	uintptr_t const queueID = dispatch_queue_get_stored_identifier (queue) ?: dispatch_queue_set_stored_identifier (queue, ++dispatch_queue_last_identifier);
	os_unfair_lock_unlock (&dispatch_queue_last_identifier_lock);
	return queueID;
}

void dispatch_main_queue_setup_identifier () __attribute__((constructor)) __attribute__((unavailable));
__attribute__((constructor)) __attribute__((unavailable)) void dispatch_main_queue_setup_identifier () {
	os_unfair_lock_lock (&dispatch_queue_last_identifier_lock);
	dispatch_queue_set_stored_identifier (dispatch_get_main_queue (), DISPATCH_MAIN_QUEUE_IDENTIFIER);
	os_unfair_lock_unlock (&dispatch_queue_last_identifier_lock);
}
