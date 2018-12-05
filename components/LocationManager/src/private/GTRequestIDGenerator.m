//
//  GTRequestIDGenerator.m
//  GTCatalog
//
//  Created by liuxc on 2018/12/3.
//

#import "GTRequestIDGenerator.h"

@implementation GTRequestIDGenerator

static GTLocationRequestID _nextRequestID = 0;

+(GTLocationRequestID)getUniqueRequestID
{
    _nextRequestID++;
    return _nextRequestID;
}

@end
