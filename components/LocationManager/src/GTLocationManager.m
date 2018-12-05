//
//  GTLocationManager.m
//  GTCatalog
//
//  Created by liuxc on 2018/12/3.
//

#import "GTLocationManager.h"
#import "private/GTLocationManager+Private.h"
#import "GTLocationRequest.h"
#import "GTHeadingRequest.h"
#import "GTGeocoderRequest.h"

#ifndef GT_ENABLE_LOGGING
#   ifdef DEBUG
#       define GT_ENABLE_LOGGING 1
#   else
#       define GT_ENABLE_LOGGING 0
#   endif /* DEBUG */
#endif /* GT_ENABLE_LOGGING */

#if GT_ENABLE_LOGGING
#   define GTLMLog(...)          NSLog(@"GTLocationManager: %@", [NSString stringWithFormat:__VA_ARGS__]);
#else
#   define GTLMLog(...)
#endif /* GT_ENABLE_LOGGING */


@interface GTLocationManager () <CLLocationManagerDelegate, GTLocationRequestDelegate>

/** The instance of CLLocationManager encapsulated by this class. */
@property (nonatomic, strong) CLLocationManager *locationManager;
/** The most recent current location, or nil if the current location is unknown, invalid, or stale. */
@property (nonatomic, strong) CLLocation *currentLocation;
/** The most recent current heading, or nil if the current heading is unknown, invalid, or stale. */
@property (nonatomic, strong) CLHeading *currentHeading;
/** Whether or not the CLLocationManager is currently monitoring significant location changes. */
@property (nonatomic, assign) BOOL isMonitoringSignificantLocationChanges;
/** Whether or not the CLLocationManager is currently sending location updates. */
@property (nonatomic, assign) BOOL isUpdatingLocation;
/** Whether or not the CLLocationManager is currently sending heading updates. */
@property (nonatomic, assign) BOOL isUpdatingHeading;
/** Whether an error occurred during the last location update. */
@property (nonatomic, assign) BOOL updateFailed;


// An array of active location requests in the form:
// @[ GTLocationRequest *locationRequest1, GTLocationRequest *locationRequest2, ... ]
@property (nonatomic, strong) __GT_GENERICS(NSArray, GTLocationRequest *) *locationRequests;

// An array of active heading requests in the form:
// @[ GTHeadingRequest *headingRequest1, GTHeadingRequest *headingRequest2, ... ]
@property (nonatomic, strong) __GT_GENERICS(NSArray, GTHeadingRequest *) *headingRequests;

// An array of active heading requests in the form:
// @[ GTGeocoderRequest *geocodeRequest1, GTGeocoderRequest *geocodeRequest2, ... ]
@property (nonatomic, strong) __GT_GENERICS(NSArray, GTGeocoderRequest *) *geocodeRequests;

@end


@implementation GTLocationManager

static id _sharedInstance;

/**
 Returns the current state of location services for this app, based on the system settings and user authorization status.
 */
+ (GTLocationServicesState)locationServicesState
{
    if ([CLLocationManager locationServicesEnabled] == NO) {
        return GTLocationServicesStateDisabled;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        return GTLocationServicesStateNotDetermined;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        return GTLocationServicesStateDenied;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        return GTLocationServicesStateRestricted;
    }

    return GTLocationServicesStateAvailable;
}

/**
 Returns the current state of heading services for this device.
 */
+ (GTHeadingServicesState)headingServicesState
{
    if ([CLLocationManager headingAvailable]) {
        return GTHeadingServicesStateAvailable;
    } else {
        return GTHeadingServicesStateUnavailable;
    }
}

/**
 Returns the singleton instance of this class.
 */
+ (instancetype)sharedInstance
{
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    NSAssert(_sharedInstance == nil, @"Only one instance of GTLocationManager should be created. Use +[GTLocationManager sharedInstance] instead.");
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        self.preferredAuthorizationType = GTAuthorizationTypeAuto;

#ifdef __IPHONE_8_4
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_4
        /* iOS 9 requires setting allowsBackgroundLocationUpdates to YES in order to receive background location updates.
         We only set it to YES if the location background mode is enabled for this app, as the documentation suggests it is a
         fatal programmer error otherwise. */
        NSArray *backgroundModes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"];
        if ([backgroundModes containsObject:@"location"]) {
            if (@available(iOS 9, *)) {
                [_locationManager setAllowsBackgroundLocationUpdates:YES];
            }
        }
#endif /* __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_4 */
#endif /* __IPHONE_8_4 */

        _locationRequests = @[];
    }
    return self;
}

#pragma mark Public location methods

/**
 Asynchronously requests the current location of the device using location services.

 @param desiredAccuracy The accuracy level desired (refers to the accuracy and recency of the location).
 @param timeout         The maximum amount of time (in seconds) to wait for a location with the desired accuracy before completing.
 If this value is 0.0, no timeout will be set (will wait indefinitely for success, unless request is force completed or canceled).
 @param block           The block to be executed when the request succeeds, fails, or times out. Three parameters are passed into the block:
 - The current location (the most recent one acquired, regardless of accuracy level), or nil if no valid location was acquired
 - The achieved accuracy for the current location (may be less than the desired accuracy if the request failed)
 - The request status (if it succeeded, or if not, why it failed)

 @return The location request ID, which can be used to force early completion or cancel the request while it is in progress.
 */
