//
//  GTPermissionPhotos.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTPermissionPhotos : NSObject

+ (BOOL)authorized;

/**
 photo permission status
 
 @return
 0 :NotDetermined
 1 :Restricted
 2 :Denied
 3 :Authorized
 */
+ (NSInteger)authorizationStatus;

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion;

@end

NS_ASSUME_NONNULL_END
