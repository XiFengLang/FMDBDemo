//
//  JKNetworkRequestAgent.h
//  FMDBDemo
//
//  Created by 蒋鹏 on 2017/6/11.
//  Copyright © 2017年 溪枫狼. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKNetworkRequestAgent : NSObject


/**
 请求数据，主线程回调
 
 @param completionHandler completionHandler description
 */
- (void)requestRemoteDataWithCompletionHandler:(void(^)(NSDictionary * responceObject, NSString * url, NSDictionary * paramters))completionHandler;

@end
