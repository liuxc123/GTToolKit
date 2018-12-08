//
//  GTPermissionData.m
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import "GTPermissionData.h"
#import <CoreTelephony/CTCellularData.h>

@interface GTPermissionData()

@property (nonatomic, strong) id cellularData;
@property (nonatomic, copy) void (^completion)(BOOL granted,BOOL firstTime);
@end

@implementation GTPermissionData

+ (instancetype)sharedManager
{
    static GTPermissionData* _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[GTPermissionData alloc] init];
        
    });
    
    return _sharedInstance;
}


+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion
{
    if (@available(iOS 10,*)) {
        
        [GTPermissionData sharedManager].completion = completion;
        
        if (![GTPermissionData sharedManager].cellularData) {
            
            CTCellularData *cellularData = [[CTCellularData alloc] init];
            
            cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (state == kCTCellularDataNotRestricted) {
                        //没有限制
                        [GTPermissionData sharedManager].completion(YES,NO);
                        NSLog(@"有网络权限");
                    }
                    else if (state == kCTCellularDataRestrictedStateUnknown)
                    {
                        //                    completion(NO,NO);
                        NSLog(@"没有请求网络或正在等待用户确认权限?");
                    }
                    else{
                        //
                        [GTPermissionData sharedManager].completion(NO,NO);
                        NSLog(@"无网络权限");
                    }
                });
            };
            
            //不存储，对象cellularData会销毁
            [GTPermissionData sharedManager].cellularData = cellularData;
        }
    }
    else
    {
        completion(YES,NO);
    }
    
}

@end
