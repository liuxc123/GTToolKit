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

#import "MANaviViewController.h"
@interface MANaviManager : NSObject
//管理类单例
+(instancetype)sharedManager;

-(void)initNavi;


@end