- (GTLocationRequestID)requestLocationWithDesiredAccuracy:(GTLocationAccuracy)desiredAccuracy
                                                    timeout:(NSTimeInterval)timeout
                                                      block:(GTLocationRequestBlock)block
{
    return [self requestLocationWithDesiredAccuracy:desiredAccuracy
                                            timeout:timeout
                               delayUntilAuthorized:NO
                                              block:block];
}

/**
 Asynchronously requests the current location of the device using location services, optionally waiting until the user grants the app permission
 to access location services before starting the timeout countdown.

 @param desiredAccuracy      The accuracy level desired (refers to the accuracy and recency of the location).
 @param timeout              The maximum amount of time (in seconds) to wait for a location with the desired accuracy before completing. If
 this value is 0.0, no timeout will be set (will wait indefinitely for success, unless request is force completed or canceled).
 @param delayUntilAuthorized A flag specifying whether the timeout should only take effect after the user responds to the system prompt requesting
 permission for this app to access location services. If YES, the timeout countdown will not begin until after the
 app receives location services permissions. If NO, the timeout countdown begins immediately when calling this method.
 @param block                The block to be executed when the request succeeds, fails, or times out. Three parameters are passed into the block:
 - The current location (the most recent one acquired, regardless of accuracy level), or nil if no valid location was acquired
 - The achieved accuracy for the current location (may be less than the desired accuracy if the request failed)
 - The request status (if it succeeded, or if not, why it failed)

 @return The location request ID, which can be used to force early completion or cancel the request while it is in progress.
 */
- (GTLocationRequestID)requestLocationWithDesiredAccuracy:(GTLocationAccuracy)desiredAccuracy
                                                    timeout:(NSTimeInterval)timeout
                                       delayUntilAuthorized:(BOOL)delayUntilAuthorized
                                                      block:(GTLocationRequestBlock)block
{
    NSAssert([NSThread isMainThread], @"GTLocationManager should only be called from the main thread.");

    if (desiredAccuracy == GTLocationAccuracyNone) {
        NSAssert(desiredAccuracy != GTLocationAccuracyNone, @"GTLocationAccuracyNone is not a valid desired accuracy.");
        desiredAccuracy = GTLocationAccuracyCity; // default to the lowest valid desired accuracy
    }

    GTLocationRequest *locationRequest = [[GTLocationRequest alloc] initWithType:GTLocationRequestTypeSingle];
    locationRequest.delegate = self;
    locationRequest.desiredAccuracy = desiredAccuracy;
    locationRequest.timeout = timeout;
    locationRequest.block = block;

    BOOL deferTimeout = delayUntilAuthorized && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined);
    if (!deferTimeout) {
        [locationRequest startTimeoutTimerIfNeeded];
    }

    [self addLocationRequest:locationRequest];

    return locationRequest.requestID;
}

/**
 Creates a subscription for location updates that will execute the block once per update indefinitely (until canceled), regardless of the accuracy of each location.
 This method instructs location services to use the highest accuracy available (which also requires the most power).
 If an error occurs, the block will execute with a status other than GTLocationStatusSuccess, and the subscription will be canceled automatically.

 @param block The block to execute every time an updated location is available.
 The status will be GTLocationStatusSuccess unless an error occurred; it will never be GTLocationStatusTimedOut.

 @return The location request ID, which can be used to cancel the subscription of location updates to this block.
 */
- (GTLocationRequestID)subscribeToLocationUpdatesWithBlock:(GTLocationRequestBlock)block
{
    return [self subscribeToLocationUpdatesWithDesiredAccuracy:GTLocationAccuracyRoom
                                                         block:block];
}

/**
 Creates a subscription for location updates that will execute the block once per update indefinitely (until canceled), regardless of the accuracy of each location.
 The specified desired accuracy is passed along to location services, and controls how much power is used, with higher accuracies using more power.
 If an error occurs, the block will execute with a status other than GTLocationStatusSuccess, and the subscription will be canceled automatically.

 @param desiredAccuracy The accuracy level desired, which controls how much power is used by the device's location services.
 @param block           The block to execute every time an updated location is available. Note that this block runs for every update, regardless of
 whether the achievedAccuracy is at least the desiredAccuracy.
 The status will be GTLocationStatusSuccess unless an error occurred; it will never be GTLocationStatusTimedOut.

 @return The location request ID, which can be used to cancel the subscription of location updates to this block.
 */
- (GTLocationRequestID)subscribeToLocationUpdatesWithDesiredAccuracy:(GTLocationAccuracy)desiredAccuracy
                                                                 block:(GTLocationRequestBlock)block
{
    NSAssert([NSThread isMainThread], @"GTLocationManager should only be called from the main thread.");

    GTLocationRequest *locationRequest = [[GTLocationRequest alloc] initWithType:GTLocationRequestTypeSubscription];
    locationRequest.desiredAccuracy = desiredAccuracy;
    locationRequest.block = block;

    [self addLocationRequest:locationRequest];

    return locationRequest.requestID;
}

/**
 Creates a subscription for significant location changes that will execute the block once per change indefinitely (until canceled).
 If an error occurs, the block will execute with a status other than GTLocationStatusSuccess, and the subscription will be canceled automatically.

 @param block The block to execute every time an updated location is available.
 The status will be GTLocationStatusSuccess unless an error occurred; it will never be GTLocationStatusTimedOut.

 @return The location request ID, which can be used to cancel the subscription of significant location changes to this block.
 */
