//
//  MAMapManager.m
//  GTCatalog
//
//  Created by liuxc on 2018/12/4.
//

#import "MAMapManager.h"

@implementation MAMapManager

#pragma mark --创建一个单例类对象
+(instancetype)sharedManager{
    static MAMapManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //初始化单例对象
        instance = [[MAMapManager alloc]init];
    });
    return instance;
}

@end
