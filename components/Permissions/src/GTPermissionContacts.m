//
//  GTPermissionContacts.m
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import "GTPermissionContacts.h"
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@implementation GTPermissionContacts

+ (BOOL)authorized
{
    if (@available(iOS 9,*)) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        return status ==  CNAuthorizationStatusAuthorized;
    }
    else
    {
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        return status == kABAuthorizationStatusAuthorized;
    }
}

/**
 access authorizationStatus
 
 @return ABAuthorizationStatus:prior to iOS 9 or CNAuthorizationStatus after iOS 9
 */
+ (NSInteger)authorizationStatus
{
    NSInteger status;
    if (@available(iOS 9,*)) {
        status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    }
    else{
        status = ABAddressBookGetAuthorizationStatus();
    }
    return status;
}

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion
{
    if (@available(iOS 9,*))
    {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        switch (status)
        {
            case CNAuthorizationStatusAuthorized:
            {
                if (completion) {
                    completion(YES,NO);
                }
            }
                break;
            case CNAuthorizationStatusDenied:
            case CNAuthorizationStatusRestricted:
            {
                if (completion) {
                    completion(NO,NO);
                }
            }
                break;
            case CNAuthorizationStatusNotDetermined:
            {
                [[CNContactStore new] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (completion) {
                            completion(granted,YES);
                        }
                    });
                }];
                
            }
                break;
        }
    }
    else
    {
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        
        switch (status) {
            case kABAuthorizationStatusAuthorized: {
                if (completion) {
                    completion(YES,NO);
                }
            } break;
            case kABAuthorizationStatusNotDetermined: {
                ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
                ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(granted,YES);
                        });
                    }
                });
            } break;
            case kABAuthorizationStatusRestricted:
            case kABAuthorizationStatusDenied: {
                if (completion) {
                    completion(NO,NO);
                }
            } break;
        }
    }
}

@end
