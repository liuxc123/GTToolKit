//
//  GTPermissionCamera.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTPermissionCamera : NSObject

+ (BOOL)authorized;

+ (AVAuthorizationStatus)authorizationStatus;

+ (void)authorizeWithCompletion:(void(^)(BOOL granted ,BOOL firstTime ))completion;

@end

NS_ASSUME_NONNULL_END
