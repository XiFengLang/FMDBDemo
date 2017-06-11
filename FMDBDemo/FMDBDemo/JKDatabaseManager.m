//
//  JKDatabaseManager.m
//  FMDBDemo
//
//  Created by 蒋鹏 on 2017/6/10.
//  Copyright © 2017年 溪枫狼. All rights reserved.
//

#import "JKDatabaseManager.h"
#import "FMDB.h"
#import "NSString+JsonObject.h"

@interface JKDatabaseManager ()

@property (nonatomic, strong) FMDatabaseQueue * databaseQueue;
@property (nonatomic, strong) dispatch_queue_t querySerialQueue;
@property (nonatomic, strong) dispatch_queue_t updateSerialQueue;
@end

@implementation JKDatabaseManager
static NSString * const kDatabaseName = @"jk_demo_db";
static NSString * const kDatabaseTableName = @"jk_demo_table";

/// 习惯用一个单例管一个数据库
+ (instancetype)shared {
    static JKDatabaseManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JKDatabaseManager alloc] init];
    });
    return manager;
}

- (NSString *)pathWithDatabaseName:(NSString *)databaseName {
    NSString * databasePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    /// 也可以用UID关联文件夹区分不同用户的数据库
    return [databasePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",databaseName]];
}


- (void)initializeDatabase {
    /// 这里只有一张表，整一个串行队列负责查询就行，多表可以用多个队列管理
    _querySerialQueue = dispatch_queue_create("jk_database_query_queue", DISPATCH_QUEUE_SERIAL);
    _updateSerialQueue = dispatch_queue_create("jk_database_update_queue", DISPATCH_QUEUE_SERIAL);
    
    _databaseQueue = [[FMDatabaseQueue alloc] initWithPath:[self pathWithDatabaseName:kDatabaseName]];
    
    
    [self createDatabaseTable];
}

/// 建表
- (void)createDatabaseTable {
    dispatch_async(self.updateSerialQueue, ^{
        [self.databaseQueue inDatabase:^(FMDatabase *database) {
            /// 本人才疏学浅，大脑对大写的英文识别效率低，所以习惯用小写，写法规范不规范就不管了
            NSString * updateStr = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement, url text, paramters text, timing datetime, content text)",kDatabaseTableName];
            
            /// 这里用数组，创建多张表的时候能省些代码
            NSArray <NSString *>* sqlStr = @[updateStr];
            [sqlStr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![database executeUpdate:obj]) {
                    NSLog(@"JK Database Manager 建表失败:%@ ",obj);
                }
            }];
        }];
    });
}


/// 关闭数据库并且释放队列
- (void)closeDatabase {
    [self.databaseQueue close];
    self.databaseQueue = nil;
    self.querySerialQueue = nil;
}


- (void)insertIntoTableWithUrl:(NSString *)url paramters:(NSDictionary *)paramters timing:(NSString *)timing content:(NSDictionary *)content completionHandler:(void (^)(BOOL))completionHandler{
    
    /// 暂时没找到直接存NSDictionary或者NSData对象的合适姿势，只能转换成字符串存储
    NSString * paramterStr = [NSString jsonStringWithObject:paramters];
    NSString * contentStr = [NSString jsonStringWithObject:content];
    
    dispatch_async(self.updateSerialQueue, ^{
        [self.databaseQueue inDatabase:^(FMDatabase *database) {
            NSLog(@"Insert: %@",[NSThread currentThread]);
            NSString * updateStr = [NSString stringWithFormat:@"insert into %@ (url, paramters, timing, content) values ('%@','%@','%@','%@')",kDatabaseTableName, url, paramterStr, timing, contentStr];
            if (![database executeUpdate:updateStr]) {
                NSLog(@"JK Database Manager 插入数据失败:%@ ",updateStr);
                if (completionHandler) completionHandler(false);
            } else {
                if (completionHandler) completionHandler(true);
            }
        }];
    });
}

- (void)queryTheRequestRecordForToday:(JKDatabaseQueryCompletionHandler)completionHandler {
    NSString * query = [NSString stringWithFormat:@"select * from %@ where datetime(timing) >= datetime('now','start of day') and datetime(timing) < datetime('now','start of day', '+1 day')",kDatabaseTableName];
    [self queryTheRequestRecord:query completionHandler:completionHandler];
    
    
    /// 或者这样
    //    [self queryTheRequestRecordForAGivenDay:[jk_database_dateFormatter() stringFromDate:[NSDate date]] completionHandler:completionHandler];
}


- (void)queryTheRequestRecordForAGivenDay:(NSString *)day completionHandler:(JKDatabaseQueryCompletionHandler)completionHandler {
    /// 00:00-23:59
    NSString * query = [NSString stringWithFormat:@"select * from %@ where datetime(timing) >= datetime('%@','start of day') and datetime(timing) < datetime('%@','start of day', '+1 day')",kDatabaseTableName, day, day];
    [self queryTheRequestRecord:query completionHandler:completionHandler];
}


- (void)queryTheRequestRecord:(NSString *)query completionHandler:(JKDatabaseQueryCompletionHandler)completionHandler {
    
    dispatch_async(self.querySerialQueue, ^{
        [self.databaseQueue inDatabase:^(FMDatabase *database) {
            NSLog(@"Query: %@",[NSThread currentThread]);
            [database setDateFormat:JK_Database_DateFormatter()];
            
            /// 昨天的0时0分0秒 datetime('now','start of day', '-1 day')
            /// 明天的0时0分0秒 datetime('now','start of day', '+1 day')
            /// 今天的0时0分0秒 datetime('now','start of day')
            /// 特定时间 '2017-06-09 00:00:00'
            /// 查询对应的时间 [database stringForQuery:@"select datetime('now','start of day')"]
            /// 还可以这么写 NSLog(@"%@",[database stringForQuery:@"select datetime('2017-06-09 00:00:00','start of day','+1 day')"]);
            
            FMResultSet * resultSet = [database executeQuery:query];
            NSMutableArray <NSDictionary *>* mutArray = [NSMutableArray array];
            while (resultSet.next) {
                NSString * url = [resultSet stringForColumn:@"url"];
                NSDictionary * paramters = [resultSet stringForColumn:@"paramters"].jsonObject ?: @{};
                NSString * timing = [resultSet stringForColumn:@"timing"];
                NSDictionary * content = [resultSet stringForColumn:@"content"].jsonObject ? : @{};
                [mutArray addObject:NSDictionaryOfVariableBindings(url, paramters, timing, content)];
            }
            
            /// 查询完就close resultSet
            //            [resultSet close];
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //            });
            if (completionHandler) completionHandler(mutArray.copy);
        }];
    });
}



- (void)deleteTheRequestRecordWithTiming:(NSString *)timing completionHandler:(void (^)(BOOL))completionHandler {
    dispatch_async(self.updateSerialQueue, ^{
        [self.databaseQueue inDatabase:^(FMDatabase *database) {
            NSLog(@"Delete: %@",[NSThread currentThread]);
            NSString * delete = [NSString stringWithFormat:@"delete from %@ where timing = '%@'",kDatabaseTableName, timing];
            if (![database executeUpdate:delete]) {
                NSLog(@"JK Database Manager 删除数据失败:%@ ",delete);
                
                if (completionHandler) completionHandler(false);
            } else {
                if (completionHandler) completionHandler(true);
            }
        }];
    });
}

@end
