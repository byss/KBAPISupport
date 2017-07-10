//
//  KBCollection.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/10/17.
//  Copyright © 2017 Kirill byss Bystrov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KBAPISupport/KBObject.h>

@protocol KBCollection <KBObject>

@property (nonatomic, nonnull, readonly, class) Class itemClass;

@end
