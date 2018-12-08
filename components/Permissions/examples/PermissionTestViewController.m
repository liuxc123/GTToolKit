//
//  PermissionTestViewController.m
//  LBXKit
//
//  Created by lbx on 2017/10/30.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "PermissionTestViewController.h"
#import "GTPermission.h"
#import "GTPermissionSetting.h"
#import "GTPermissionNet.h"

@interface PermissionTestViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *photoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *cameraSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *locationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *contactSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *reminderSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *calendarSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *healthSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *audioSwitch;

//健康提示
@property (weak, nonatomic) IBOutlet UILabel *labelHealthTip;

//定位提示
@property (weak, nonatomic) IBOutlet UILabel *labelLocationService;

//网络状态
@property (weak, nonatomic) IBOutlet UILabel *labelNetStatus;
//网络权限
@property (weak, nonatomic) IBOutlet UILabel *labelNetPermission;

@end

@implementation PermissionTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"权限获取测试";
    
    //健康需要 TARGETS ->Capabilities -> HealthKit里面设置
    if ([GTPermission isDeviceSupportedWithType:GTPermissionTypeHealth]) {
        _labelHealthTip.text = @"设备支持HealthKit";
    }
    else{
        _labelHealthTip.text = @"设备不支持HealthKit";
    }
    
    [self addAllTargets];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addAllTargets) name:@"refresh" object:nil];
    
    
    [self netPermissionlisten];
  
}

- (void)swithValueChange:(id)sender
{
    //取消所有switch的值变化监听
    [self clearAllTargets];

    
    UISwitch *_switch = sender;
    if (sender == _photoSwitch)
    {
        //相册
        [GTPermission authorizeWithType:GTPermissionTypePhotos completion:^(BOOL granted, BOOL firstTime) {
            
            _switch.on = granted;
            [self handCompletionWithGranted:granted firstTime:firstTime];
        }];
    }
    else if (sender == _cameraSwitch)
    {
        //相机
        [GTPermission authorizeWithType:GTPermissionTypeCamera completion:^(BOOL granted, BOOL firstTime) {
           
            _switch.on = granted;
            [self handCompletionWithGranted:granted firstTime:firstTime];
        }];
    }
    else if (sender == _locationSwitch)
    {
        if (![GTPermission isServicesEnabledWithType:GTPermissionTypeLocation])
        {
            //系统定位权限未开启
            _switch.on = NO;
            
            //增加所有switch的值变化监听
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self addAllTargets];
            });
            return;
        }
        
        //定位,模拟器不准确
        [GTPermission authorizeWithType:GTPermissionTypeLocation completion:^(BOOL granted, BOOL firstTime) {
            
            _switch.on = granted;
            [self handCompletionWithGranted:granted firstTime:firstTime];
        }];
      
    }
    else if (sender == _contactSwitch)
    {
        //通讯录
        [GTPermission authorizeWithType:GTPermissionTypeContacts completion:^(BOOL granted, BOOL firstTime) {
            
            _switch.on = granted;
            [self handCompletionWithGranted:granted firstTime:firstTime];
        }];
    }
    else if (sender == _reminderSwitch)
    {
        //提醒
        [GTPermission authorizeWithType:GTPermissionTypeReminders completion:^(BOOL granted, BOOL firstTime) {
           
            _switch.on = granted;
            [self handCompletionWithGranted:granted firstTime:firstTime];
        }];
    }
    else if (sender == _calendarSwitch)
    {
        //日历
        [GTPermission authorizeWithType:GTPermissionTypeCalendar completion:^(BOOL granted, BOOL firstTime) {
            
            _switch.on = granted;
            [self handCompletionWithGranted:granted firstTime:firstTime];
        }];
    }
    else if (sender == _healthSwitch)
    {
        //健康,需要相关配置
        [GTPermission authorizeWithType:GTPermissionTypeHealth completion:^(BOOL granted, BOOL firstTime) {
            
            _switch.on = granted;
            [self handCompletionWithGranted:granted firstTime:firstTime];
        }];
    }
    else if (sender == _audioSwitch)
    {
        //麦克风,模拟器不准确
        [GTPermission authorizeWithType:GTPermissionTypeMicrophone completion:^(BOOL granted, BOOL firstTime) {

            _switch.on = granted;
            [self handCompletionWithGranted:granted firstTime:firstTime];
        }];
    }
}

- (void)handCompletionWithGranted:(BOOL)granted firstTime:(BOOL)firstTime
{
    //没有权限，且不是第一次获取权限
    if ( !granted && !firstTime )
    {
        [GTPermissionSetting showAlertToDislayPrivacySettingWithTitle:@"提示" msg:@"没有 xxx 权限，是否前往设置" cancel:@"取消" setting:@"设置"];
    }
    
    
    //增加所有switch的值变化监听
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self addAllTargets];
        
    });
    
    
    
}

- (void)testCode
{
    //相机
    [GTPermission authorizeWithType:GTPermissionTypeCamera completion:^(BOOL granted, BOOL firstTime) {
     
        if (granted) {
            //TODO
            //dosth
        }
        else if (!firstTime)
        {
            //不是第一次请求权限，那么可以弹出权限提示，用户选择设置，即跳转到设置界面，设置权限
             [GTPermissionSetting showAlertToDislayPrivacySettingWithTitle:@"提示" msg:@"没有相机权限，是否前往设置" cancel:@"取消" setting:@"设置"];
        }
    }];
    
    
    //定位
    [GTPermission authorizeWithType:GTPermissionTypeLocation completion:^(BOOL granted, BOOL firstTime) {
        
        if (granted) {
            //TODO
            //dosth
        }
        else if (!firstTime)
        {
            //不是第一次请求权限，那么可以弹出权限提示，用户选择设置，即跳转到设置界面，设置权限
            [GTPermissionSetting showAlertToDislayPrivacySettingWithTitle:@"提示" msg:@"没有定位权限，是否前往设置" cancel:@"取消" setting:@"设置"];
        }
    }];
}


