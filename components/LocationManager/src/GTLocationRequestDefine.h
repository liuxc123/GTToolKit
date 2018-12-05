//
//  GTLocationRequestDefine.h
//  Pods
//
//  Created by liuxc on 2018/12/3.
//

#ifndef GTLocationRequestDefine_h
#define GTLocationRequestDefine_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LBSAddressInfo.h"

#if __has_feature(objc_generics)
#   define __GT_GENERICS(type, ...)       type<__VA_ARGS__>
#else
#   define __GT_GENERICS(type, ...)       type
#endif

#ifdef NS_DESIGNATED_INITIALIZER
#   define __GT_DESIGNATED_INITIALIZER    NS_DESIGNATED_INITIALIZER
#else
#   define __GT_DESIGNATED_INITIALIZER
#endif

static const CLLocationAccuracy kGTHorizontalAccuracyThresholdCity =         5000.0;  // in meters
static const CLLocationAccuracy kGTHorizontalAccuracyThresholdNeighborhood = 1000.0;  // in meters
static const CLLocationAccuracy kGTHorizontalAccuracyThresholdBlock =         100.0;  // in meters
static const CLLocationAccuracy kGTHorizontalAccuracyThresholdHouse =          15.0;  // in meters
static const CLLocationAccuracy kGTHorizontalAccuracyThresholdRoom =            5.0;  // in meters

static const NSTimeInterval kGTUpdateTimeStaleThresholdCity =             600.0;  // in seconds
static const NSTimeInterval kGTUpdateTimeStaleThresholdNeighborhood =     300.0;  // in seconds
static const NSTimeInterval kGTUpdateTimeStaleThresholdBlock =             60.0;  // in seconds
static const NSTimeInterval kGTUpdateTimeStaleThresholdHouse =             15.0;  // in seconds
static const NSTimeInterval kGTUpdateTimeStaleThresholdRoom =               5.0;  // in seconds

/** The possible states that location services can be in. */
typedef NS_ENUM(NSInteger, GTLocationServicesState) {
    /** User has already granted this app permissions to access location services, and they are enabled and ready for use by this app.
     Note: this state will be returned for both the "When In Use" and "Always" permission levels. */
    GTLocationServicesStateAvailable,
    /** User has not yet responded to the dialog that grants this app permission to access location services. */
    GTLocationServicesStateNotDetermined,
    /** User has explicitly denied this app permission to access location services. (The user can enable permissions again for this app from the system Settings app.) */
    GTLocationServicesStateDenied,
    /** User does not have ability to enable location services (e.g. parental controls, corporate policy, etc). */
    GTLocationServicesStateRestricted,
    /** User has turned off location services device-wide (for all apps) from the system Settings app. */
    GTLocationServicesStateDisabled
};

/** The possible states that heading services can be in. */
typedef NS_ENUM(NSInteger, GTHeadingServicesState) {
    /** Heading services are available on the device */
    GTHeadingServicesStateAvailable,
    /** Heading services are available on the device */
    GTHeadingServicesStateUnavailable,
};

/** The possible states that heading services can be in. */
typedef NS_ENUM(NSInteger, GTGeocoderServicesState) {
    /** Heading services are available on the device */
    GTGeocoderServicesStateAvailable,
    /** Heading services are available on the device */
    GTGeocoderServicesStateUnavailable,
};

/** A unique ID that corresponds to one location request. */
typedef NSInteger GTLocationRequestID;

/** A unique ID that corresponds to one heading request. */
typedef NSInteger GTHeadingRequestID;

/** A unique ID that corresponds to one geocoder request. */
typedef NSInteger GTGeocoderRequestID;

/** An abstraction of both the horizontal accuracy and recency of location data.
 Room is the highest level of accuracy/recency; City is the lowest level. */
typedef NS_ENUM(NSInteger, GTLocationAccuracy) {
    // 'None' is not valid as a desired accuracy.
    /** Inaccurate (>5000 meters, and/or received >10 minutes ago). */
    GTLocationAccuracyNone = 0,

    // The below options are valid desired accuracies.
    /** 5000 meters or better, and received within the last 10 minutes. Lowest accuracy. */
    GTLocationAccuracyCity,
    /** 1000 meters or better, and received within the last 5 minutes. */
    GTLocationAccuracyNeighborhood,
    /** 100 meters or better, and received within the last 1 minute. */
    GTLocationAccuracyBlock,
    /** 15 meters or better, and received within the last 15 seconds. */
    GTLocationAccuracyHouse,
    /** 5 meters or better, and received within the last 5 seconds. Highest accuracy. */
    GTLocationAccuracyRoom,
};

