//
//  GTLocationRequest.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/3.
//

#import "GTLocationRequestDefine.h"

NS_ASSUME_NONNULL_BEGIN

/** 定位请求类型 */
typedef NS_ENUM(NSInteger, GTLocationRequestType) {
    /** A one-time location request with a specific desired accuracy and optional timeout. */
    /** 具有特定精度和可选超时的一次性位置请求。 */
    GTLocationRequestTypeSingle,
    /** A subscription to location updates. */
    /** 持续定位更新 */
    GTLocationRequestTypeSubscription,
    /** A subscription to significant location changes. */
    GTLocationRequestTypeSignificantChanges
};

@class GTLocationRequest;

/**
 Protocol for the GTLocationRequest to notify the its delegate that a request has timed out.
 */
@protocol GTLocationRequestDelegate

/**
 Notification that a location request has timed out.

 @param locationRequest The location request that timed out.
 */
- (void)locationRequestDidTimeout:(GTLocationRequest *)locationRequest;

@end


/**
 Represents a geolocation request that is created and managed by GTLocationManager.
 */
@interface GTLocationRequest : NSObject

/** 定位请求代理 */
@property (nonatomic, weak, nullable) id<GTLocationRequestDelegate> delegate;
/** 此位置请求的请求ID(在初始化期间设置) */
@property (nonatomic, readonly) GTLocationRequestID requestID;
/** 此位置请求的类型(在初始化期间设置)。 */
@property (nonatomic, readonly) GTLocationRequestType type;
/** 这是否是一个重复的位置请求(类型是 Subscription 或 SignificantChanges ) */
@property (nonatomic, readonly) BOOL isRecurring;
/** 此位置请求所需的精度。 */
@property (nonatomic, assign) GTLocationAccuracy desiredAccuracy;
/** 位置请求在完成之前允许存在的最长时间。
 如果这个值正好是0.0，它将被忽略(请求本身永远不会超时)。 */
@property (nonatomic, assign) NSTimeInterval timeout;
/** 自上次设置超时值以来位置请求存活的时间。 */
@property (nonatomic, readonly) NSTimeInterval timeAlive;
/** 这个位置请求是否超时(如果已经完成，也是YES)。subcrition订阅永远不会超时。 */
@property (nonatomic, readonly) BOOL hasTimedOut;
/** 定位请求完成回调 */
@property (nonatomic, copy, nullable) GTLocationRequestBlock block;

/** Designated initializer. Initializes and returns a newly allocated location request object with the specified type. */
- (instancetype)initWithType:(GTLocationRequestType)type __GT_DESIGNATED_INITIALIZER;

/** Completes the location request. */
/** 完成位置请求。 */
- (void)complete;
/** Forces the location request to consider itself timed out. */
/** 强制请求超时 */
- (void)forceTimeout;
/** Cancels the location request. */
/** 取消定位请求 */
- (void)cancel;

/** Starts the location request's timeout timer if a nonzero timeout value is set, and the timer has not already been started. */
- (void)startTimeoutTimerIfNeeded;

/** Returns the associated recency threshold (in seconds) for the location request's desired accuracy level. */
/** 返回位置请求所需精度级别的相关近似值(以秒为单位)。 */
- (NSTimeInterval)updateTimeStaleThreshold;

/** Returns the associated horizontal accuracy threshold (in meters) for the location request's desired accuracy level. */
/** 返回位置请求所需精度级别的相关水平精度阈值(以米为单位)。 */
- (CLLocationAccuracy)horizontalAccuracyThreshold;

@end

NS_ASSUME_NONNULL_END

