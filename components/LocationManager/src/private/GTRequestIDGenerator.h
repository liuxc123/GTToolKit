//
//  GTRequestIDGenerator.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/3.
//

#import "GTLocationRequestDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface GTRequestIDGenerator : NSObject

/**
 Returns a unique request ID (within the lifetime of the application).
 */
+(GTLocationRequestID)getUniqueRequestID;

@end

NS_ASSUME_NONNULL_END
