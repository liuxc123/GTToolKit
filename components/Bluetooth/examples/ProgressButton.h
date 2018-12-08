//
//  ProgressButton.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define UIControlStateInProgress (UIControlStateSelected<<1)

@interface ProgressButton : UIButton

@property (nonatomic) BOOL inProgress;

@property(nonatomic) UIActivityIndicatorViewStyle activityIndicatorViewStyle;

@end

NS_ASSUME_NONNULL_END
