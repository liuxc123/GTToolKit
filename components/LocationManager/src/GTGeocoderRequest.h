//
//  GTGeocoderRequest.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/4.
//

#import "GTLocationRequestDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface GTGeocoderRequest : NSObject

/** 逆地理编码请求的请求ID(在初始化期间设置)。 */
@property (nonatomic, readonly) GTHeadingRequestID requestID;

/** 逆地理编码请求对象 */
@property (nonatomic, readonly) CLGeocoder *geocoder;

/** 这是一个逆地理编码请求完成执行的回调 */
@property (nonatomic, copy, nullable) GTGeocoderRequestBlock block;

@end

NS_ASSUME_NONNULL_END
