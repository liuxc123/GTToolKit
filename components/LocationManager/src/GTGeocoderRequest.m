//
//  GTGeocoderRequest.m
//  GTCatalog
//
//  Created by liuxc on 2018/12/4.
//

#import "GTGeocoderRequest.h"
#import "private/GTRequestIDGenerator.h"

@implementation GTGeocoderRequest

/**
 Designated initializer. Initializes and returns a newly allocated heading request.
 */
- (instancetype)init
{
    if (self = [super init]) {
        _requestID = [GTRequestIDGenerator getUniqueRequestID];
        _geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

/**
 Two heading requests are considered equal if their request IDs match.
 */
- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }
    if (((GTGeocoderRequest *)object).requestID == self.requestID) {
        return YES;
    }
    return NO;
}

/**
 Return a hash based on the string representation of the request ID.
 */
- (NSUInteger)hash
{
    return [[NSString stringWithFormat:@"%ld", (long)self.requestID] hash];
}

@end
