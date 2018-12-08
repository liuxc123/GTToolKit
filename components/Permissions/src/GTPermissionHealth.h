//
//  GTPermissionHealth.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTPermissionHealth : NSObject

+ (BOOL)authorized;


/*!
 @method        isHealthDataAvailable
 @abstract      Returns YES if HealthKit is supported on the device.
 @discussion    HealthKit is not supported on all iOS devices.  Using HKHealthStore APIs on devices which are not
 supported will result in errors with the HKErrorHealthDataUnavailable code.  Call isHealthDataAvailable
 before attempting to use other parts of the framework.
 */
+ (BOOL)isHealthDataAvailable;

+ (NSInteger)authorizationStatus;

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion;

@end

NS_ASSUME_NONNULL_END
