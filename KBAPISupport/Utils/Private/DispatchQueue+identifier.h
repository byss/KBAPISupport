//
//  DispatchQueue+identifier.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/26/18.
//

#import <dispatch/dispatch.h>

#if __cplusplus
extern "C" {
#endif
	
#define DISPATCH_QUEUE_IDENTIFIER_INVALID	0
#define DISPATCH_MAIN_QUEUE_IDENTIFIER UINTPTR_MAX

DISPATCH_NONNULL_ALL DISPATCH_NOTHROW DISPATCH_REFINED_FOR_SWIFT
uintptr_t dispatch_current_queue_get_identifier ();
	
DISPATCH_NONNULL_ALL DISPATCH_NOTHROW DISPATCH_REFINED_FOR_SWIFT
uintptr_t dispatch_queue_get_identifier (dispatch_queue_t queue);

#if __cplusplus
}
#endif
