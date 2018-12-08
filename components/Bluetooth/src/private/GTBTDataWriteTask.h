//
//  GTBTDataWriteTask.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTBTDataWriteTask : NSObject

@property (nullable, nonatomic, strong) NSData *pendingData; // data pending, need to be wrote
@property (nullable, nonatomic, copy) void(^responseBlock)(NSError *error);
@property (nonatomic) BOOL isWritting;
@property (nonatomic) NSUInteger maxLen;

@end

NS_ASSUME_NONNULL_END
