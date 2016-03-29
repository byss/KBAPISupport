//
//  KBAPISupport.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double const KBAPISupportVersionNumber;
FOUNDATION_EXPORT unsigned char const KBAPISupportVersionString [];

/* Core */
#import <KBAPISupport/KBAPISupport-Core.h>

/* NSURLConnection */
#if __has_include(<KBAPISupport/KBAPISupport+NSURLConnection.h>)
#	import <KBAPISupport/KBAPISupport+NSURLConnection.h>
#endif

/* NSURLSession */
#if __has_include(<KBAPISupport/KBAPISupport+NSURLSession.h>)
#	import <KBAPISupport/KBAPISupport+NSURLSession.h>
#endif

/* JSON */
#if __has_include(<KBAPISupport/KBAPISupport+JSON.h>)
#	import <KBAPISupport/KBAPISupport+JSON.h>
#endif

/* XML */
#if __has_include(<KBAPISupport/KBAPISupport+XML.h>)
#	import <KBAPISupport/KBAPISupport+XML.h>
#endif

/* Mapping */
#if __has_include(<KBAPISupport/KBAPISupport+Mapping.h>)
#	import <KBAPISupport/KBAPISupport+Mapping.h>
#endif

/* Blocks */
#if __has_include(<KBAPISupport/KBAPISupport+Blocks.h>)
#	import <KBAPISupport/KBAPISupport+Blocks.h>
#endif

/* Delegates */
#if __has_include(<KBAPISupport/KBAPISupport+Delegates.h>)
#	import <KBAPISupport/KBAPISupport+Delegates.h>
#endif
