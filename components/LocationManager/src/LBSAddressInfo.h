//
//  LBSAddressInfo.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/4.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 反地理编码地理信息
 */
@interface LBSAddressInfo : NSObject

//经度
@property (nonatomic,assign)  CLLocationDegrees  latitude;
//纬度
@property (nonatomic,assign)  CLLocationDegrees  longitude;
//海拔
@property (nonatomic,assign)  CLLocationDegrees  altitude;

//国家
@property (nonatomic,copy)  NSString * country;
//省分
@property (nonatomic,copy)  NSString * administrativeArea;
//子行政区 county, eg. Santa Clara
@property (nonatomic,copy)  NSString * subAdministrativeArea;
//城市
@property (nonatomic,copy)  NSString * locality;
//县区
@property (nonatomic,copy)  NSString * subLocality;
//街道
@property (nonatomic,copy)  NSString * thoroughfare;
//子街道
@property (nonatomic,copy)  NSString * subThoroughfare;
//名称
@property (nonatomic,copy)  NSString * name;
//邮政编码
@property (nonatomic,copy)  NSString * postalCode;


@end
