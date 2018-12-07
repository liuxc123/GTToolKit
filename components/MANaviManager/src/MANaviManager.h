//
//  GTNaviManager.h
//  GTNavigationTest
//
//  Created by zhi'qiang 冯 on 2018/12/4.
//  Copyright © 2018 zhi'qiang 冯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AMapNaviKit/AMapNaviKit.h>
typedef void(^CalcuateSuccessBlock)(void);
@interface MANaviManager : NSObject

//管理类单例
+(instancetype)sharedManager;

//


/**
 步行导航

 @param startLocation 起点
 @param endLocation 终点
 @param calcuateSuccessBlock 成功回调
 */
-(void)startWalkNaviStartLocation:(AMapNaviPoint * )startLocation endLocation:(AMapNaviPoint *  )endLocation calcuateSuccessBlock:(CalcuateSuccessBlock) calcuateSuccessBlock;

//

/**
 驾车导航

 @param startLocation 起点
 @param endLocation 终点
 @param wayLocations 途经点数组
 @param calcuateSuccessBlock 成功回调
 */
-(void)startDriverNaviStartLocation:(AMapNaviPoint *)startLocation endLocation:(AMapNaviPoint *)endLocation wayLocations:(NSArray<AMapNaviPoint*> *)wayLocations calcuateSuccessBlock:(CalcuateSuccessBlock) calcuateSuccessBlock;



@end
