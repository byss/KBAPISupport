//
//  KBAtomicCounter.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/19/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

#import <stdatomic.h>

typedef struct {
	atomic_intptr_t value __attribute__((swift_private));
} KBAtomicCounter __attribute__((swift_private));

 __attribute__((swift_private)) __attribute__((always_inline)) inline void KBAtomicCounterInit (KBAtomicCounter *const counter, size_t const value) {
	atomic_init (&counter->value, value);
}

 __attribute__((swift_private)) __attribute__((always_inline)) inline size_t KBAtomicCounterGetValue (KBAtomicCounter *const counter) {
	return atomic_load (&counter->value);
}

 __attribute__((swift_private)) __attribute__((always_inline)) inline size_t KBAtomicCounterGetNext (KBAtomicCounter *const counter) {
	return atomic_fetch_add (&counter->value, 1);
}
