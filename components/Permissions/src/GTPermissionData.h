//
//  GTPermissionData.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///data networks permission
@interface GTPermissionData : NSObject

/**
 判断网络权限是否有限制
 remark: just call back data networks permission
 @param completion 回调
 */
+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion;

@end

NS_ASSUME_NONNULL_END
