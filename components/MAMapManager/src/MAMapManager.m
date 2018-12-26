//
//  MAMapManager.m
//  GTCatalog
//
//  Created by liuxc on 2018/12/4.
//

#import "MAMapManager.h"

@interface MAMapManager () <MAMapViewDelegate>

@end

@implementation MAMapManager

#pragma mark --创建一个单例类对象
+(instancetype)sharedManager{
    static MAMapManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //初始化单例对象
        instance = [[MAMapManager alloc]init];
        instance.mapView.delegate = self;
    });
    return instance;
}

- (MAMapView *)mapView
{
    if (_mapView == nil) {
        _mapView = [[MAMapView alloc] initWithFrame: [UIScreen mainScreen].bounds];
        ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
        _mapView.showsUserLocation = YES;
        _mapView.userTrackingMode = MAUserTrackingModeFollow;
        //设置地图缩放比例，即显示区域
        [_mapView setZoomLevel:15.1 animated:YES];
        //设置定位精度
        _mapView.desiredAccuracy = kCLLocationAccuracyBest;
        //设置定位距离
        _mapView.distanceFilter = 5.0f;
    }

    return _mapView;
}


-(void)setupMapViewWithBlock:(void(^)(MAMapView *mapview))block {
    [_mapView removeAnnotations:self.mapView.annotations];
    [_mapView removeOverlays:self.mapView.overlays];
    if (block) {
        block(self.mapView);
    }
}



@end
