//
//  GTBLPeripheralInterExtension.m
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import "GTBLPeripheralInterExtension.h"
#import "ObjcExtensionProperty.h"

@class GTBTCentralManager;
@implementation CBAttribute (GTBLInternal)

__SETTER_PRIMITIVE(BOOL, finishedSubArributeDiscover, setFinishedSubArributeDiscover:, numberWithBool:)
__GETTER_PRIMITIVE(BOOL, finishedSubArributeDiscover, boolValue)

__SETTER(interPropertiesDescription, setInterPropertiesDescription:, OBJC_ASSOCIATION_COPY)
__GETTER(NSString, interPropertiesDescription)

@end


@implementation CBPeripheral (GTBLInternal)


__SETTER_PRIMITIVE(int, interRssiValue, setInterRssiValue:, numberWithInt:)
__GETTER_PRIMITIVE(int, interRssiValue, intValue)

__SETTER_WEAK_CUSTOMIZE(centralManager, setCentralManager:)
__GETTER_WEAK(GTBTCentralManager, centralManager)


__SETTER(interAdertisementData, setInterAdertisementData:, OBJC_ASSOCIATION_RETAIN)
__GETTER(NSDictionary, interAdertisementData)

@end
