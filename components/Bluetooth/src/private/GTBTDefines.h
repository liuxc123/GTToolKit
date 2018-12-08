//
//  GTBTDefines.h
//  Pods
//
//  Created by liuxc on 2018/12/8.
//

#ifndef GTBTDefines_h
#define GTBTDefines_h

//--error define---

#define SCAN_START_ERROR(msg,info) [NSError errorWithDomain:msg code:-700 userInfo:info]

#define PERIPHERAL_DISCONNECTED_ERROR [NSError errorWithDomain:@"peripheral is disconnected" code:-701 userInfo:nil]
#define PERIPHERAL_DISCONNECING_ERROR [NSError errorWithDomain:@"peripheral is disconnecting" code:-702 userInfo:nil]

#define SERVICE_NOT_FOUND_ERROR(serviceID) [NSError errorWithDomain:[NSString stringWithFormat:@"service of %@ uuid not found",serviceID] code:-710 userInfo:nil]

#define CHARAC_NOT_FOUND_ERROR(serviceID,charaterID)  [NSError errorWithDomain:[NSString stringWithFormat:NSLocalizedString(@"The characteris with uuid %@ in service %@ not found ", nil),charaterID,serviceID] code:-712 userInfo:nil]

#define DES_NOT_FOUND_ERROR(serviceID,charaterID,descriptorID)  [NSError errorWithDomain:[NSString stringWithFormat:NSLocalizedString(@"The descriptor with uuid %@ in characteris %@ of service %@ not found ", nil),descriptorID,charaterID,serviceID] code:-713 userInfo:nil]

#define NO_GTBTCENTRAL_ERROR [NSError errorWithDomain:NSLocalizedString(@"The peripheral is not discovered from a GTBTCentralManager instance", nil) code:-720 userInfo:nil]

#define GTBT_UNKNOW_ERROR [NSError errorWithDomain:@"unknown" code:-799 userInfo:nil]

//-----end----

#ifndef WEAK_SELF
#define WEAK_SELF __weak typeof(self) weakSelf = self
#endif


#endif /* GTBTDefines_h */