- (GTLocationRequestID)subscribeToSignificantLocationChangesWithBlock:(GTLocationRequestBlock)block
{
    NSAssert([NSThread isMainThread], @"GTLocationManager should only be called from the main thread.");

    GTLocationRequest *locationRequest = [[GTLocationRequest alloc] initWithType:GTLocationRequestTypeSignificantChanges];
    locationRequest.block = block;

    [self addLocationRequest:locationRequest];

    return locationRequest.requestID;
}

/**
 Immediately forces completion of the location request with the given requestID (if it exists), and executes the original request block with the results.
 This is effectively a manual timeout, and will result in the request completing with status GTLocationStatusTimedOut.
 */
- (void)forceCompleteLocationRequest:(GTLocationRequestID)requestID
{
    NSAssert([NSThread isMainThread], @"GTLocationManager should only be called from the main thread.");

    for (GTLocationRequest *locationRequest in self.locationRequests) {
        if (locationRequest.requestID == requestID) {
            if (locationRequest.isRecurring) {
                // Recurring requests can only be canceled
                [self cancelLocationRequest:requestID];
            } else {
                [locationRequest forceTimeout];
                [self completeLocationRequest:locationRequest];
            }
            break;
        }
    }
}

/**
 Immediately cancels the location request with the given requestID (if it exists), without executing the original request block.
 */
- (void)cancelLocationRequest:(GTLocationRequestID)requestID
{
    NSAssert([NSThread isMainThread], @"GTLocationManager should only be called from the main thread.");

    for (GTLocationRequest *locationRequest in self.locationRequests) {
        if (locationRequest.requestID == requestID) {
            [locationRequest cancel];
            GTLMLog(@"Location Request canceled with ID: %ld", (long)locationRequest.requestID);
            [self removeLocationRequest:locationRequest];
            break;
        }
    }
}

#pragma mark Public heading methods

/**
 Asynchronously requests the current heading of the device using location services.

 @param block The block to be executed when the request succeeds. One parameter is passed into the block:
 - The current heading (the most recent one acquired, regardless of accuracy level), or nil if no valid heading was acquired

 @return The heading request ID, which can be used remove the request from being called in the future.
 */
- (GTHeadingRequestID)subscribeToHeadingUpdatesWithBlock:(GTHeadingRequestBlock)block
{
    GTHeadingRequest *headingRequest = [[GTHeadingRequest alloc] init];
    headingRequest.block = block;

    [self addHeadingRequest:headingRequest];

    return headingRequest.requestID;
}

/**
 Immediately cancels the heading request with the given requestID (if it exists), without executing the original request block.
 */
- (void)cancelHeadingRequest:(GTHeadingRequestID)requestID
{
    for (GTHeadingRequest *headingRequest in self.headingRequests) {
        if (headingRequest.requestID == requestID) {
            [self removeHeadingRequest:headingRequest];
            GTLMLog(@"Heading Request canceled with ID: %ld", (long)headingRequest.requestID);
            break;
        }
    }
}

#pragma mark Public geocode methods

- (GTGeocoderRequestID)requestGeocoderWithLocation:(CLLocation *)location block:(GTGeocoderRequestBlock)block
{
    GTGeocoderRequest *geocoderRequest = [[GTGeocoderRequest alloc] init];
    geocoderRequest.block = block;

    [self addGeocodeRequest:geocoderRequest location:location];

    return geocoderRequest.requestID;
}

/**
 Immediately cancels the geocode request with the given requestID (if it exists), without executing the original request block.
 */
- (void)cancelGeocoderRequest:(GTGeocoderRequestID)requestID {

    for (GTGeocoderRequest *geocoderRequest in self.geocodeRequests) {
        if (geocoderRequest.requestID == requestID) {
            [self removeGeocodeRequest:geocoderRequest];
            GTLMLog(@"Geocoder Request canceled with ID: %ld", (long)geocoderRequest.requestID);
            break;
        }
    }
}


#pragma mark Internal location methods

/**
 Adds the given location request to the array of requests, updates the maximum desired accuracy, and starts location updates if needed.
 */
- (void)addLocationRequest:(GTLocationRequest *)locationRequest
{
    GTLocationServicesState locationServicesState = [GTLocationManager locationServicesState];
    if (locationServicesState == GTLocationServicesStateDisabled ||
        locationServicesState == GTLocationServicesStateDenied ||
        locationServicesState == GTLocationServicesStateRestricted) {
        // No need to add this location request, because location services are turned off device-wide, or the user has denied this app permissions to use them
        [self completeLocationRequest:locationRequest];
        return;
    }

    switch (locationRequest.type) {
        case GTLocationRequestTypeSingle:
        case GTLocationRequestTypeSubscription:
        {
            GTLocationAccuracy maximumDesiredAccuracy = GTLocationAccuracyNone;
            // Determine the maximum desired accuracy for all existing location requests (does not include the new request we're currently adding)
            for (GTLocationRequest *locationRequest in [self activeLocationRequestsExcludingType:GTLocationRequestTypeSignificantChanges]) {
                if (locationRequest.desiredAccuracy > maximumDesiredAccuracy) {
                    maximumDesiredAccuracy = locationRequest.desiredAccuracy;
                }
            }
            // Take the max of the maximum desired accuracy for all existing location requests and the desired accuracy of the new request we're currently adding
            maximumDesiredAccuracy = MAX(locationRequest.desiredAccuracy, maximumDesiredAccuracy);
            [self updateWithMaximumDesiredAccuracy:maximumDesiredAccuracy];

            [self startUpdatingLocationIfNeeded];
        }
            break;
        case GTLocationRequestTypeSignificantChanges:
            [self startMonitoringSignificantLocationChangesIfNeeded];
            break;
    }
    __GT_GENERICS(NSMutableArray, GTLocationRequest *) *newLocationRequests = [NSMutableArray arrayWithArray:self.locationRequests];
    [newLocationRequests addObject:locationRequest];
    self.locationRequests = newLocationRequests;
    GTLMLog(@"Location Request added with ID: %ld", (long)locationRequest.requestID);

    // Process all location requests now, as we may be able to immediately complete the request just added above
    // if a location update was recently received (stored in self.currentLocation) that satisfies its criteria.
    [self processLocationRequests];
}

