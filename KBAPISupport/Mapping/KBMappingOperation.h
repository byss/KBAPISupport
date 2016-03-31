//
//  KBMappingOperation.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/31/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBOperation.h>

@protocol KBEntity;
@interface KBMappingOperation: KBOperation

@property (nonatomic, nullable, unsafe_unretained) Class expectedClass;
@property (nonatomic, nullable, unsafe_unretained) Class errorClass;
@property (nonatomic, nullable, copy) void (^operationCompletionBlock) (id <KBEntity> _Nullable responseObject, NSError *_Nullable error);

@end
