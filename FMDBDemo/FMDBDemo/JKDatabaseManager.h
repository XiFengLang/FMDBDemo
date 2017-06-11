//
//  JKDatabaseManager.h
//  FMDBDemo
//
//  Created by 蒋鹏 on 2017/6/10.
//  Copyright © 2017年 溪枫狼. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSData+JsonObject.h"


/**
 专门用来处理时间
 */
static inline NSDateFormatter * JK_Database_DateFormatter() {
    static NSDateFormatter * dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc]init];
        NSLocale * locale = [[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:locale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    return dateFormatter;
}


typedef void(^JKDatabaseQueryCompletionHandler)(NSArray <NSDictionary *>* historyItmes);


@interface JKDatabaseManager : NSObject

+ (instancetype)shared;


/**
 一些初始化操作，创建串行队列、建表
 */
- (void)initializeDatabase;



/**
 关闭数据库，释放线程队列
 */
- (void)closeDatabase;


/// 增
- (void)insertIntoTableWithUrl:(NSString *)url paramters:(NSDictionary *)paramters timing:(NSString *)timing content:(NSDictionary *)content completionHandler:(void(^)(BOOL finished))completionHandler;


/// 查：今天
- (void)queryTheRequestRecordForToday:(JKDatabaseQueryCompletionHandler)completionHandler;


/// 查：某天
- (void)queryTheRequestRecordForAGivenDay:(NSString *)day completionHandler:(JKDatabaseQueryCompletionHandler)completionHandler;


/// 删改
- (void)deleteTheRequestRecordWithTiming:(NSString *)timing completionHandler:(void(^)(BOOL finished))completionHandler;

@end
