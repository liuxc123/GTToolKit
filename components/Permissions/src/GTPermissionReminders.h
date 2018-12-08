//
//  GTPermissionReminders.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTPermissionReminders : NSObject

+ (BOOL)authorized;

+ (EKAuthorizationStatus)authorizationStatus;

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion;

@end

NS_ASSUME_NONNULL_END
