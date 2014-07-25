//
//  KBArray.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 25/07/14.
//
//

#import "KBEntity.h"

@interface KBArray: NSArray <KBEntity>

+ (Class) entityClass;
#if KBAPISUPPORT_XML
+ (NSString *) entityTag;
#endif

@end