/**
 Removes a given location request from the array of requests, updates the maximum desired accuracy, and stops location updates if needed.
 */
- (void)removeLocationRequest:(GTLocationRequest *)locationRequest
{
    __GT_GENERICS(NSMutableArray, GTLocationRequest *) *newLocationRequests = [NSMutableArray arrayWithArray:self.locationRequests];
    [newLocationRequests removeObject:locationRequest];
    self.locationRequests = newLocationRequests;

    switch (locationRequest.type) {
        case GTLocationRequestTypeSingle:
        case GTLocationRequestTypeSubscription:
        {
            // Determine the maximum desired accuracy for all remaining location requests
            GTLocationAccuracy maximumDesiredAccuracy = GTLocationAccuracyNone;
            for (GTLocationRequest *locationRequest in [self activeLocationRequestsExcludingType:GTLocationRequestTypeSignificantChanges]) {
                if (locationRequest.desiredAccuracy > maximumDesiredAccuracy) {
                    maximumDesiredAccuracy = locationRequest.desiredAccuracy;
                }
            }
            [self updateWithMaximumDesiredAccuracy:maximumDesiredAccuracy];

            [self stopUpdatingLocationIfPossible];
        }
            break;
        case GTLocationRequestTypeSignificantChanges:
            [self stopMonitoringSignificantLocationChangesIfPossible];
            break;
    }
}

/**
 Returns the most recent current location, or nil if the current location is unknown, invalid, or stale.
 */
- (CLLocation *)currentLocation
{
    if (_currentLocation) {
        // Location isn't nil, so test to see if it is valid
        if (!CLLocationCoordinate2DIsValid(_currentLocation.coordinate) || (_currentLocation.coordinate.latitude == 0.0 && _currentLocation.coordinate.longitude == 0.0)) {
            // The current location is invalid; discard it and return nil
            _currentLocation = nil;
        }
    }

    // Location is either nil or valid at this point, return it
    return _currentLocation;
}

/**
 Requests permission to use location services on devices with iOS 8+.
 */
- (void)requestAuthorizationIfNeeded
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    // As of iOS 8, apps must explicitly request location services permissions. GTLocationManager supports both levels, "Always" and "When In Use".
    // GTLocationManager determines which level of permissions to request based on which description key is present in your app's Info.plist
    // If you provide values for both description keys, the more permissive "Always" level is requested.

    double iOSVersion = floor(NSFoundationVersionNumber);
    BOOL isiOSVersion7to10 = iOSVersion > NSFoundationVersionNumber_iOS_7_1 && iOSVersion <= NSFoundationVersionNumber10_11_Max;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        BOOL canRequestAlways = NO;
        BOOL canRequestWhenInUse = NO;
        if (isiOSVersion7to10) {
            canRequestAlways = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] != nil;
            canRequestWhenInUse = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil;
        } else {
            canRequestAlways = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysAndWhenInUseUsageDescription"] != nil;
            canRequestWhenInUse = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil;
        }
        BOOL needRequestAlways = NO;
        BOOL needRequestWhenInUse = NO;
        switch (self.preferredAuthorizationType) {
            case GTAuthorizationTypeAuto:
                needRequestAlways = canRequestAlways;
                needRequestWhenInUse = canRequestWhenInUse;
                break;
            case GTAuthorizationTypeAlways:
                needRequestAlways = canRequestAlways;
                break;
            case GTAuthorizationTypeWhenInUse:
                needRequestWhenInUse = canRequestWhenInUse;
                break;

            default:
                break;
        }
        if (needRequestAlways) {
            [self.locationManager requestAlwaysAuthorization];
        } else if (needRequestWhenInUse) {
            [self.locationManager requestWhenInUseAuthorization];
        } else {
            if (isiOSVersion7to10) {
                // At least one of the keys NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription MUST be present in the Info.plist file to use location services on iOS 8+.
                NSAssert(canRequestAlways || canRequestWhenInUse, @"To use location services in iOS 8+, your Info.plist must provide a value for either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription.");
            } else {
                // Key NSLocationAlwaysAndWhenInUseUsageDescription MUST be present in the Info.plist file to use location services on iOS 11+.
                NSAssert(canRequestAlways, @"To use location services in iOS 11+, your Info.plist must provide a value for NSLocationAlwaysAndWhenInUseUsageDescription.");
            }
        }
    }
#endif /* __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1 */
}

/**
 Sets the CLLocationManager desiredAccuracy based on the given maximum desired accuracy (which should be the maximum desired accuracy of all active location requests).
 */
