//
//  NSString+JsonObject.h
//  FMDBDemo
//
//  Created by 蒋鹏 on 2017/6/11.
//  Copyright © 2017年 溪枫狼. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+JsonObject.h"

@interface NSString (JsonObject)

@property (nonatomic, strong, readonly) id jsonObject;

+ (NSString *)jsonStringWithObject:(id)object;

@end
