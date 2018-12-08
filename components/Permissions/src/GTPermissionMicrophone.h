//
//  GTPermissionMicrophone.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTPermissionMicrophone : NSObject

+ (BOOL)authorized;

/**
 permission status
 
 0 ：AVAudioSessionRecordPermissionUndetermined
 1 ：AVAudioSessionRecordPermissionDenied
 2 ：AVAudioSessionRecordPermissionGranted
 
 @return status
 */
+ (NSInteger)authorizationStatus;

+ (void)authorizeWithCompletion:(void(^)(BOOL granted,BOOL firstTime))completion;

@end

NS_ASSUME_NONNULL_END
