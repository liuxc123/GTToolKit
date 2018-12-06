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


#pragma mark - MAMapManagerDelegate

/**
 MAMapManagerDelegate 接管了所有的 MAMapViewDelegate
 */
@protocol MAMapManagerDelegate <NSObject>

@optional

/**
 * @brief 地图区域改变过程中会调用此接口 since 4.6.0
 * @param mapView 地图View
 */
- (void)mapViewRegionChanged:(MAMapView *)mapView;

/**
 * @brief 地图区域即将改变时会调用此接口
 * @param mapView 地图View
 * @param animated 是否动画
 */
- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated;

/**
 * @brief 地图区域改变完成后会调用此接口
 * @param mapView 地图View
 * @param animated 是否动画
 */
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated;

/**
 * @brief 地图将要发生移动时调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction;

/**
 * @brief 地图移动结束后调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction;

/**
 * @brief 地图将要发生缩放时调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapWillZoomByUser:(BOOL)wasUserAction;

/**
 * @brief 地图缩放结束后调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction;

/**
 * @brief 地图开始加载
 * @param mapView 地图View
 */
- (void)mapViewWillStartLoadingMap:(MAMapView *)mapView;

/**
 * @brief 地图加载成功
 * @param mapView 地图View
 */
- (void)mapViewDidFinishLoadingMap:(MAMapView *)mapView;

/**
 * @brief 地图加载失败
 * @param mapView 地图View
 * @param error 错误信息
 */
- (void)mapViewDidFailLoadingMap:(MAMapView *)mapView withError:(NSError *)error;

/**
 * @brief 根据anntation生成对应的View。

 注意：
 1、5.1.0后由于定位蓝点增加了平滑移动功能，如果在开启定位的情况先添加annotation，需要在此回调方法中判断annotation是否为MAUserLocation，从而返回正确的View。
 if ([annotation isKindOfClass:[MAUserLocation class]]) {
 return nil;
 }

 2、请不要在此回调中对annotation进行select和deselect操作，此时annotationView还未添加到mapview。

 * @param mapView 地图View
 * @param annotation 指定的标注
 * @return 生成的标注View
 */
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation;

/**
 * @brief 当mapView新添加annotation views时，调用此接口
 * @param mapView 地图View
 * @param views 新添加的annotation views
 */
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views;

/**
 * @brief 当选中一个annotation view时，调用此接口. 注意如果已经是选中状态，再次点击不会触发此回调。取消选中需调用-(void)deselectAnnotation:animated:
 * @param mapView 地图View
 * @param view 选中的annotation view
 */
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view;

/**
 * @brief 当取消选中一个annotation view时，调用此接口
 * @param mapView 地图View
 * @param view 取消选中的annotation view
 */
- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view;

/**
 * @brief 在地图View将要启动定位时，会调用此函数
 * @param mapView 地图View
 */
- (void)mapViewWillStartLocatingUser:(MAMapView *)mapView;

/**
 * @brief 在地图View停止定位后，会调用此函数
 * @param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(MAMapView *)mapView;

/**
 * @brief 位置或者设备方向更新后，会调用此函数
 * @param mapView 地图View
 * @param userLocation 用户定位信息(包括位置与设备方向等数据)
 * @param updatingLocation 标示是否是location数据更新, YES:location数据更新 NO:heading数据更新
 */
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation;

/**
 * @brief 定位失败后，会调用此函数
 * @param mapView 地图View
 * @param error 错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error;

/**
 * @brief 拖动annotation view时view的状态变化
 * @param mapView 地图View
 * @param view annotation view
 * @param newState 新状态
 * @param oldState 旧状态
 */
- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState
   fromOldState:(MAAnnotationViewDragState)oldState;

/**
 * @brief 根据overlay生成对应的Renderer
 * @param mapView 地图View
 * @param overlay 指定的overlay
 * @return 生成的覆盖物Renderer
 */
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay;

/**
 * @brief 当mapView新添加overlay renderers时，调用此接口
 * @param mapView 地图View
 * @param overlayRenderers 新添加的overlay renderers
 */
- (void)mapView:(MAMapView *)mapView didAddOverlayRenderers:(NSArray *)overlayRenderers;

/**
 * @brief 标注view的accessory view(必须继承自UIControl)被点击时，触发该回调
 * @param mapView 地图View
 * @param view callout所属的标注view
 * @param control 对应的control
 */
- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;

/**
 * @brief 标注view的calloutview整体点击时，触发该回调。只有使用默认calloutview时才生效。
 * @param mapView 地图的view
 * @param view calloutView所属的annotationView
 */
- (void)mapView:(MAMapView *)mapView didAnnotationViewCalloutTapped:(MAAnnotationView *)view;

/**
 * @brief 标注view被点击时，触发该回调。（since 5.7.0）
 * @param mapView 地图的view
 * @param view annotationView
 */
- (void)mapView:(MAMapView *)mapView didAnnotationViewTapped:(MAAnnotationView *)view;

/**
 * @brief 当userTrackingMode改变时，调用此接口
 * @param mapView 地图View
 * @param mode 改变后的mode
 * @param animated 动画
 */
- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated;

/**
 * @brief 当openGLESDisabled变量改变时，调用此接口
 * @param mapView 地图View
 * @param openGLESDisabled 改变后的openGLESDisabled
 */
- (void)mapView:(MAMapView *)mapView didChangeOpenGLESDisabled:(BOOL)openGLESDisabled;

/**
 * @brief 当touchPOIEnabled == YES时，单击地图使用该回调获取POI信息
 * @param mapView 地图View
 * @param pois 获取到的poi数组(由MATouchPoi组成)
 */
- (void)mapView:(MAMapView *)mapView didTouchPois:(NSArray *)pois;

/**
 * @brief 单击地图回调，返回经纬度
 * @param mapView 地图View
 * @param coordinate 经纬度
 */
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 * @brief 长按地图，返回经纬度
 * @param mapView 地图View
 * @param coordinate 经纬度
 */
- (void)mapView:(MAMapView *)mapView didLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 * @brief 地图初始化完成（在此之后，可以进行坐标计算）
 * @param mapView 地图View
 */
- (void)mapInitComplete:(MAMapView *)mapView;

#if MA_INCLUDE_INDOOR
/**
 * @brief  室内地图出现,返回室内地图信息
 *
 *  @param mapView        地图View
 *  @param indoorInfo     室内地图信息
 */
- (void)mapView:(MAMapView *)mapView didIndoorMapShowed:(MAIndoorInfo *)indoorInfo;

/**
 * @brief  室内地图楼层发生变化,返回变化的楼层
 *
 *  @param mapView        地图View
 *  @param indoorInfo     变化的楼层
 */
- (void)mapView:(MAMapView *)mapView didIndoorMapFloorIndexChanged:(MAIndoorInfo *)indoorInfo;

/**
 * @brief  室内地图消失后,返回室内地图信息
 *
 *  @param mapView        地图View
 *  @param indoorInfo     室内地图信息
 */
- (void)mapView:(MAMapView *)mapView didIndoorMapHidden:(MAIndoorInfo *)indoorInfo;
#endif //end of MA_INCLUDE_INDOOR

/**
 * @brief 离线地图数据将要被加载, 调用reloadMap会触发该回调，离线数据生效前的回调.
 * @param mapView 地图View
 */
- (void)offlineDataWillReload:(MAMapView *)mapView;

/**
 * @brief 离线地图数据加载完成, 调用reloadMap会触发该回调，离线数据生效后的回调.
 * @param mapView 地图View
 */
- (void)offlineDataDidReload:(MAMapView *)mapView;

@end





