//
//  GTLocationManager.h
//  GTCatalog
//
//  Created by liuxc on 2018/12/3.
//

#import "GTLocationRequestDefine.h"

NS_ASSUME_NONNULL_BEGIN

/**
 CLLocationManager的抽象，它提供了一个基于块的异步API来获取设备的位置。
 GTLocationManager根据需要自动启动和停止系统定位服务，以最小化电池消耗。
 */
@interface GTLocationManager : NSObject

/** 根据系统设置和用户授权状态，返回此应用程序的位置服务的当前状态。*/
+ (GTLocationServicesState)locationServicesState;

/** 返回此设备的朝向服务的当前状态。 */
+ (GTHeadingServicesState)headingServicesState;

/** 单例 */
+ (instancetype)sharedInstance;

/** 授权状态 */
@property (nonatomic, assign) GTAuthorizationType preferredAuthorizationType;

#pragma mark Location Requests

/**
 使用位置服务异步请求设备的当前位置。

 @param desiredAccuracy 所需的精度水平(指位置的精度和近况)。
 @param timeout 完成前等待具有所需精度的位置的最长时间(以秒为单位)。如果该值为0.0，不会设置超时(将无限期等待成功，除非强制完成或取消请求)。
 @param block 在成功、失败或超时时执行的回调
 @return 定位 requestID
 */
- (GTLocationRequestID)requestLocationWithDesiredAccuracy:(GTLocationAccuracy)desiredAccuracy
                                                    timeout:(NSTimeInterval)timeout
                                                      block:(GTLocationRequestBlock)block;


/**
 使用定位服务异步请求设备的当前位置，可以选择延迟超时倒计时，直到用户完成响应请求此应用程序访问位置服务权限的对话框。

 @param desiredAccuracy 所需的精度水平(指位置的精度和近况)。
 @param timeout 完成前等待具有所需精度的位置的最长时间(以秒为单位)。如果该值为0.0，不会设置超时(将无限期等待成功，除非强制完成或取消请求)。
 @param delayUntilAuthorized 指定超时是否应该在用户响应系统提示符请求后才生效的标志此应用程序访问位置服务的权限。如果是，超时倒计时将在app接收位置服务权限。如果没有，则在调用此方法时立即开始超时倒计时。
 @param block 在成功、失败或超时时执行的回调
 @return 定位 requestID
 */
- (GTLocationRequestID)requestLocationWithDesiredAccuracy:(GTLocationAccuracy)desiredAccuracy
                                                    timeout:(NSTimeInterval)timeout
                                       delayUntilAuthorized:(BOOL)delayUntilAuthorized
                                                      block:(GTLocationRequestBlock)block;

/**
 为位置更新创建订阅，该订阅将无限期地(直到取消)执行每个更新一次的块，而不管每个位置的准确性如何。
 此方法指示位置服务使用可用的最高精度(这也需要最大的功率)。
 如果发生错误，块将以GTLocationStatusSuccess以外的状态执行，订阅将自动取消。

 @param block 每次更新位置可用时要执行的Block
 @return 定位 requestID
 */
- (GTLocationRequestID)subscribeToLocationUpdatesWithBlock:(GTLocationRequestBlock)block;

/**
 为位置更新创建订阅，该订阅将无限期地(直到取消)执行每个更新一次的block，而不管每个位置的准确性如何。
 指定的期望精度被传递到位置服务，并控制使用多少功率，使用更多的功率获得更高的精度。
 如果发生错误，块将以GTLocationStatusSuccess以外的状态执行，订阅将自动取消。

 @param desiredAccuracy 所需的精度水平，控制设备的定位服务使用多少功率。
 @param block           每次更新位置可用时要执行的block。请注意，这个块在每次更新时都运行，不管更新是什么所获得的精度是否至少是所期望的精度。除非发生错误，否则状态为GTLocationStatusSuccess;它永远不会被GTLocationStatusTimedOut。

 @return 定位 request ID, 可用于取消订阅此block的位置更新。
 */
