//
//  NSData+JsonObject.m
//  FMDBDemo
//
//  Created by 蒋鹏 on 2017/6/11.
//  Copyright © 2017年 溪枫狼. All rights reserved.
//

#import "NSData+JsonObject.h"

@implementation NSData (JsonObject)

- (id)jsonObject {
    if (self != nil && ![self isKindOfClass:[NSNull class]] && self.length > 0) {
        @try {
            NSError * error = nil;
            id obj = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableContainers error:&error];
            if (!error) {
                return obj;
            }
            NSLog(@"JK JSON Serialization Error: %@  \ndata:%@",error, [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding]);
            return nil;
        } @catch (NSException *exception) {
            NSLog(@"JK JSON Serialization Exception: %@  \ndata:%@",exception, [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding]);
            return nil;
        }
    }
    return nil;
}

@end
