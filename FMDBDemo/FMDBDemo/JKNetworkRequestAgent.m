//
//  JKNetworkRequestAgent.m
//  FMDBDemo
//
//  Created by 蒋鹏 on 2017/6/11.
//  Copyright © 2017年 溪枫狼. All rights reserved.
//

#import "JKNetworkRequestAgent.h"
#import "NSData+JsonObject.h"

@implementation JKNetworkRequestAgent

- (void)requestRemoteDataWithCompletionHandler:(void(^)(NSDictionary *, NSString *, NSDictionary *))completionHandler {
    NSString * url = @"http://ipad-bjwb.bjd.com.cn/DigitalPublication/publish/Handler/APINewsList.ashx?date=20131129&startRecord=1&len=5&terminalType=Iphone&udid=1234567890&cid=213";
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || !([(NSHTTPURLResponse *)response statusCode] >= 200 && [(NSHTTPURLResponse *)response statusCode] < 300)) {
            NSLog(@"HTTP Request Failure %@",error ? : response.URL);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) completionHandler(data.jsonObject, url, @{@"udid":@"1234567890",@"cid":@"213"});
            });
        }
    }] resume];
}

@end
