//
//  MAMapManager.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/4.
//
#import <Foundation/Foundation.h>
//基础定位类
#import <AMapFoundationKit/AMapFoundationKit.h>
//高德地图基础类
#import <MAMapKit/MAMapKit.h>


/**
 地图管理类 目的用于全局统一的MapView 防止过多的MapView占用太多内存
 MAMapManager 接管了MAMapView所有的生命周期
 */

@protocol MAMapManagerDelegate;

@interface MAMapManager : NSObject

///地图管理类的delegate
@property (nonatomic, weak) id<MAMapManagerDelegate> delegate;

/** 控制器 */
@property (nonatomic,weak) UIViewController *controller;

/** 地图对象 */
@property(nonatomic,strong) MAMapView *mapView;

//当前定位
@property(nonatomic,strong) CLLocation *currentLocation;

//初始化单例管理员对象
+(instancetype)sharedManager;

//配置Mapview样式
-(void)setupMapViewWithBlock:(void(^)(MAMapView *mapview))block;

@end





