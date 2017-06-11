//
//  ViewController.m
//  FMDBDemo
//
//  Created by 蒋鹏 on 2017/6/10.
//  Copyright © 2017年 溪枫狼. All rights reserved.
//

#import "ViewController.h"
#import "JKDatabaseManager.h"
#import "JKNetworkRequestAgent.h"

@interface ViewController ()

@property (nonatomic, strong) JKNetworkRequestAgent * requestAgent;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /// 初始化数据库，建表啥的
    [[JKDatabaseManager shared] initializeDatabase];
    
    self.requestAgent = [[JKNetworkRequestAgent alloc] init];
}



- (IBAction)insertAction:(id)sender {
    [self.requestAgent requestRemoteDataWithCompletionHandler:^(NSDictionary *responceObject, NSString *url, NSDictionary *paramters) {
        
        NSString * date = [JK_Database_DateFormatter() stringFromDate:[NSDate date]];
        [[JKDatabaseManager shared] insertIntoTableWithUrl:url paramters:paramters timing:date content:responceObject completionHandler:^(BOOL finished) {
            NSLog(@"insert: %@",finished ? @"true" : @"false");
        }];
    }];
}
- (IBAction)deleteAction:(id)sender {
    [[JKDatabaseManager shared] queryTheRequestRecordForToday:^(NSArray<NSDictionary *> *historyItmes) {
        NSString * timing = historyItmes.firstObject[@"timing"];
        [[JKDatabaseManager shared] deleteTheRequestRecordWithTiming:timing completionHandler:^(BOOL finished) {
            NSLog(@"delete: %@",finished ? @"true" : @"false");
        }];
    }];
}


- (IBAction)queryTodaysRecord:(id)sender {
    [[JKDatabaseManager shared] queryTheRequestRecordForToday:^(NSArray<NSDictionary *> *historyItmes) {
        NSLog(@"有%zd条数据",historyItmes.count);
    }];
}



- (IBAction)queryTheRequestRecordForAGivenDay:(id)sender {
    NSString * date = [JK_Database_DateFormatter() stringFromDate:[NSDate date]];
    [[JKDatabaseManager shared] queryTheRequestRecordForAGivenDay:date completionHandler:^(NSArray<NSDictionary *> *historyItmes) {
        NSLog(@"有%zd条数据",historyItmes.count);
        [self queryTodaysRecord:nil];
    }];
}

/// 增删查
- (IBAction)onePackageService:(id)sender {
    
    
    [self.requestAgent requestRemoteDataWithCompletionHandler:^(NSDictionary *responceObject, NSString *url, NSDictionary *paramters) {
        NSString * date = [JK_Database_DateFormatter() stringFromDate:[NSDate date]];
        
        [[JKDatabaseManager shared] insertIntoTableWithUrl:url paramters:paramters timing:date content:responceObject completionHandler:^(BOOL finished) {
            NSLog(@"insert: %@",finished ? @"true" : @"false");
            
            [[JKDatabaseManager shared] queryTheRequestRecordForAGivenDay:date completionHandler:^(NSArray<NSDictionary *> *historyItmes) {
                NSLog(@"删除前有%zd条数据",historyItmes.count);
                
                [[JKDatabaseManager shared] deleteTheRequestRecordWithTiming:date completionHandler:^(BOOL finished) {
                    NSLog(@"delete: %@",finished ? @"true" : @"false");
                    
                    [[JKDatabaseManager shared] queryTheRequestRecordForAGivenDay:date completionHandler:^(NSArray<NSDictionary *> *historyItmes) {
                        NSLog(@"删除后有%zd条数据",historyItmes.count);
                    }];
                }];
            }];
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
