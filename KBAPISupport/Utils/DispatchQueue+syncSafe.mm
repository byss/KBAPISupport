//
//  DispatchQueue+syncSafe.m
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/26/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

#import "DispatchQueue+syncSafe.h"
#import "DispatchQueue+identifier.h"

DISPATCH_NONNULL_ALL DISPATCH_NOTHROW DISPATCH_REFINED_FOR_SWIFT
void dispatch_sync_safe (dispatch_queue_t queue, DISPATCH_NOESCAPE dispatch_block_t block) {
	if (dispatch_queue_get_identifier (queue) == dispatch_current_queue_get_identifier ()) {
		block ();
	} else {
		dispatch_sync (queue, block);
	}
}
