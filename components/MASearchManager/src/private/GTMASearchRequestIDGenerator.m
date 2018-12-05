//
//  GTMASearchRequestIDGenerator.m
//  GTCatalog
//
//  Created by liuxc on 2018/12/5.
//

#import "GTMASearchRequestIDGenerator.h"

@implementation GTMASearchRequestIDGenerator

static GTMAMapSearchRequestID _nextRequestID = 0;

+(GTMAMapSearchRequestID)getUniqueRequestID
{
    _nextRequestID++;
    return _nextRequestID;
}

@end
