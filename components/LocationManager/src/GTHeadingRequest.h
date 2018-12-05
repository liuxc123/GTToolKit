//
//  GTHeadingRequest.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/3.
//

#import "GTLocationRequestDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface GTHeadingRequest : NSObject

/** 此heading朝向请求的请求ID(在初始化期间设置)。 */
@property (nonatomic, readonly) GTHeadingRequestID requestID;
/** 这是否是一个重复的heading朝向请求(目前假定所有标题请求都是)。 */
@property (nonatomic, readonly) BOOL isRecurring;
/** 这是一个heading朝向请求完成执行的回调 */
@property (nonatomic, copy, nullable) GTHeadingRequestBlock block;

@end

NS_ASSUME_NONNULL_END