- (void)updateWithMaximumDesiredAccuracy:(GTLocationAccuracy)maximumDesiredAccuracy
{
    switch (maximumDesiredAccuracy) {
        case GTLocationAccuracyNone:
            break;
        case GTLocationAccuracyCity:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyThreeKilometers) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
                GTLMLog(@"Changing location services accuracy level to: low (minimum).");
            }
            break;
        case GTLocationAccuracyNeighborhood:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyKilometer) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
                GTLMLog(@"Changing location services accuracy level to: medium low.");
            }
            break;
        case GTLocationAccuracyBlock:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyHundredMeters) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
                GTLMLog(@"Changing location services accuracy level to: medium.");
            }
            break;
        case GTLocationAccuracyHouse:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyNearestTenMeters) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
                GTLMLog(@"Changing location services accuracy level to: medium high.");
            }
            break;
        case GTLocationAccuracyRoom:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyBest) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                GTLMLog(@"Changing location services accuracy level to: high (maximum).");
            }
            break;
        default:
            NSAssert(nil, @"Invalid maximum desired accuracy!");
            break;
    }
}

/**
 Inform CLLocationManager to start monitoring significant location changes.
 */
- (void)startMonitoringSignificantLocationChangesIfNeeded
{
    [self requestAuthorizationIfNeeded];

    NSArray *locationRequests = [self activeLocationRequestsWithType:GTLocationRequestTypeSignificantChanges];
    if (locationRequests.count == 0) {
        [self.locationManager startMonitoringSignificantLocationChanges];
        if (self.isMonitoringSignificantLocationChanges == NO) {
            GTLMLog(@"Significant location change monitoring has started.")
        }
        self.isMonitoringSignificantLocationChanges = YES;
    }
}

/**
 Inform CLLocationManager to start sending us updates to our location.
 */
- (void)startUpdatingLocationIfNeeded
{
    [self requestAuthorizationIfNeeded];

    NSArray *locationRequests = [self activeLocationRequestsExcludingType:GTLocationRequestTypeSignificantChanges];
    if (locationRequests.count == 0) {
        [self.locationManager startUpdatingLocation];
        if (self.isUpdatingLocation == NO) {
            GTLMLog(@"Location services updates have started.");
        }
        self.isUpdatingLocation = YES;
    }
}

- (void)stopMonitoringSignificantLocationChangesIfPossible
{
    NSArray *locationRequests = [self activeLocationRequestsWithType:GTLocationRequestTypeSignificantChanges];
    if (locationRequests.count == 0) {
        [self.locationManager stopMonitoringSignificantLocationChanges];
        if (self.isMonitoringSignificantLocationChanges) {
            GTLMLog(@"Significant location change monitoring has stopped.");
        }
        self.isMonitoringSignificantLocationChanges = NO;
    }
}

/**
 Checks to see if there are any outstanding locationRequests, and if there are none, informs CLLocationManager to stop sending
 location updates. This is done as soon as location updates are no longer needed in order to conserve the device's battery.
 */
- (void)stopUpdatingLocationIfPossible
{
    NSArray *locationRequests = [self activeLocationRequestsExcludingType:GTLocationRequestTypeSignificantChanges];
    if (locationRequests.count == 0) {
        [self.locationManager stopUpdatingLocation];
        if (self.isUpdatingLocation) {
            GTLMLog(@"Location services updates have stopped.");
        }
        self.isUpdatingLocation = NO;
    }
}

/**
 Iterates over the array of active location requests to check and see if the most recent current location
 successfully satisfies any of their criteria.
 */
- (void)processLocationRequests
{
    CLLocation *mostRecentLocation = self.currentLocation;

    for (GTLocationRequest *locationRequest in self.locationRequests) {
        if (locationRequest.hasTimedOut) {
            // Non-recurring request has timed out, complete it
            [self completeLocationRequest:locationRequest];
            continue;
        }

        if (mostRecentLocation != nil) {
            if (locationRequest.isRecurring) {
                // This is a subscription request, which lives indefinitely (unless manually canceled) and receives every location update we get
                [self processRecurringRequest:locationRequest];
                continue;
            } else {
                // This is a regular one-time location request
                NSTimeInterval currentLocationTimeSinceUpdate = fabs([mostRecentLocation.timestamp timeIntervalSinceNow]);
                CLLocationAccuracy currentLocationHorizontalAccuracy = mostRecentLocation.horizontalAccuracy;
                NSTimeInterval staleThreshold = [locationRequest updateTimeStaleThreshold];
                CLLocationAccuracy horizontalAccuracyThreshold = [locationRequest horizontalAccuracyThreshold];
                if (currentLocationTimeSinceUpdate <= staleThreshold &&
                    currentLocationHorizontalAccuracy <= horizontalAccuracyThreshold) {
                    // The request's desired accuracy has been reached, complete it
                    [self completeLocationRequest:locationRequest];
                    continue;
                }
            }
        }
    }
}

/**
 Immediately completes all active location requests.
 Used in cases such as when the location services authorization status changes to Denied or Restricted.
 */
- (void)completeAllLocationRequests
{
    // Iterate through a copy of the locationRequests array to avoid modifying the same array we are removing elements from
    __GT_GENERICS(NSArray, GTLocationRequest *) *locationRequests = [self.locationRequests copy];
    for (GTLocationRequest *locationRequest in locationRequests) {
        [self completeLocationRequest:locationRequest];
    }
    GTLMLog(@"Finished completing all location requests.");
}

/**
 Completes the given location request by removing it from the array of locationRequests and executing its completion block.
 */
