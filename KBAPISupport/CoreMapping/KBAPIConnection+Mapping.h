//
//  KBAPIConnection+Mapping.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 9/20/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBAPIConnection.h>

@interface KBAPIConnection (Mapping)

@property (nonatomic, nullable, strong, class) id defaultMappingContext;
@property (nonatomic, nullable, strong) id mappingContext;

@end
