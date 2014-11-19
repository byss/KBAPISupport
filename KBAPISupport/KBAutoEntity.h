//
//  KBAutoEntity.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 06.12.12.
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

#import <Foundation/Foundation.h>

#import "KBAPISupport-config.h"

#if KBAPISUPPORT_XML
@class GDataXMLElement;
#endif

#import "KBEntity.h"
#import "KBAutoField.h"

/** This class is used for autoconstructing reponse objects by their fields
  * descriptions.
  */
@interface KBAutoEntity: NSObject <KBEntity>

/** This method returns a list of autoconstructed fields for this entity class.
  * Normally you don't need to override this method, see +initializeAutoFields
  * instead.
  * 
  * @return Array of id &lt; KBAutoField &gt;.
  */
+ (NSArray *) autoFields;

/** This method is called exactly once to initialize the list of autoconstructed
  * fields for this entity class. You should override this method in your entity
  * subclass to enable automatic XML/JSON mapping.
  *
  * @return Array of id &lt; KBAutoField &gt;.
  */
+ (NSArray *) initializeAutoFields;

/** This method is used to create uninitialized, empty instance of the entity class.
  * Default implementation uses simply result of [self new], but if you are using, e.g.
  * Core Data, you may want to override this method to create managed objects in context.
  * Note that this method is not automatically set via +setupAutoEntityMethodsForObjectClass:
  * so you need to write your own even for default implementation if your entity is not
  * a subclass of KBAutoEntity.
  *
  * @return Newly-created instance of entity class.
  */
+ (instancetype) createEntity;

+ (void) setupAutoEntityMethodsForObjectClass: (Class) objectClass;

@end

#define KBAUTOENTITY_EXTENSION(_Class) \
@interface _Class () <KBEntity> \
+ (NSArray *) autoFields; \
+ (NSArray *) initializeAutoFields; \
@end