- (GTLocationRequestID)subscribeToLocationUpdatesWithDesiredAccuracy:(GTLocationAccuracy)desiredAccuracy
                                                                 block:(GTLocationRequestBlock)block;

/**
 为重大位置更改创建订阅，这些更改将无限期地(直到取消)每次更改执行一次block。如果发生错误，块将以GTLocationStatusSuccess以外的状态执行，订阅将自动取消。

 @param block 每次更新位置可用时要执行的块。除非发生错误，否则状态为GTLocationStatusSuccess;它永远不会被GTLocationStatusTimedOut。

 @return 定位 request ID, 可用于取消订阅此block的位置更新。
 */
- (GTLocationRequestID)subscribeToSignificantLocationChangesWithBlock:(GTLocationRequestBlock)block;

/** 立即强制使用给定的requestID完成位置请求(如果存在)，并使用结果执行原始请求块。
 对于一次性的位置请求，这实际上是一个手动超时，将导致请求以GTLocationStatusTimedOut状态完成。
 如果requestID对应于订阅，则订阅将被简单地取消。 */
- (void)forceCompleteLocationRequest:(GTLocationRequestID)requestID;

/** 在不执行原始请求块的情况下，立即用给定的requestID(如果存在)取消位置请求(或订阅)。 */
- (void)cancelLocationRequest:(GTLocationRequestID)requestID;

#pragma mark Heading Requests

/**
 创建朝向更新订阅，假设标题更新超出标题筛选器阈值，该订阅将无限期地(直到取消)执行每个更新一次的block。
 如果发生错误，块将以GTHeadingStatusSuccess以外的状态执行，订阅将自动取消。

 @param block 每次更新的朝向可用时要执行的block。除非发生错误，否则状态将为GTHeadingStatusSuccess。

 @return  heading request ID, 可用于取消订阅此块的标题更新。
 */
- (GTHeadingRequestID)subscribeToHeadingUpdatesWithBlock:(GTHeadingRequestBlock)block;

/** 立即用给定的requestID取消标题订阅请求(如果存在)，而不执行原始请求块。 */
- (void)cancelHeadingRequest:(GTHeadingRequestID)requestID;

#pragma mark Geocode Requests

/**
 请求逆地理编码

 @param block 完成请求的要执行的block
 @return 逆地理编码请求ID
 */
- (GTGeocoderRequestID)requestGeocoderWithLocation:(CLLocation *)location block:(GTGeocoderRequestBlock)block;

/** 立即用给定的requestID取消标题订阅请求(如果存在)，而不执行原始请求块。 */
- (void)cancelGeocoderRequest:(GTGeocoderRequestID)requestID;


#pragma mark - Additions

/** 如果您设置了任何类型的授权，也可以强制启用后台位置获取 */
- (void)setBackgroundLocationUpdate:(BOOL) enabled;

/**
 设置一个布尔值，指示位置服务时状态栏是否更改其外观，都是在后台使用的。

 此属性只影响始终接收到授权的应用程序。当这样一个应用程序移动到后台时，系统使用此属性来确定是否更改状态栏外观以指示位置服务正在使用中。显示修改后的状态栏可以让用户快速返回到应用程序。 此属性的默认值为false。 对于在用授权的app，系统在使用时总是会改变状态栏的外观，应用程序在后台使用定位服务。

 @param shows  是否展示后台位置指示器
 */
- (void)setShowsBackgroundLocationIndicator:(BOOL) shows;

/**
 设置一个布尔值，该值指示位置管理器对象是否可能暂停位置更新。

 @param pauses 指示位置管理器对象是否可能暂停位置更新的布尔值。
 */
- (void)setPausesLocationUpdatesAutomatically:(BOOL) pauses;

@end

NS_ASSUME_NONNULL_END
