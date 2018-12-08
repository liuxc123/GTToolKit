//
//  GTPermission.m
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import "GTPermission.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

typedef void(^completionPermissionHandler)(BOOL granted,BOOL firstTime);

@implementation GTPermission


+ (BOOL)isServicesEnabledWithType:(GTPermissionType)type
{
    if (type == GTPermissionTypeLocation)
    {
        SEL sel = NSSelectorFromString(@"isServicesEnabled");
        BOOL ret  = ((BOOL *(*)(id,SEL))objc_msgSend)( NSClassFromString(@"GTPermissionLocation"), sel);
        return ret;
    }
    return YES;
}

+ (BOOL)isDeviceSupportedWithType:(GTPermissionType)type
{
    if (type == GTPermissionTypeHealth) {
        
        SEL sel = NSSelectorFromString(@"isHealthDataAvailable");
        BOOL ret  = ((BOOL *(*)(id,SEL))objc_msgSend)( NSClassFromString(@"GTPermissionHealth"), sel);
        return ret;
    }
    return YES;
}

+ (BOOL)authorizedWithType:(GTPermissionType)type
{
    SEL sel = NSSelectorFromString(@"authorized");
    
    NSString *strClass = nil;
    switch (type) {
        case GTPermissionTypeLocation:
            strClass = @"GTPermissionLocation";
            break;
        case GTPermissionTypeCamera:
            strClass = @"GTPermissionCamera";
            break;
        case GTPermissionTypePhotos:
            strClass = @"GTPermissionPhotos";
            break;
        case GTPermissionTypeContacts:
            strClass = @"GTPermissionContacts";
            break;
        case GTPermissionTypeReminders:
            strClass = @"GTPermissionReminders";
            break;
        case GTPermissionTypeCalendar:
            strClass = @"GTPermissionCalendar";
            break;
        case GTPermissionTypeMicrophone:
            strClass = @"GTPermissionMicrophone";
            break;
        case GTPermissionTypeHealth:
            strClass = @"GTPermissionHealth";
            break;
        case GTPermissionTypeDataNetwork:
            break;
        default:
            break;
    }
    
    if (strClass) {
        BOOL ret  = ((BOOL *(*)(id,SEL))objc_msgSend)( NSClassFromString(strClass), sel);
        return ret;
    }
    
    return NO;
}

+ (void)authorizeWithType:(GTPermissionType)type completion:(void(^)(BOOL granted,BOOL firstTime))completion
{
    NSString *strClass = nil;
    switch (type) {
        case GTPermissionTypeLocation:
            strClass = @"GTPermissionLocation";
            break;
        case GTPermissionTypeCamera:
            strClass = @"GTPermissionCamera";
            break;
        case GTPermissionTypePhotos:
            strClass = @"GTPermissionPhotos";
            break;
        case GTPermissionTypeContacts:
            strClass = @"GTPermissionContacts";
            break;
        case GTPermissionTypeReminders:
            strClass = @"GTPermissionReminders";
            break;
        case GTPermissionTypeCalendar:
            strClass = @"GTPermissionCalendar";
            break;
        case GTPermissionTypeMicrophone:
            strClass = @"GTPermissionMicrophone";
            break;
        case GTPermissionTypeHealth:
            strClass = @"GTPermissionHealth";
            break;
        case GTPermissionTypeDataNetwork:
            strClass = @"GTPermissionData";
            break;
            
        default:
            break;
    }
    
    if (strClass)
    {
        SEL sel = NSSelectorFromString(@"authorizeWithCompletion:");
        ((void(*)(id,SEL, completionPermissionHandler))objc_msgSend)(NSClassFromString(strClass),sel, completion);
    }
}

@end
