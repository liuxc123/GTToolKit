//
//  GTMASearchRequestIDGenerator.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/5.
//

#import <Foundation/Foundation.h>
#import "MAMapSearchManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface GTMASearchRequestIDGenerator : NSObject

/**
 Returns a unique request ID (within the lifetime of the application).
 */
+(GTMAMapSearchRequestID)getUniqueRequestID;

@end

NS_ASSUME_NONNULL_END
