//
//  GTPermissionContacts.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTPermissionContacts : NSObject

+ (BOOL)authorized;

/**
 access authorizationStatus
 
 @return ABAuthorizationStatus(prior to iOS 9) or CNAuthorizationStatus(after iOS 9)
 */
+ (NSInteger)authorizationStatus;

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion;

@end

NS_ASSUME_NONNULL_END
