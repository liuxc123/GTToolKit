//
//  ThirdPartyNaviManager.h
//  GTNavigationTest
//
//  Created by zhi'qiang 冯 on 2018/12/6.
//  Copyright © 2018 zhi'qiang 冯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapNaviKit/AMapNaviKit.h>

@interface ThirdPartyNaviManager : NSObject

+(instancetype)sharedManager;


//要想导航或者跳转第三方导航，请调用这个方法

/**
 要想导航或者跳转第三方导航，请调用这个方法 支持 高德 百度 苹果 腾讯 地图 内置地图默认驾车模式

 @param startLocation 起点
 @param endLocation 终点
 @param stationName 目的地名称可以为空
 */
-(void)createOptionMenuStartLocation:(AMapNaviPoint *)startLocation EndLocation:(AMapNaviPoint* )endLocation stationName:(NSString *) stationName;
@end
