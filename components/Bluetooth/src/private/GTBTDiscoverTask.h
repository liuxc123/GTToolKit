//
//  GTBTDiscoverTask.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTBTDiscoverTask : NSObject

@property (nonatomic, copy) void (^block)(NSError *error);
@property (nonatomic, copy) NSArray <NSString *> *discoverIDs;

@end

NS_ASSUME_NONNULL_END