- (void)addAllTargets
{
    [self refreshStatus];
    
    [_photoSwitch addTarget:self action:@selector(swithValueChange:) forControlEvents:UIControlEventValueChanged];
    [_cameraSwitch addTarget:self action:@selector(swithValueChange:) forControlEvents:UIControlEventValueChanged];
    [_locationSwitch addTarget:self action:@selector(swithValueChange:) forControlEvents:UIControlEventValueChanged];
    [_contactSwitch addTarget:self action:@selector(swithValueChange:) forControlEvents:UIControlEventValueChanged];
    
    [_reminderSwitch addTarget:self action:@selector(swithValueChange:) forControlEvents:UIControlEventValueChanged];
    [_calendarSwitch addTarget:self action:@selector(swithValueChange:) forControlEvents:UIControlEventValueChanged];
    [_healthSwitch addTarget:self action:@selector(swithValueChange:) forControlEvents:UIControlEventValueChanged];
    [_audioSwitch addTarget:self action:@selector(swithValueChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)clearAllTargets
{
    
    [_photoSwitch removeTarget:self action:@selector(swithValueChange:) forControlEvents:UIControlEventValueChanged];
    [_cameraSwitch removeTarget:self action:@selector(swithValueChange:) forControlEvents:UIControlEventValueChanged];
    [_locationSwitch removeTarget:self action:@selector(swithValueChange:) forControlEvents:UIControlEventValueChanged];
    [_contactSwitch removeTarget:self action:@selector(swithValueChange:) forControlEvents:UIControlEventValueChanged];
    
    [_reminderSwitch removeTarget:self action:@selector(swithValueChange:) forControlEvents:UIControlEventValueChanged];
    [_calendarSwitch removeTarget:self action:@selector(swithValueChange:) forControlEvents:UIControlEventValueChanged];
    [_healthSwitch removeTarget:self action:@selector(swithValueChange:) forControlEvents:UIControlEventValueChanged];
    [_audioSwitch removeTarget:self action:@selector(swithValueChange:) forControlEvents:UIControlEventValueChanged];
}


- (void)refreshStatus
{
    _photoSwitch.on     = [GTPermission authorizedWithType:GTPermissionTypePhotos];
    _cameraSwitch.on    = [GTPermission authorizedWithType:GTPermissionTypeCamera];
    _locationSwitch.on  = [GTPermission authorizedWithType:GTPermissionTypeLocation];
    _contactSwitch.on   = [GTPermission authorizedWithType:GTPermissionTypeContacts];
    _reminderSwitch.on  = [GTPermission authorizedWithType:GTPermissionTypeReminders];
    _calendarSwitch.on  = [GTPermission authorizedWithType:GTPermissionTypeCalendar];
    _healthSwitch.on    = [GTPermission authorizedWithType:GTPermissionTypeHealth];
    _audioSwitch.on     = [GTPermission authorizedWithType:GTPermissionTypeMicrophone];
    
    _labelLocationService.text = [GTPermission isServicesEnabledWithType:GTPermissionTypeLocation]? @"系统服务开启":@"系统服务未开启";
    
    _photoSwitch.enabled = !_photoSwitch.on;
    _cameraSwitch.enabled = !_cameraSwitch.on;
    _locationSwitch.enabled = !_locationSwitch.on;
    _contactSwitch.enabled = !_contactSwitch.on;
    _reminderSwitch.enabled = !_reminderSwitch.on;
    _calendarSwitch.enabled = !_calendarSwitch.on;
    _healthSwitch.enabled = !_healthSwitch.on;
    _audioSwitch.enabled = !_audioSwitch.on;
}

#pragma mark- 网络权限设置
- (void)netPermissionlisten
{
    __weak __typeof(self) weakSelf = self;
    
    NSString *hostName = @"www.baidu.com";//or @"202.108.22.5"
    [[GTPermissionNet sharedManager]startListenNetWithHostName:hostName onNetStatus:^(NetReachWorkStatus netStatus) {
        
        NSLog(@"netstatus:%ld",netStatus);
        NSString *strNetStatus = @"";
        switch (netStatus) {
            case NetReachWorkNotReachable:
                NSLog(@"网络不可用");
                strNetStatus = @"网络不可用";
                break;
            case NetReachWorkStatusUnknown:
                NSLog(@"未知网络");
                strNetStatus = @"未知网络";
                break;
            case NetReachWorkStatusWWAN2G:
                NSLog(@"2G网络");
                strNetStatus = @"2G网络";
                break;
            case NetReachWorkStatusWWAN3G:
                strNetStatus = @"3G网络";
                break;
            case NetReachWorkStatusWWAN4G:
                NSLog(@"4G网络");
                strNetStatus = @"4G网络";
                break;
            case NetReachWorkStatusWiFi:
                NSLog(@"WiFi");
                strNetStatus = @"WiFi";
                break;
            default:
                break;
        }
        
        __strong __typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.labelNetStatus.text = strNetStatus;
        }
        
    } onNetPermission:^(BOOL granted) {
        
        __strong __typeof(self) strongSelf = weakSelf;
        strongSelf.labelNetPermission.text = granted ? @"有网络权限" : @"可能没有网络权限";
    }];
}

+ (NSDictionary *)catalogMetadata
{
    return @{
             @"breadcrumbs": @[@"Permissions"],
             @"primaryDemo": @YES,
             @"presentable": @YES,
             };
}

@end
