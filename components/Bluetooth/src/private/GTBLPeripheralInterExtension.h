//
//  GTBLPeripheralInterExtension.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@class GTBTCentralManager;

@interface CBAttribute (GTBLInternal)

@property (nonatomic) BOOL finishedSubArributeDiscover;

@property (nonatomic, copy) NSString *interPropertiesDescription;

@end

@interface CBPeripheral (GTBLInternal)

@property (nullable, nonatomic, weak) GTBTCentralManager *centralManager;

@property (nonatomic) int interRssiValue;

@property (nonatomic) NSDictionary *interAdertisementData;

@end

NS_ASSUME_NONNULL_END
