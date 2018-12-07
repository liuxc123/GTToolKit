//
//  GTNaviManager.m
//  GTNavigationTest
//
//  Created by zhi'qiang 冯 on 2018/12/4.
//  Copyright © 2018 zhi'qiang 冯. All rights reserved.
//

#import "MANaviManager.h"
#import "SpeechSynthesizer.h"
#import "MANaviViewController.h"
#import "MoreMenuView.h"


@interface MANaviManager()<AMapNaviWalkManagerDelegate,AMapNaviWalkViewDelegate,AMapNaviWalkDataRepresentable,AMapNaviDriveManagerDelegate,AMapNaviDriveDataRepresentable,AMapNaviDriveViewDelegate,MoreMenuViewDelegate>

//导航页面
@property (nonatomic,strong) MANaviViewController * maNaviController;
//地图页面
@property (nonatomic,strong) MAMapView *mapView;
//导航信息
@property (nonatomic,strong) AMapNaviInfo * naviInfo;
//剩余距离
@property (nonatomic,assign) double  routeRemainDistance;
//剩余时间
@property (nonatomic,assign) double  routeRemainTime;
//驾车管理类
@property (nonatomic,strong) AMapNaviDriveManager * naviManager;
//步行
@property (nonatomic,strong) AMapNaviWalkManager * walkManager;

//驾车导航视图
@property (nonatomic,strong)AMapNaviDriveView *driveView;
//步行导航视图
@property (nonatomic,strong)AMapNaviWalkView * walkView;
//导航起点
@property (nonatomic,strong)AMapNaviPoint *startPoint;
//导航终点
@property (nonatomic,strong)AMapNaviPoint *endPoint;
//规划成功回调
@property (nonatomic,assign) CalcuateSuccessBlock calcuateSuccessBlock;
//导航菜单按钮
@property (nonatomic,strong) MoreMenuView *menuView;

@end

@implementation MANaviManager

#pragma Mark - 单例
+(instancetype)sharedManager{
    static MANaviManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //初始化单例对象
        manager = [[MANaviManager alloc]init];
    });
    return manager;
}
//驾车导航管理类
-(void)initDriveNavi{
    if (self.naviManager == nil) {
        self.naviManager = [AMapNaviDriveManager sharedInstance];
        self.naviManager.delegate = self;
    }
}
//步行导航管理类
-(void)initWalkNavi{
    if (self.walkManager == nil){
        self.walkManager = [[AMapNaviWalkManager alloc]init];
        self.walkManager.delegate =self;
    }
}
//初始化导航菜单按键
-(void)initMoreMenu{
    if (self.menuView == nil){
        self.menuView = [[MoreMenuView alloc]init];
        self.menuView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;;
        self.menuView.delegate = self;
    }
}


//开始步行导航
-(void)startWalkNaviStartLocation:(AMapNaviPoint * )startLocation endLocation:(AMapNaviPoint *  )endLocation calcuateSuccessBlock:(CalcuateSuccessBlock) calcuateSuccessBlock{
    self.calcuateSuccessBlock = calcuateSuccessBlock;
    self.maNaviController.navigationController.navigationBar.hidden = YES;
 
    [self initWalkNavi];
    self.walkView = [[AMapNaviWalkView alloc]init];
    self.walkView.delegate =self;

    [self.walkManager addDataRepresentative:self.walkView];
    [self.walkManager calculateWalkRouteWithStartPoints:@[startLocation] endPoints:@[endLocation]];
    
}

//开始驾车导航
-(void)startDriverNaviStartLocation:(AMapNaviPoint *)startLocation endLocation:(AMapNaviPoint *)endLocation wayLocations:(NSArray<AMapNaviPoint*> *)wayLocations calcuateSuccessBlock:(CalcuateSuccessBlock) calcuateSuccessBlock{
    
    self.calcuateSuccessBlock = calcuateSuccessBlock;
    self.maNaviController.navigationController.navigationBar.hidden = YES;
  
    [self initDriveNavi];
    self.driveView = [[AMapNaviDriveView alloc]init];
    self.driveView.delegate =self;
    [self.naviManager addDataRepresentative:self.driveView];
    [self.naviManager calculateDriveRouteWithStartPoints:@[startLocation] endPoints:@[endLocation] wayPoints:wayLocations drivingStrategy:AMapNaviDrivingStrategySingleDefault];
}

//展示导航页面
-(void)showNaviController{
    
    self.maNaviController = [[MANaviViewController alloc]init];
    if (self.walkView){
        self.walkView.frame = UIScreen.mainScreen.bounds;
        self.driveView.showMoreButton = NO;
        [self.maNaviController.view addSubview:self.walkView];
    }
    
    if(self.driveView){
        self.driveView.frame = UIScreen.mainScreen.bounds;
        [self initMoreMenu];
        [self.maNaviController.view addSubview:self.driveView];
    }
    [[MANaviViewController getCurrentUIVC] presentViewController:self.maNaviController animated:YES completion:nil];

}