- (void)completeLocationRequest:(GTLocationRequest *)locationRequest
{
    if (locationRequest == nil) {
        return;
    }

    [locationRequest complete];
    [self removeLocationRequest:locationRequest];

    GTLocationStatus status = [self statusForLocationRequest:locationRequest];
    CLLocation *currentLocation = self.currentLocation;
    GTLocationAccuracy achievedAccuracy = [self achievedAccuracyForLocation:currentLocation];

    // GTLocationManager is not thread safe and should only be called from the main thread, so we should already be executing on the main thread now.
    // dispatch_async is used to ensure that the completion block for a request is not executed before the request ID is returned, for example in the
    // case where the user has denied permission to access location services and the request is immediately completed with the appropriate error.
    dispatch_async(dispatch_get_main_queue(), ^{
        if (locationRequest.block) {
            locationRequest.block(currentLocation, achievedAccuracy, status);
        }
    });

    GTLMLog(@"Location Request completed with ID: %ld, currentLocation: %@, achievedAccuracy: %lu, status: %lu", (long)locationRequest.requestID, currentLocation, (unsigned long) achievedAccuracy, (unsigned long)status);
}

/**
 Handles calling a recurring location request's block with the current location.
 */
- (void)processRecurringRequest:(GTLocationRequest *)locationRequest
{
    NSAssert(locationRequest.isRecurring, @"This method should only be called for recurring location requests.");

    GTLocationStatus status = [self statusForLocationRequest:locationRequest];
    CLLocation *currentLocation = self.currentLocation;
    GTLocationAccuracy achievedAccuracy = [self achievedAccuracyForLocation:currentLocation];

    // GTLocationManager is not thread safe and should only be called from the main thread, so we should already be executing on the main thread now.
    // dispatch_async is used to ensure that the completion block for a request is not executed before the request ID is returned.
    dispatch_async(dispatch_get_main_queue(), ^{
        if (locationRequest.block) {
            locationRequest.block(currentLocation, achievedAccuracy, status);
        }
    });
}

/**
 Returns all active location requests with the given type.
 */
- (NSArray *)activeLocationRequestsWithType:(GTLocationRequestType)locationRequestType
{
    return [self.locationRequests filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(GTLocationRequest *evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject.type == locationRequestType;
    }]];
}

/**
 Returns all active location requests excluding requests with the given type.
 */
- (NSArray *)activeLocationRequestsExcludingType:(GTLocationRequestType)locationRequestType
{
    return [self.locationRequests filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(GTLocationRequest *evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject.type != locationRequestType;
    }]];
}

/**
 Returns the location manager status for the given location request.
 */
- (GTLocationStatus)statusForLocationRequest:(GTLocationRequest *)locationRequest
{
    GTLocationServicesState locationServicesState = [GTLocationManager locationServicesState];

    if (locationServicesState == GTLocationServicesStateDisabled) {
        return GTLocationStatusServicesDisabled;
    }
    else if (locationServicesState == GTLocationServicesStateNotDetermined) {
        return GTLocationStatusServicesNotDetermined;
    }
    else if (locationServicesState == GTLocationServicesStateDenied) {
        return GTLocationStatusServicesDenied;
    }
    else if (locationServicesState == GTLocationServicesStateRestricted) {
        return GTLocationStatusServicesRestricted;
    }
    else if (self.updateFailed) {
        return GTLocationStatusError;
    }
    else if (locationRequest.hasTimedOut) {
        return GTLocationStatusTimedOut;
    }

    return GTLocationStatusSuccess;
}

/**
 Returns the associated GTLocationAccuracy level that has been achieved for a given location,
 based on that location's horizontal accuracy and recency.
 */
- (GTLocationAccuracy)achievedAccuracyForLocation:(CLLocation *)location
{
    if (!location) {
        return GTLocationAccuracyNone;
    }

    NSTimeInterval timeSinceUpdate = fabs([location.timestamp timeIntervalSinceNow]);
    CLLocationAccuracy horizontalAccuracy = location.horizontalAccuracy;

    if (horizontalAccuracy <= kGTHorizontalAccuracyThresholdRoom &&
        timeSinceUpdate <= kGTUpdateTimeStaleThresholdRoom) {
        return GTLocationAccuracyRoom;
    }
    else if (horizontalAccuracy <= kGTHorizontalAccuracyThresholdHouse &&
             timeSinceUpdate <= kGTUpdateTimeStaleThresholdHouse) {
        return GTLocationAccuracyHouse;
    }
    else if (horizontalAccuracy <= kGTHorizontalAccuracyThresholdBlock &&
             timeSinceUpdate <= kGTUpdateTimeStaleThresholdBlock) {
        return GTLocationAccuracyBlock;
    }
    else if (horizontalAccuracy <= kGTHorizontalAccuracyThresholdNeighborhood &&
             timeSinceUpdate <= kGTUpdateTimeStaleThresholdNeighborhood) {
        return GTLocationAccuracyNeighborhood;
    }
    else if (horizontalAccuracy <= kGTHorizontalAccuracyThresholdCity &&
             timeSinceUpdate <= kGTUpdateTimeStaleThresholdCity) {
        return GTLocationAccuracyCity;
    }
    else {
        return GTLocationAccuracyNone;
    }
}

#pragma mark Internal heading methods

/**
 Returns the most recent heading, or nil if the current heading is unknown or invalid.
 */
- (CLHeading *)currentHeading
{
    // Heading isn't nil, so test to see if it is valid
    if (!GTCLHeadingIsIsValid(_currentHeading)) {
        // The current heading is invalid; discard it and return nil
        _currentHeading = nil;
    }

    // Heading is either nil or valid at this point, return it
    return _currentHeading;
}

/**
 Checks whether the given @c CLHeading has valid properties.
 */
BOOL GTCLHeadingIsIsValid(CLHeading *heading)
{
    return heading.trueHeading > 0 &&
    heading.headingAccuracy > 0;
}

