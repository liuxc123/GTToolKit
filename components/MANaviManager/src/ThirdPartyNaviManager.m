//
//  ThirdPartyNaviManager.m
//  GTNavigationTest
//
//  Created by zhi'qiang 冯 on 2018/12/6.
//  Copyright © 2018 zhi'qiang 冯. All rights reserved.
//

#import "ThirdPartyNaviManager.h"
#import "MANaviManager.h"
#import "MANaviViewController.h"
#import <MapKit/MapKit.h>
@interface ThirdPartyNaviManager()

@end

@implementation ThirdPartyNaviManager

+(instancetype)sharedManager{
    static ThirdPartyNaviManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //初始化单例对象
        manager = [[ThirdPartyNaviManager alloc]init];
    });
    return manager;
}

-(void)createOptionMenuStartLocation:(AMapNaviPoint *)startLocation EndLocation:(AMapNaviPoint* )endLocation stationName:(NSString *)stationName{
    if (!endLocation) {
        return;
    }

    UIApplication * applocation = [UIApplication sharedApplication];
    UIAlertController * optionMenu = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    //内置地图
    if (startLocation) {
        UIAlertAction * builtAction = [UIAlertAction actionWithTitle:@"内置导航" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [MANaviManager.sharedManager startDriverNaviStartLocation:startLocation endLocation:endLocation wayLocations:nil calcuateSuccessBlock:^{

            }];
        }];
        [optionMenu addAction:builtAction];
    }

    //苹果地图
    UIAlertAction * iphoneAction = [UIAlertAction actionWithTitle:@"苹果地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CLLocationCoordinate2D end = CLLocationCoordinate2DMake(endLocation.latitude, endLocation.longitude);
        MKMapItem * currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKPlacemark * placeMark = [[MKPlacemark alloc]initWithCoordinate:end addressDictionary:nil];
        MKMapItem * toLaction = [[MKMapItem alloc]initWithPlacemark: placeMark];
        toLaction.name = stationName;
        [MKMapItem openMapsWithItems:@[currentLocation, toLaction] launchOptions:@{
                                                                                   MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                                                                   MKLaunchOptionsShowsTrafficKey:[NSNumber numberWithBool:YES]
        }];
        
    }];
    [optionMenu addAction:iphoneAction];
    
    //百度地图
    if ([applocation canOpenURL:[NSURL URLWithString:@"baidumap://"]]){
        UIAlertAction * baiduAction = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name:%@&mode=walking&coord_type=gcj02",endLocation.latitude,endLocation.longitude,stationName] stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
            [applocation openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
        }];
        [optionMenu addAction:baiduAction];
    }
    
    //高德地图
    if([applocation canOpenURL:[NSURL URLWithString:@"iosamap://"]]){
        UIAlertAction * gaodeAction = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=app名&backScheme=iosamap://&lat=%f&lon=%f&dev=0&style=2",endLocation.latitude,endLocation.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [applocation openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
        }];
        [optionMenu addAction:gaodeAction];
    }
    
    //腾讯地图
    if ([applocation canOpenURL:[NSURL URLWithString:@"qqmap://"]]){
        UIAlertAction * qqAction = [UIAlertAction actionWithTitle:@"腾讯地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?from=我的位置&type=drive&tocoord=%f,%f&to=%@&coord_type=1&policy=0",endLocation.latitude,endLocation.longitude,stationName] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [applocation openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
        }];
        [optionMenu addAction:qqAction];
    }
    
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        return ;
    }];
    [optionMenu addAction:cancelAction];
    
    [[MANaviViewController getCurrentUIVC] presentViewController:optionMenu animated:YES completion:nil];
    
}

@end
