//
//  KBJSONParsingOperation.h
//  KBAPISupport
//
//  Created by Kirill byss Bystrov on 3/17/16.
//  Copyright © 2016 Kirill byss Bystrov. All rights reserved.
//

#import <KBAPISupport/KBOperation.h>

@interface KBJSONParsingOperation: KBOperation

@property (nonatomic, copy, nullable) NSData *JSONData;
@property (nonatomic, copy, nullable) void (^operationCompletionBlock) (id _Nullable parsedObject, NSError *_Nullable error);

@end