/**
 Adds the given heading request to the array of requests and starts heading updates.
 */
- (void)addHeadingRequest:(GTHeadingRequest *)headingRequest
{
    NSAssert(headingRequest, @"Must pass in a non-nil heading request.");

    // If heading services are not available, just return
    if ([GTLocationManager headingServicesState] == GTHeadingServicesStateUnavailable) {
        // dispatch_async is used to ensure that the completion block for a request is not executed before the request ID is returned.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (headingRequest.block) {
                headingRequest.block(nil, GTHeadingStatusUnavailable);
            }
        });
        GTLMLog(@"Heading Request (ID %ld) NOT added since device heading is unavailable.", (long)headingRequest.requestID);
        return;
    }

    __GT_GENERICS(NSMutableArray, GTHeadingRequest *) *newHeadingRequests = [NSMutableArray arrayWithArray:self.headingRequests];
    [newHeadingRequests addObject:headingRequest];
    self.headingRequests = newHeadingRequests;
    GTLMLog(@"Heading Request added with ID: %ld", (long)headingRequest.requestID);

    [self startUpdatingHeadingIfNeeded];
}

/**
 Inform CLLocationManager to start sending us updates to our heading.
 */
- (void)startUpdatingHeadingIfNeeded
{
    if (self.headingRequests.count != 0) {
        [self.locationManager startUpdatingHeading];
        if (self.isUpdatingHeading == NO) {
            GTLMLog(@"Heading services updates have started.");
        }
        self.isUpdatingHeading = YES;
    }
}

/**
 Removes a given heading request from the array of requests and stops heading updates if needed.
 */
- (void)removeHeadingRequest:(GTHeadingRequest *)headingRequest
{
    __GT_GENERICS(NSMutableArray, GTHeadingRequest *) *newHeadingRequests = [NSMutableArray arrayWithArray:self.headingRequests];
    [newHeadingRequests removeObject:headingRequest];
    self.headingRequests = newHeadingRequests;

    [self stopUpdatingHeadingIfPossible];
}

/**
 Checks to see if there are any outstanding headingRequests, and if there are none, informs CLLocationManager to stop sending
 heading updates. This is done as soon as heading updates are no longer needed in order to conserve the device's battery.
 */
- (void)stopUpdatingHeadingIfPossible
{
    if (self.headingRequests.count == 0) {
        [self.locationManager stopUpdatingHeading];
        if (self.isUpdatingHeading) {
            GTLMLog(@"Location services heading updates have stopped.");
        }
        self.isUpdatingHeading = NO;
    }
}

/**
 Iterates over the array of active heading requests and processes each
 */
- (void)processRecurringHeadingRequests
{
    for (GTHeadingRequest *headingRequest in self.headingRequests) {
        [self processRecurringHeadingRequest:headingRequest];
    }
}

/**
 Handles calling a recurring heading request's block with the current heading.
 */
- (void)processRecurringHeadingRequest:(GTHeadingRequest *)headingRequest
{
    NSAssert(headingRequest.isRecurring, @"This method should only be called for recurring heading requests.");

    GTHeadingStatus status = [self statusForHeadingRequest:headingRequest];

    // Check if the request had a fatal error and should be canceled
    if (status == GTHeadingStatusUnavailable) {
        // dispatch_async is used to ensure that the completion block for a request is not executed before the request ID is returned.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (headingRequest.block) {
                headingRequest.block(nil, status);
            }
        });

        [self cancelHeadingRequest:headingRequest.requestID];
        return;
    }

    // dispatch_async is used to ensure that the completion block for a request is not executed before the request ID is returned.
    dispatch_async(dispatch_get_main_queue(), ^{
        if (headingRequest.block) {
            headingRequest.block(self.currentHeading, status);
        }
    });
}

/**
 Returns the status for the given heading request.
 */
- (GTHeadingStatus)statusForHeadingRequest:(GTHeadingRequest *)headingRequest
{
    if ([GTLocationManager headingServicesState] == GTHeadingServicesStateUnavailable) {
        return GTHeadingStatusUnavailable;
    }

    // The accessor will return nil for an invalid heading results
    if (!self.currentHeading) {
        return GTHeadingStatusInvalid;
    }

    return GTHeadingStatusSuccess;
}

#pragma mark Internal geocode methods

- (void)addGeocodeRequest:(GTGeocoderRequest *)geocodeRequest location:(CLLocation *)location
{
    NSAssert(geocodeRequest, @"Must pass in a non-nil geocode request.");

    __GT_GENERICS(NSMutableArray, GTGeocoderRequest *) *newGeocodeRequests = [NSMutableArray arrayWithArray:self.geocodeRequests];
    [newGeocodeRequests addObject:geocodeRequest];
    self.geocodeRequests = newGeocodeRequests;
    GTLMLog(@"Heading Request added with ID: %ld", (long)geocodeRequest.requestID);

    [self startGeocodeRequest:geocodeRequest location:location];
}

