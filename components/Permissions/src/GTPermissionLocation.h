//
//  GTPermissionLocation.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTPermissionLocation : NSObject

/**
 @return YES if GPS system service enabled,NO if GPS system service is not enabled
 */
+ (BOOL)isServicesEnabled;

+ (BOOL)authorized;

+ (CLAuthorizationStatus)authorizationStatus;

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion;

@end

NS_ASSUME_NONNULL_END