//驾车回调
-(void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager{
    [self.naviManager addDataRepresentative:self.driveView];
    [driveManager startGPSNavi];
    if(self.calcuateSuccessBlock){
        self.calcuateSuccessBlock();
    }
    [self showNaviController];
}

//步行回调
-(void)walkManagerOnCalculateRouteSuccess:(AMapNaviWalkManager *)walkManager{
    [self.walkManager addDataRepresentative:self.walkView];
    [walkManager startGPSNavi];
    if(self.calcuateSuccessBlock){
        self.calcuateSuccessBlock();
    }
    [self showNaviController];
}

//停止驾车导航
-(void)driveViewCloseButtonClicked:(AMapNaviDriveView *)driveView{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:@"是否退出导航" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.maNaviController.navigationController.navigationBar.hidden = NO;
        [self.naviManager stopNavi];
        [driveView removeFromSuperview];
        __block typeof(self) weakself = self;
        [self.maNaviController dismissViewControllerAnimated:YES completion:^{
            weakself.driveView = nil;
            weakself.menuView = nil;
            weakself.maNaviController = nil;
        }];
        //停止语音
        [[SpeechSynthesizer sharedSpeechSynthesizer]stopSpeak];
    }];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        return ;
    }];
    
    [alert addAction:sureAction];
    [alert addAction:cancelAction];
    [[MANaviViewController getCurrentUIVC] presentViewController:alert animated:YES completion:nil];
}

//停止步行导航
-(void)walkViewCloseButtonClicked:(AMapNaviWalkView *)walkView{
    
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:@"是否退出导航" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.maNaviController.navigationController.navigationBar.hidden = NO;
        [self.walkManager stopNavi];
        [walkView removeFromSuperview];
        __block typeof(self) weakself = self;
        [self.maNaviController dismissViewControllerAnimated:YES completion:^{
            weakself.walkView = nil;
            weakself.menuView = nil;
            weakself.maNaviController = nil;
        }];
        //停止语音
        [[SpeechSynthesizer sharedSpeechSynthesizer]stopSpeak];
    }];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        return ;
    }];
    
    [alert addAction:sureAction];
    [alert addAction:cancelAction];
    [[MANaviViewController getCurrentUIVC] presentViewController:alert animated:YES completion:nil];
}
//配置导航按钮
-(void)driveViewMoreButtonClicked:(AMapNaviDriveView *)driveView{
    //配置MoreMenu状态
    [self.menuView setTrackingMode:self.driveView.trackingMode];
    [self.menuView setShowNightType:self.driveView.showStandardNightType];
    
    [self.menuView setFrame:self.maNaviController.view.bounds];
    [self.maNaviController.view addSubview:self.menuView];
}
- (void)driveViewTrunIndicatorViewTapped:(AMapNaviDriveView *)driveView
{
    if (self.driveView.showMode == AMapNaviDriveViewShowModeCarPositionLocked)
    {
        [self.driveView setShowMode:AMapNaviDriveViewShowModeNormal];
    }
    else if (self.driveView.showMode == AMapNaviDriveViewShowModeNormal)
    {
        [self.driveView setShowMode:AMapNaviDriveViewShowModeOverview];
    }
    else if (self.driveView.showMode == AMapNaviDriveViewShowModeOverview)
    {
        [self.driveView setShowMode:AMapNaviDriveViewShowModeCarPositionLocked];
    }
}


//语音播放Delegate
-(BOOL)driveManagerIsNaviSoundPlaying:(AMapNaviDriveManager *)driveManager{
    return [[SpeechSynthesizer sharedSpeechSynthesizer]isSpeaking];
}

-(void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType{
    [[SpeechSynthesizer sharedSpeechSynthesizer]speakString:soundString];
}

-(void)walkManager:(AMapNaviWalkManager *)walkManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType{
    [[SpeechSynthesizer sharedSpeechSynthesizer]speakString:soundString];
}

-(void)thirdPartyNaviStartLocation:(CLLocationCoordinate2D)startLocation EndLocation:(CLLocationCoordinate2D)endLocation{
    
}
#pragma Mark --------MoreMenu Delegate
-(void)moreMenuViewFinishButtonClicked{
    [self.menuView removeFromSuperview];
}
- (void)moreMenuViewNightTypeChangeTo:(BOOL)isShowNightType
{
    [self.driveView setShowStandardNightType:isShowNightType];
}
- (void)moreMenuViewTrackingModeChangeTo:(AMapNaviViewTrackingMode)trackingMode
{
    [self.driveView setTrackingMode:trackingMode];
}
@end




