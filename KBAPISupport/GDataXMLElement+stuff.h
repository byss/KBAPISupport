//
//  GDataXMLElement+stuff.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 28.11.12.
//  Copyright (c) 2012 Kirill byss Bystrov. All rights reserved.
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

#if KBAPISUPPORT_XML
#	import "GDataXMLNode.h"

/** Convinience methods for GDataXMLElement.
  */
@interface GDataXMLElement (stuff)

/** Returns value of child XML element interpreted as string.
  *
  * Finds by name first child element of receiver and represents it as NSString.
  * If child element contains subelements, they will be represented as strings too.
  * For example, if receiver represents XML
  * 	<root>
  * 		<elem>
  * 			<subelem>subelem-value</subelem>
  * 		</elem>
  * 	</root>
  * then childStringValue:@"elem" would return @"<subelem>subelem-value</subelem>".
  *
  * @param childName Name of the requested child element.
  * @return String representation of child content or nil if no child found.
  */
- (NSString *) childStringValue: (NSString *) childName;

/** Returns first child element with specified name.
  *
  * @param childName Name of the requested child element.
  * @return Receiver's first child element with specified name of nil if element is not found.
  */
- (GDataXMLElement *) firstChildWithName: (NSString *) childName;

/** Returns object representation of XML element.
  *
  * @return NSString, NSArray or NSDictionary, depending on the receiver's content.
  */
- (id) objectValue;

@end
#endif
