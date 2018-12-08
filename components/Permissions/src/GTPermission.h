//
//  GTPermission.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import "GTPermissionSetting.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,GTPermissionType)
{
    GTPermissionTypeLocation,
    GTPermissionTypeCamera,
    GTPermissionTypePhotos,
    GTPermissionTypeContacts,
    GTPermissionTypeReminders,
    GTPermissionTypeCalendar,
    GTPermissionTypeMicrophone,
    GTPermissionTypeHealth,
    GTPermissionTypeDataNetwork
};

@interface GTPermission : NSObject

/**
 only effective for location servince,other type reture YES
 
 
 @param type permission type,when type is not location,return YES
 @return YES if system location privacy service enabled NO othersize
 */
+ (BOOL)isServicesEnabledWithType:(GTPermissionType)type;


/**
 whether device support the type
 
 @param type permission type
 @return  YES if device support
 
 */
+ (BOOL)isDeviceSupportedWithType:(GTPermissionType)type;

/**
 whether permission has been obtained, only return status, not request permission
 for example, u can use this method in app setting, show permission status
 in most cases, suggest call "authorizeWithType:completion" method
 
 @param type permission type
 @return YES if Permission has been obtained,NO othersize
 */
+ (BOOL)authorizedWithType:(GTPermissionType)type;


/**
 request permission and return status in main thread by block.
 execute block immediately when permission has been requested,else request permission and waiting for user to choose "Don't allow" or "Allow"
 
 @param type permission type
 @param completion May be called immediately if permission has been requested
 granted: YES if permission has been obtained, firstTime: YES if first time to request permission
 */
+ (void)authorizeWithType:(GTPermissionType)type completion:(void(^)(BOOL granted,BOOL firstTime))completion;

@end

NS_ASSUME_NONNULL_END
