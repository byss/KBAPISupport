//
//  KBAPISupport-debug.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 17.01.13.
//  Copyright (c) 2013 Kirill byss Bystrov. All rights reserved.
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

#import "KBAPISupport-config.h"

///////////////////////// Debug macros /////////////////////////

#ifndef KBAPISUPPORT_LOG
#	if KBAPISUPPORT_DEBUG && defined (DEBUG)
#		define KBAPISUPPORT_LOG(fmt, args...) NSLog (@"%s (%d): " fmt, __PRETTY_FUNCTION__, __LINE__, ##args)
#	else
#		define KBAPISUPPORT_LOG(...)
#	endif
#endif

#ifndef KBAPISUPPORT_F_START
#	define KBAPISUPPORT_F_START KBAPISUPPORT_LOG (@">>>");
#endif

#ifndef KBAPISUPPORT_F_END
#	define KBAPISUPPORT_F_END KBAPISUPPORT_LOG (@"<<<");
#endif

#ifndef KBAPISUPPORT_BUG_HERE
#	define KBAPISUPPORT_BUG_HERE NSLog (@"Execution reached line %d in %s (func %s). Possible bug.", __LINE__, __FILE__, __PRETTY_FUNCTION__);
#endif
