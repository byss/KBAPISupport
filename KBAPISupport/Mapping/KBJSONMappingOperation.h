//
//  KBJSONMappingOperation.h
//  KBAPISupport
//
//  Created by Kirill Bystrov on 3/30/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#if __has_include (<KBAPISupport/KBAPISupport+JSON.h>)

#import <KBAPISupport/KBOperation.h>

@protocol KBEntity;
@interface KBJSONMappingOperation: KBOperation

@property (nonatomic, nullable, strong) id JSONObject;
@property (nonatomic, nullable, unsafe_unretained) Class expectedClass;
@property (nonatomic, nullable, unsafe_unretained) Class errorClass;
@property (nonatomic, nullable, copy) void (^operationCompletionBlock) (id <KBEntity> _Nullable responseObject, NSError *_Nullable error);

@end

#endif