/** An alias of the heading filter accuracy in degrees.
 Specifies the minimum amount of change in degrees needed for a heading service update. Observers will not be notified of updates less than the stated filter value. */
typedef CLLocationDegrees GTHeadingFilterAccuracy;

/** A status that will be passed in to the completion block of a location request. */
typedef NS_ENUM(NSInteger, GTLocationStatus) {
    // These statuses will accompany a valid location.
    /** Got a location and desired accuracy level was achieved successfully. */
    GTLocationStatusSuccess = 0,
    /** Got a location, but the desired accuracy level was not reached before timeout. (Not applicable to subscriptions.) */
    GTLocationStatusTimedOut,

    // These statuses indicate some sort of error, and will accompany a nil location.
    /** User has not yet responded to the dialog that grants this app permission to access location services. */
    GTLocationStatusServicesNotDetermined,
    /** User has explicitly denied this app permission to access location services. */
    GTLocationStatusServicesDenied,
    /** User does not have ability to enable location services (e.g. parental controls, corporate policy, etc). */
    GTLocationStatusServicesRestricted,
    /** User has turned off location services device-wide (for all apps) from the system Settings app. */
    GTLocationStatusServicesDisabled,
    /** An error occurred while using the system location services. */
    GTLocationStatusError
};

/** A status that will be passed in to the completion block of a heading request. */
typedef NS_ENUM(NSInteger, GTHeadingStatus) {
    // These statuses will accompany a valid heading.
    /** Got a heading successfully. */
    GTHeadingStatusSuccess = 0,

    // These statuses indicate some sort of error, and will accompany a nil heading.
    /** Heading was invalid. */
    GTHeadingStatusInvalid,

    /** Heading services are not available on the device */
    GTHeadingStatusUnavailable
};

/** A status that will be passed in to the completion block of a heading request. */
typedef NS_ENUM(NSInteger, GTGeocoderStatus) {
    // These statuses will accompany a valid heading.
    /** Got a heading successfully. */
    GTGeocoderStatusSuccess = 0,

    // These statuses indicate some sort of error, and will accompany a nil heading.
    /** Heading was invalid. */
    GTGeocoderStatusInvalid,
};

/**
 A block type for a location request, which is executed when the request succeeds, fails, or times out.

 @param currentLocation The most recent & accurate current location available when the block executes, or nil if no valid location is available.
 @param achievedAccuracy The accuracy level that was actually achieved (may be better than, equal to, or worse than the desired accuracy).
 @param status The status of the location request - whether it succeeded, timed out, or failed due to some sort of error. This can be used to
 understand what the outcome of the request was, decide if/how to use the associated currentLocation, and determine whether other
 actions are required (such as displaying an error message to the user, retrying with another request, quietly proceeding, etc).
 */
typedef void(^GTLocationRequestBlock)(CLLocation *currentLocation, GTLocationAccuracy achievedAccuracy, GTLocationStatus status);

/**
 A block type for a heading request, which is executed when the request succeeds.

 @param currentHeading  The most recent current heading available when the block executes.
 @param status          The status of the request - whether it succeeded or failed due to some sort of error. This can be used to understand if any further action is needed.
 */
typedef void(^GTHeadingRequestBlock)(CLHeading *currentHeading, GTHeadingStatus status);


/**
 逆地理编码block回调

 @param currentAddress 逆地理返回的信息
 @param status 返回的状态
 */
typedef void(^GTGeocoderRequestBlock)(LBSAddressInfo *currentAddress, GTGeocoderStatus status);


typedef NS_ENUM(NSUInteger, GTAuthorizationType) {
    GTAuthorizationTypeAuto,
    GTAuthorizationTypeAlways,
    GTAuthorizationTypeWhenInUse,
};

#endif /* GTLocationRequestDefine_h */
