//
//  DispatchQueue+syncSafe.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/26/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

#import <dispatch/dispatch.h>

#if __cplusplus
extern "C" {
#endif
	
DISPATCH_NONNULL_ALL DISPATCH_NOTHROW DISPATCH_REFINED_FOR_SWIFT
void dispatch_sync_safe (dispatch_queue_t queue, DISPATCH_NOESCAPE dispatch_block_t block);

#if __cplusplus
}
#endif

