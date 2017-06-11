//
//  NSString+JsonObject.m
//  FMDBDemo
//
//  Created by 蒋鹏 on 2017/6/11.
//  Copyright © 2017年 溪枫狼. All rights reserved.
//

#import "NSString+JsonObject.h"

@implementation NSString (JsonObject)

+ (NSString *)jsonStringWithObject:(id)object {
    if (![NSJSONSerialization isValidJSONObject:object]) {
        NSLog(@"[JK JSON Serialization] The object is invalid.%@",object);
        return nil;
    }
    NSError * parseError = nil;
    NSData  * jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&parseError];
    if (parseError) {
        NSLog(@"[JK JSON Serialization] %@",[parseError localizedDescription]);
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (id)jsonObject {
    if([self respondsToSelector:@selector(length)]){
        if (self.length ==0) {
            return nil;
        }
    } else {
        NSLog(@"[JK JSON Serialization] 非NSString类型对象 \n%@",self);
        return nil;
    }
    
    NSString * tempSelf = [NSString stringWithString:self];
    
    // 替换特殊字符
    if ([self containsString:@"\r\n"] && ![self containsString:@"\\r\\n"]) {
        tempSelf = [self stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\\r\\n"];
    } else if ([self containsString:@"\r\r"] && ![self containsString:@"\\r\\r"]){
        tempSelf = [self stringByReplacingOccurrencesOfString:@"\r\r" withString:@"\\r\\r"];
    }
    
    return [self dataUsingEncoding:NSUTF8StringEncoding].jsonObject;
}

@end
