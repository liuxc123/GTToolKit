//
//  CBPeripheral+GTBLE.m
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import "CBPeripheral+GTBLE.h"
#import "GTBTCentralManager.h"
#import "GTBLPeripheralInterExtension.h"
#import "GTBTCentralManager+Private.h"
#import "ObjcExtensionProperty.h"
#import "GTBTDefines.h"



#define ERROR_BLOCK_INVOKE_AND_RETURN(error)     if(!self.centralManager && completion)  { \
completion(error); \
return; \
}

@implementation CBPeripheral (GTBLE)


__SETTER_PRIMITIVE(unsigned int, dataWritePakcetMaxLengthLimit,setDataWritePakcetMaxLengthLimit:,numberWithInt:)
__GETTER_PRIMITIVE_DEFAULT(unsigned int,dataWritePakcetMaxLengthLimit,125,intValue)


-(void)setCnnectionStateChangeBlock:(void (^)(CBPeripheral *peripheral))cnnectionStateChangeBlock {
    
    IMP key = class_getMethodImplementation([self class],@selector(cnnectionStateChangeBlock));
    objc_setAssociatedObject(self, key, cnnectionStateChangeBlock, OBJC_ASSOCIATION_RETAIN);
    
    [self.centralManager addDelegate:(id<GTBlePeripheralManagerDelegate>)self];
}

-(void (^)(CBPeripheral *peripheral))cnnectionStateChangeBlock {
    IMP key = class_getMethodImplementation([self class],@selector(cnnectionStateChangeBlock));
    return objc_getAssociatedObject(self, key);
}

-(int)rssiValue
{
    return self.interRssiValue;
}


-(NSDictionary *)advertisementData {
    return self.interAdertisementData;
}

#pragma mark-
-(void)centralManager:(GTBTCentralManager *)manager didChangeStateForPeripheral:(CBPeripheral *)peripheral {
    if(peripheral == self) {
        if(self.cnnectionStateChangeBlock)
            self.cnnectionStateChangeBlock(self);
    }
}


#pragma mark- discover
-(void)discoverService:(nullable NSArray <NSString *> *)serviceIDs
            completion:(nullable void (^)(NSError *error))completion {
    
    ERROR_BLOCK_INVOKE_AND_RETURN(NO_GTBTCENTRAL_ERROR);
    [self.centralManager discoverService:serviceIDs forPeripheral:self completion:completion];
}


-(void)discoverCharacteristics:(nullable NSArray <NSString *> *)charaterIDs
                     ofService:(nonnull NSString *)serviceID
                    completion:(nullable void (^)(NSError *error))completion {
    
    ERROR_BLOCK_INVOKE_AND_RETURN(NO_GTBTCENTRAL_ERROR);
    [self.centralManager discoverCharacteristics:charaterIDs ofService:serviceID forPeripheral:self completion:completion];
}


-(void)discoverDescriptorsForCharacteristic:(nonnull NSString *)charaterID
                                  ofService:(nonnull NSString *)serviceID
                                 completion:(nullable void (^)(NSError *error))completion {
    
    ERROR_BLOCK_INVOKE_AND_RETURN(NO_GTBTCENTRAL_ERROR);
    [self.centralManager discoverDescriptorsForCharacteristic:charaterID ofService:serviceID forPeripheral:self completion:completion];
    
}

-(void)discoverAllServicesCharacteristicsAndDescriptorsWithCompletion:(nullable void (^)(NSError *error))completion {
    
    ERROR_BLOCK_INVOKE_AND_RETURN(NO_GTBTCENTRAL_ERROR);
    WEAK_SELF;
    [self.centralManager discoverService:nil forPeripheral:self completion:^(NSError *error) {
        if(error && completion) {
            completion(error);
        }
        else {
            for(CBService *s in weakSelf.services) {
                [weakSelf.centralManager discoverCharacteristics:nil ofService:s.UUID.UUIDString forPeripheral:weakSelf completion:^(NSError *error) {
                    if(error) {
                        if(completion)
                            completion(error);
                    }
                    else {
                        for(CBCharacteristic *chra in s.characteristics) {
                            [weakSelf.centralManager discoverDescriptorsForCharacteristic:chra.UUID.UUIDString ofService:s.UUID.UUIDString forPeripheral:self completion:^(NSError *error) {
                                
                                if(error && completion) {
                                    completion(error);
                                }
                                else {
                                    
                                    BOOL allDiscoverFinished = YES;
                                    for(CBService *tSv in weakSelf.services)
                                    {
                                        if(!tSv.finishedSubArributeDiscover) {
                                            allDiscoverFinished = NO;
                                            break;
                                        }
                                        for(CBCharacteristic *tChara in tSv.characteristics)
                                        {
                                            if(!tChara.finishedSubArributeDiscover) {
                                                allDiscoverFinished = NO;
                                                break;
                                            }
                                        }
                                    }
                                    
                                    if(allDiscoverFinished)
                                        if(completion)
                                            completion(nil);
                                    
                                }
                            }];
                        }
                    }
                }];
            }
        }
    }];
    
}

