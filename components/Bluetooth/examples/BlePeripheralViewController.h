//
//  BlePeripheralViewController.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import <UIKit/UIKit.h>
#import "GTBTCentralManager.h"
#import "CBPeripheral+GTBLE.h"

NS_ASSUME_NONNULL_BEGIN

@interface BlePeripheralViewController : UITableViewController

-(instancetype)initWithPeripheral:(CBPeripheral *)per andManager:(GTBTCentralManager *)manager;

@end

NS_ASSUME_NONNULL_END