- (void)startGeocodeRequest:(GTGeocoderRequest *)geocodeRequest location:(CLLocation *)location
{
    __weak __typeof(self) weakSelf  = self;
    [geocodeRequest.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {

        LBSAddressInfo *addressInfo = [[LBSAddressInfo alloc] init];

        if (placemarks.count > 0) {
            CLPlacemark *mark = (CLPlacemark*)[placemarks objectAtIndex:0];// read the most confident one
            addressInfo.latitude = location ? location.coordinate.latitude : 0;
            addressInfo.longitude = location ? location.coordinate.longitude : 0;
            addressInfo.altitude = location ? location.altitude : 0;
            addressInfo.name = mark.name ? mark.name : @"" ;
            addressInfo.thoroughfare = mark.thoroughfare ? mark.thoroughfare : @"" ;
            addressInfo.subThoroughfare = mark.subThoroughfare ? mark.subThoroughfare : @"" ;
            addressInfo.locality = mark.locality ? mark.locality : @"" ;
            addressInfo.administrativeArea = mark.administrativeArea ? mark.administrativeArea : @"" ;
            addressInfo.subAdministrativeArea = mark.subAdministrativeArea ? mark.subAdministrativeArea : @"" ;
            addressInfo.administrativeArea = mark.administrativeArea ? mark.administrativeArea : @"" ;
            addressInfo.postalCode = mark.postalCode ? mark.postalCode : @"" ;
            addressInfo.country = mark.country ? mark.country : @"" ;
        } else {
            addressInfo.latitude = 0;
            addressInfo.longitude = 0;
            addressInfo.altitude = 0;
            addressInfo.name = @"Unknown";
            addressInfo.thoroughfare = @"Unknown";
            addressInfo.subThoroughfare = @"Unknown";
            addressInfo.locality = @"Unknown";
            addressInfo.administrativeArea = @"Unknown";
            addressInfo.subAdministrativeArea = @"Unknown";
            addressInfo.administrativeArea = @"Unknown";
            addressInfo.postalCode = @"Unknown";
            addressInfo.country = @"Unknown";
        }

        [weakSelf completeGeocodeRequest:geocodeRequest address:addressInfo error:error];

    }];
}

- (void)completeGeocodeRequest:(GTGeocoderRequest *)geocodeRequest address:(LBSAddressInfo *)address error:(NSError *)error
{

    GTGeocoderStatus status = (error == nil) ? GTGeocoderStatusSuccess : GTGeocoderStatusInvalid;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (geocodeRequest.block) {
            geocodeRequest.block(address, status);
        }
    });

    GTLMLog(@"Geocode Request completed with ID: %ld, status: %lu", geocodeRequest.requestID, status);
    GTLMLog(@"Geocode address country: %@ , administrativeArea: %@, subAdministrativeArea: %@, locality:%@, subLocality:%@, thoroughfare:%@, subThoroughfare:%@, postalCode:%@, name:%@",
            address.country,
            address.administrativeArea,
            address.subAdministrativeArea,
            address.locality,
            address.subLocality,
            address.thoroughfare,
            address.subThoroughfare,
            address.postalCode,
            address.name
            );

}

/**
 Removes a given heading request from the array of requests and stops heading updates if needed.
 */
- (void)removeGeocodeRequest:(GTGeocoderRequest *)geocodeRequest
{
    [geocodeRequest.geocoder cancelGeocode];
    __GT_GENERICS(NSMutableArray, GTGeocoderRequest *) *newGeocoderRequests = [NSMutableArray arrayWithArray:self.geocodeRequests];
    [newGeocoderRequests removeObject:geocodeRequest];
    self.geocodeRequests = newGeocoderRequests;
}

#pragma mark GTLocationRequestDelegate method

- (void)locationRequestDidTimeout:(GTLocationRequest *)locationRequest
{
    // For robustness, only complete the location request if it is still active (by checking to see that it hasn't been removed from the locationRequests array).
    for (GTLocationRequest *activeLocationRequest in self.locationRequests) {
        if (activeLocationRequest.requestID == locationRequest.requestID) {
            [self completeLocationRequest:locationRequest];
            break;
        }
    }
}

#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // Received update successfully, so clear any previous errors
    self.updateFailed = NO;

    CLLocation *mostRecentLocation = [locations lastObject];
    self.currentLocation = mostRecentLocation;

    // Process the location requests using the updated location
    [self processLocationRequests];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    self.currentHeading = newHeading;

    // Process the heading requests using the updated heading
    [self processRecurringHeadingRequests];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    GTLMLog(@"Location services error: %@", [error localizedDescription]);
    self.updateFailed = YES;

    for (GTLocationRequest *locationRequest in self.locationRequests) {
        if (locationRequest.isRecurring) {
            // Keep the recurring request alive
            [self processRecurringRequest:locationRequest];
        } else {
            // Fail any non-recurring requests
            [self completeLocationRequest:locationRequest];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{

    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        // Clear out any active location requests (which will execute the blocks with a status that reflects
        // the unavailability of location services) since we now no longer have location services permissions
        [self completeAllLocationRequests];
    }
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    else if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
#else
        else if (status == kCLAuthorizationStatusAuthorized) {
#endif /* __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1 */

            // Start the timeout timer for location requests that were waiting for authorization
            for (GTLocationRequest *locationRequest in self.locationRequests) {
                [locationRequest startTimeoutTimerIfNeeded];
            }
        }
    }


#pragma mark - Additions
/** It is possible to force enable background location fetch even if your set any kind of Authorizations */
- (void)setBackgroundLocationUpdate:(BOOL) enabled {
    if (@available(iOS 9, *)) {
        _locationManager.allowsBackgroundLocationUpdates = enabled;
    }
}

- (void)setShowsBackgroundLocationIndicator:(BOOL) shows {
    if (@available(iOS 11, *)) {
        _locationManager.showsBackgroundLocationIndicator = shows;
    }
}

- (void)setPausesLocationUpdatesAutomatically:(BOOL) pauses
{
    _locationManager.pausesLocationUpdatesAutomatically = pauses;
}
@end