#pragma mark- inter GTBTPort map

-(void)inter_findCharacteristicForPort:(GTBTPort *)port completion:(void (^)(NSError *error, CBCharacteristic *charateristic))completion {
    
    WEAK_SELF;
    CBCharacteristic *c = [self discoveredCharacteristicWithUUID:port.charateristicID ofService:port.serviceID];
    if(!c) {
        [weakSelf.centralManager discoverCharacteristics:@[port.charateristicID] ofService:port.serviceID forPeripheral:self completion:^(NSError *error) {
            if(completion) {
                
                if(error) {
                    completion(error,nil);
                }
                else {
                    CBCharacteristic *c1 = [self discoveredCharacteristicWithUUID:port.charateristicID ofService:port.serviceID];
                    if(c1) {
                        completion(nil,c1);
                    }
                    else {
                        completion(CHARAC_NOT_FOUND_ERROR(port.charateristicID,port.serviceID),nil);
                    }
                }
            }
        }];
    } else if(completion)  {
        completion(nil,c);
    }
}

-(void)inter_findDescriptorForPort:(GTBTPort *)port completion:(void (^)(NSError *error, CBDescriptor *descriptor))completion {
    
    CBDescriptor *desc = [self discoveredDescriptorWithUUID:port.descriptorID characteristicWithUUID:port.charateristicID ofService:port.serviceID];
    if(desc) {
        [self inter_findCharacteristicForPort:port completion:^(NSError *error, CBCharacteristic *charateristic) {
            if(completion) {
                if(error) {
                    completion(error,nil);
                } else {
                    CBDescriptor *desc1 = [self discoveredDescriptorWithUUID:port.descriptorID characteristicWithUUID:port.charateristicID ofService:port.serviceID];
                    if(desc1) {
                        completion(nil,desc1);
                    } else {
                        completion(DES_NOT_FOUND_ERROR(port.serviceID,port.charateristicID,port.descriptorID),nil);
                    }
                }
            }
        }];
    } else if(completion) {
        completion(nil,desc);
    }
}

#pragma mark- data transfer

-(void)writeData:(nonnull NSData *)data toPort:(GTBTPort *)port
{
    WEAK_SELF;
    [self inter_findCharacteristicForPort:port completion:^(NSError *error, CBCharacteristic *charateristic) {
        if(charateristic)
            [weakSelf.centralManager writeData:data forCharacteristic:charateristic];
    }];
}


/**
 write data to a GTBTPort with response
 向一个GTBTPort端口发送数据, 发送成功与否都在block回调得到结果
 */
-(void)writeData:(nonnull NSData *)data
          toPort:(GTBTPort *)port
      completion:(nullable void(^)(NSError *error))completion
{
    ERROR_BLOCK_INVOKE_AND_RETURN(NO_GTBTCENTRAL_ERROR);
    
    WEAK_SELF;
    if(port.descriptorID) {
        [self inter_findDescriptorForPort:port completion:^(NSError *error, CBDescriptor *descriptor) {
            if(descriptor) {
                [weakSelf.centralManager writeData:data forDescriptor:descriptor response:completion];
            }
            else if(completion)
                completion(error);
        }];
    }
    else {
        [self inter_findCharacteristicForPort:port completion:^(NSError *error, CBCharacteristic *charateristic) {
            if(charateristic)
                [weakSelf.centralManager writeData:data forCharacteristic:charateristic response:completion];
            else if(completion)
                completion(error);
        }];
    }
}


