//
//  KBAPISupport.h
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

/* Core */
#import <KBAPISupport/KBAPISupport-Core.h>

/* NSURLConnection */
#if __has_include (<KBAPISupport/KBAPISupport+NSURLConnection.h>)
#	import <KBAPISupport/KBAPISupport+NSURLConnection.h>
#endif

/* NSURLSession */
#if __has_include (<KBAPISupport/KBAPISupport+NSURLSession.h>)
#	import <KBAPISupport/KBAPISupport+NSURLSession.h>
#endif

/* JSON */
#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)
#	import <KBAPISupport/KBAPISupport+JSON.h>
#endif

/* XML */
#if __has_include (<KBAPISupport/KBAPISupport+XML.h>)
#	import <KBAPISupport/KBAPISupport+XML.h>
#endif

/* Core Mapping */
#if __has_include (<KBAPISupport/KBAPISupport+CoreMapping.h>)
#	import <KBAPISupport/KBAPISupport+CoreMapping.h>
#endif

/* Object Mapping */
#if __has_include (<KBAPISupport/KBAPISupport+ObjectMapping.h>)
#	import <KBAPISupport/KBAPISupport+ObjectMapping.h>
#endif

/* Blocks */
#if __has_include (<KBAPISupport/KBAPISupport+Blocks.h>)
#	import <KBAPISupport/KBAPISupport+Blocks.h>
#endif

/* Delegates */
#if __has_include (<KBAPISupport/KBAPISupport+Delegates.h>)
#	import <KBAPISupport/KBAPISupport+Delegates.h>
#endif

/* Network Indicator */
#if __has_include (<KBAPISupport/KBAPISupport+NetworkIndicator.h>)
#	import <KBAPISupport/KBAPISupport+NetworkIndicator.h>
#endif

/* Logging */
#if __has_include (<KBAPISupport/KBAPISupport+Logging.h>)
#	import <KBAPISupport/KBAPISupport+Logging.h>
#endif
