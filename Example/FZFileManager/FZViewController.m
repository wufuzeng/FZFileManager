//
//  FZViewController.m
//  FZFileManager
//
//  Created by wufuzeng on 07/27/2019.
//  Copyright (c) 2019 wufuzeng. All rights reserved.
//

#import "FZViewController.h"

#import "FZFileManager.h"

@interface FZViewController ()

@end

@implementation FZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	 
    NSString *url = @"https:\/\/mlboos.oss-cn-hangzhou.aliyuncs.com\/CommunityFile%2FUserUpLoadFile%2FVideo%2F20190723092138770-1435_video.mp4";
    
    NSLog(@"%@",[FZFolderOperation library]);
    
    /*
    [[FZFileReceiver sharedReceiver] fileWithUrl:url progress:^(NSUInteger current,NSUInteger total) {
        NSLog(@"%ld,%ld",current,total);
    } result:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"下载数据:%@",data);
        }else{
            NSLog(@"下载失败");
        }
    }];
    */
    
     [[FZFileReceiver sharedReceiver] fileWithUrl:url progress:^(NSUInteger total, NSUInteger current) {
     NSLog(@"%ld,%ld",current,total);
     } result:^(NSData * _Nullable data, NSError * _Nullable error) {
     if (error == nil) {
     NSLog(@"下载数据:%@",data);
     }else{
     NSLog(@"下载失败");
     }
     }];
    
    NSLog(@"%@",[FZFolderOperation caches]);
    
    [FZFolderOperation removePath:[FZFolderOperation caches]];
    
    
}



@end
