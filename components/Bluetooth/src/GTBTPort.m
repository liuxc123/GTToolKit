//
//  GTBTPort.m
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import "GTBTPort.h"

@implementation GTBTPort

-(instancetype)initWithServiceID:(nonnull NSString *)serviceID
                characteristicID:(nonnull NSString *)charateristicID
                   descriptionID:(nullable NSString *)descriptionID {
    self = [super init];
    _serviceID = [serviceID copy];
    _charateristicID = [charateristicID copy];
    _descriptorID = [descriptionID copy];
    return self;
    
}

+(instancetype)portWithServiceID:(nonnull NSString *)serviceID
                characteristicID:(nonnull NSString *)charateristicID
                   descriptionID:(nullable NSString *)descriptionID {
    return [[GTBTPort alloc] initWithServiceID:serviceID characteristicID:charateristicID descriptionID:descriptionID];
}

+(instancetype)portWithServiceID:(nonnull NSString *)serviceID
                characteristicID:(nonnull NSString *)charateristicID {
    return [[GTBTPort alloc] initWithServiceID:serviceID characteristicID:charateristicID descriptionID:nil];
}

-(BOOL)isEqual:(id)object {
    
    if(self == object)
        return YES;
    if([object isKindOfClass:[GTBTPort class]])
    {
        GTBTPort *otherPort = (GTBTPort *)object;
        
        if([self.serviceID isEqualToString:otherPort.serviceID]
           && [self.charateristicID isEqualToString:otherPort.charateristicID]) {
            
            if((!self.descriptorID && !otherPort.descriptorID)
               ||([self.descriptorID isEqualToString:otherPort.descriptorID]))
                return YES;
        }
    }
    return NO;
}

@end
