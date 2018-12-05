//
//  MAMapSearchManager.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/5.
//

#import <Foundation/Foundation.h>
#import "MASearchResult.h"
#import <AMapSearchKit/AMapSearchKit.h>

//关键字搜索数据回调block
typedef void(^MASearchCompletionBlock)(AMapSearchObject *request, AMapSearchObject *response);
//搜索失败回调block
typedef void(^MASearchErrorBlock)(NSError *error);
//搜索搜索Id
typedef NSInteger GTMAMapSearchRequestID;

@interface MAMapSearchManager : NSObject

/** 单例对象 */
+ (instancetype)sharedManager;


/**
 高德地图搜索方法

 @param request 请求对象
 @param completeBlock 完成回调
 @param errorblock 失败回调
 @return 返回requestID
 */
- (GTMAMapSearchRequestID *)searchForRequest:(AMapSearchObject *)request
                               completeBlock:(MASearchCompletionBlock)completeBlock
                                  errorBlock:(MASearchErrorBlock)errorblock;

@end
