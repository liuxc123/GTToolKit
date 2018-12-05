//
//  MAMapManager.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/4.
//
#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>

@interface MAMapManager : NSObject

/** 控制器 */
@property (nonatomic,weak)UIViewController *controller;

/** 地图对象 */
@property(nonatomic,strong) MAMapView *mapView;

//初始化单例管理员对象
+(instancetype)sharedManager;

@end