-(void)readDataFromPort:(GTBTPort *)port completion:(nullable void(^)(id value, NSError *error))completion
{
    if(!self.centralManager && completion)
        completion(nil,NO_GTBTCENTRAL_ERROR);
    
    WEAK_SELF;
    if(port.descriptorID) {
        [self inter_findDescriptorForPort:port completion:^(NSError *error, CBDescriptor *descriptor) {
            
            if(descriptor) {
                [weakSelf.centralManager readDataForDescriptor:descriptor completion:^(NSError *err) {
                    if(completion) {
                        completion(descriptor.value,err);
                    }
                }];
            }
            else if(completion)
                completion(nil,error);
            
        }];
        
    } else {
        [self inter_findCharacteristicForPort:port completion:^(NSError *error, CBCharacteristic *charateristic) {
            if(charateristic) {
                [weakSelf.centralManager readDataforCharacteristic:charateristic completion:^(NSError *err) {
                    if(completion) {
                        completion(charateristic.value,err);
                    }
                }];
            } else if(completion)
                completion(nil,error);
        }];
    }
    
}


-(void)setOnDataNotifyBlock:(void(^)(GTBTPort *port, NSData *data))block forPort:(GTBTPort *)port
{
    WEAK_SELF;
    if(port) {
        [self inter_findCharacteristicForPort:port completion:^(NSError *error, CBCharacteristic *charateristic) {
            if(!error && charateristic) {
                if(block) {
                    [weakSelf.centralManager setDataNotifyBlock:^(CBCharacteristic *characteristic) {
                        block(port, charateristic.value);
                    } forCharacteristic:charateristic];
                }
                else {
                    [weakSelf.centralManager setDataNotifyBlock:nil forCharacteristic:charateristic];
                }
                
            }
        }];
    }
    else {
        if(block) {
            [self.centralManager setDataNotifyBlock:^(CBCharacteristic *characteristic) {
                GTBTPort *port = [GTBTPort portWithServiceID:characteristic.service.UUID.UUIDString characteristicID:characteristic.UUID.UUIDString];
                block(port,characteristic.value);
            } forPeripheral:self];
        }
        else {
            [self.centralManager setDataNotifyBlock:nil forPeripheral:self];
        }
    }
}


-(void)enableNotify:(BOOL)enable forPort:(GTBTPort *)port completion:(void(^)(NSError *))completion
{
    ERROR_BLOCK_INVOKE_AND_RETURN(NO_GTBTCENTRAL_ERROR);
    
    WEAK_SELF;
    [self inter_findCharacteristicForPort:port completion:^(NSError *error, CBCharacteristic *charateristic) {
        if(completion) {
            if(charateristic)
                [weakSelf.centralManager enableNotify:enable forCharacteristic:charateristic completion:completion];
            else
                completion(error);
        }
    }];
}

#pragma mark-
-(void)readRssiWithCompletion:(nullable void (^)(int rssi, NSError *error))completion {
    
    if(completion && !self.centralManager)
        completion(0,NO_GTBTCENTRAL_ERROR);
    
    [self.centralManager readRSSIForPeripheral:self completion:completion];
}

#pragma mark-

-(nullable CBDescriptor *)discoveredDescriptorWithUUID:(nonnull NSString *)descriptorUUIDString
                                characteristicWithUUID:(nonnull NSString *)characteristicUUIDString
                                             ofService:(nonnull NSString *)serviceUUIDString
{
    CBDescriptor *retDesc = nil;
    CBCharacteristic *charc = [self discoveredCharacteristicWithUUID:characteristicUUIDString ofService:serviceUUIDString];
    if(charc)
    {
        for(CBDescriptor *desc in charc.descriptors)
        {
            if([desc.UUID.UUIDString isEqualToString:descriptorUUIDString])
            {
                retDesc = desc;
                break;
            }
        }
    }
    
    return retDesc;
}

-(nullable CBCharacteristic *)discoveredCharacteristicWithUUID:(nonnull NSString *)characteristicUUIDString
                                                     ofService:(nonnull NSString *)serviceUUIDString
{
    CBCharacteristic *chara = nil;
    CBService *service = [self discoveredServiceWithUUID:serviceUUIDString];
    if(service)
    {
        if([service.UUID.UUIDString isEqualToString:serviceUUIDString])
        {
            for (CBCharacteristic *chra in service.characteristics)
            {
                if([chra.UUID.UUIDString isEqualToString:characteristicUUIDString])
                {
                    chara = chra;
                    break;
                }
            }
        }
    }
    
    return chara;
}

-(nullable CBService *)discoveredServiceWithUUID:(NSString *)serviceUUID
{
    CBService *tService = nil;
    for(CBService *s in self.services)
    {
        if([s.UUID.UUIDString isEqualToString:serviceUUID])
        {
            tService = s;
            break;
        }
    }
    return tService;
}




@end


@implementation CBCharacteristic (GTBLE)

-(NSString *)propertiesDescription
{
    return self.interPropertiesDescription;
}

@end
