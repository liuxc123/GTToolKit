//
//  GTNaviManager.m
//  GTNavigationTest
//
//  Created by zhi'qiang 冯 on 2018/12/4.
//  Copyright © 2018 zhi'qiang 冯. All rights reserved.
//

#import "MANaviManager.h"

@interface MANaviManager()

//导航页面
@property (nonatomic,strong) MANaviViewController * maNaviController;
//地图页面
@property (nonatomic,strong) MAMapView *mapView;
//导航信息
@property (nonatomic,strong) AMapNaviInfo * naviInfo;
//剩余距离
@property (nonatomic,assign) double  routeRemainDistance;
//剩余时间
@property (nonatomic,assign) double  routeRemainTime;
//导航管理类
@property (nonatomic,strong) AMapNaviDriveManager * naviManager;

@end

@implementation MANaviManager

#pragma Mark - 单例
+(instancetype)sharedManager{
    static MANaviManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //初始化单例对象
        manager = [[MANaviManager alloc]init];
    });
    return manager;
}
-(void)initNavi{
    if (self.naviManager == nil) {
        self.naviManager = [AMapNaviDriveManager sharedInstance];
        self.naviManager.delegate = self;
    }
}

@end
