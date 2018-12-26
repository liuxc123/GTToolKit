//
//  MAMapSearchManager.m
//  GTCatalog
//
//  Created by liuxc on 2018/12/5.
//

#import "MAMapSearchManager.h"
#import "private/GTMASearchRequestIDGenerator.h"
#import <objc/runtime.h>

NSString *kSearchRequestIDKey = @"searchRequestIDKey";
NSString *kSearchAPIKey = @"searchAPIKey";
NSString *kSearchCompleteBlockKey = @"searchCompleteBlockKey";
NSString *kSearchErrorBlockKey = @"searchErrorBlockKey";

@interface MAMapSearchManager ()<AMapSearchDelegate>

@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString*, id>*> *searchArray;

@end

@interface AMapSearchObject ()

@property (nonatomic, assign) GTMAMapSearchRequestID requestID;

@end

@implementation MAMapSearchManager

+ (instancetype)sharedManager {
    static MAMapSearchManager *manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _searchArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - public methods

- (GTMAMapSearchRequestID)searchForRequest:(AMapSearchObject *)request
           completeBlock:(MASearchCompletionBlock)completeBlock
              errorBlock:(MASearchErrorBlock)errorblock
{
    request.requestID = [GTMASearchRequestIDGenerator getUniqueRequestID];

    AMapSearchAPI *searchAPI = [[AMapSearchAPI alloc] init];
    searchAPI.delegate = self;
    //存储requestId
    NSMutableDictionary *searchDic = [NSMutableDictionary dictionary];
    [searchDic setValue:[NSNumber numberWithInteger:request.requestID] forKey:kSearchRequestIDKey];
    [searchDic setObject:searchAPI forKey:kSearchAPIKey];
    [searchDic setObject:completeBlock forKey:kSearchCompleteBlockKey];
    [searchDic setObject:errorblock forKey:kSearchErrorBlockKey];
    [self.searchArray addObject:searchDic];


    // POI 搜索
    if ([request isKindOfClass:[AMapPOIKeywordsSearchRequest class]]) {
        [searchAPI AMapPOIKeywordsSearch:request];
    }

    // 周边 搜索
    if ([request isKindOfClass:[AMapPOIAroundSearchRequest class]]) {
        [searchAPI AMapPOIAroundSearch:request];
    }

    // ID 搜索
    if ([request isKindOfClass:[AMapPOIIDSearchRequest class]]) {
        [searchAPI AMapPOIIDSearch:request];
    }

    // 检索多边形内的POI
    if ([request isKindOfClass:[AMapPOIPolygonSearchRequest class]]) {
        [searchAPI AMapPOIPolygonSearch:request];
    }

    // 获取道路沿途的POI
    if ([request isKindOfClass:[AMapRoutePOISearchRequest class]]) {
        [searchAPI AMapRoutePOISearch:request];
    }

    // 根据输入给出提示语
    if ([request isKindOfClass:[AMapInputTipsSearchRequest class]]) {
        [searchAPI AMapInputTipsSearch:request];
    }

    // 地理编码
    if ([request isKindOfClass:[AMapGeocodeSearchRequest class]]) {
        [searchAPI AMapGeocodeSearch:request];
    }

    // 反地理编码
    if ([request isKindOfClass:[AMapReGeocodeSearchRequest class]]) {
        [searchAPI AMapReGoecodeSearch:request];
    }

    // 获取行政区划数据
    if ([request isKindOfClass:[AMapDistrictSearchRequest class]]) {
        [searchAPI AMapDistrictSearch:request];
    }

    // 公交路线ID查询
    if ([request isKindOfClass:[AMapBusLineIDSearchRequest class]]) {
        [searchAPI AMapBusLineIDSearch:request];
    }

    // 公交路线关键字查询
    if ([request isKindOfClass:[AMapBusLineNameSearchRequest class]]) {
        [searchAPI AMapBusLineNameSearch:request];
    }

    // 公交站点查询介绍
    if ([request isKindOfClass:[AMapBusStopSearchRequest class]]) {
        [searchAPI AMapBusStopSearch:request];
    }

    // 获取天气数据
    if ([request isKindOfClass:[AMapWeatherSearchRequest class]]) {
        [searchAPI AMapWeatherSearch:request];
    }

    // 获取业务数据（云图功能）本地检索
    if ([request isKindOfClass:[AMapCloudPOILocalSearchRequest class]]) {
        [searchAPI AMapCloudPOILocalSearch:request];
    }

    // 获取业务数据（云图功能）本地检索
    if ([request isKindOfClass:[AMapCloudPOIAroundSearchRequest class]]) {
        [searchAPI AMapCloudPOIAroundSearch:request];
    }

    // 获取业务数据（云图功能）多边形检索
    if ([request isKindOfClass:[AMapCloudPOIPolygonSearchRequest class]]) {
        [searchAPI AMapCloudPOIPolygonSearch:request];
    }

    // 获取业务数据（云图功能 ID 检索
    if ([request isKindOfClass:[AMapCloudPOIIDSearchRequest class]]) {
        [searchAPI AMapCloudPOIIDSearch:request];
    }

    // 交通态势搜索
    if ([request isKindOfClass:[AMapRoadTrafficSearchRequest class]]) {
        [searchAPI AMapRoadTrafficSearch:request];
    }


    // 驾车出行路线规划
    if ([request isKindOfClass:[AMapDrivingRouteSearchRequest class]]) {
        [searchAPI AMapDrivingRouteSearch:request];
    }

    // 步行出行路线规划
    if ([request isKindOfClass:[AMapWalkingRouteSearchRequest class]]) {
        [searchAPI AMapWalkingRouteSearch:request];
    }

    // 公交出行路线规划
    if ([request isKindOfClass:[AMapTransitRouteSearchRequest class]]) {
        [searchAPI AMapTransitRouteSearch:request];
    }

    // 骑行出行路线规划
    if ([request isKindOfClass:[AMapRidingRouteSearchRequest class]]) {
        [searchAPI AMapRidingRouteSearch:request];
    }

    // 骑行出行路线规划
    if ([request isKindOfClass:[AMapTruckRouteSearchRequest class]]) {
        [searchAPI AMapTruckRouteSearch:request];
    }

    return request.requestID;
}

#pragma mark - private methods

- (NSDictionary<NSString *,id>*)getRequestInfoWithRequestID:(GTMAMapSearchRequestID)requestID
{
    __block NSDictionary<NSString *,id> *requestInfo;
    [self.searchArray enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ((GTMAMapSearchRequestID)[obj objectForKey:kSearchRequestIDKey] == requestID) {
            requestInfo = obj;
            *stop == YES;
        }
    }];
    return requestInfo;
}

- (void)performBlockWithRequest:(AMapSearchObject *)request response:(AMapSearchObject *)response {
    NSDictionary *requestInfo =[self getRequestInfoWithRequestID:((AMapSearchObject *)request).requestID];
    MASearchCompletionBlock completeBlock = [requestInfo objectForKey:kSearchCompleteBlockKey];
    if (completeBlock) {
        completeBlock(request, response);
    }
}


#pragma mark - AMapSearchDelegate methods

/* 当请求发生错误时，会调用代理的此方法. */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSDictionary *requestInfo =[self getRequestInfoWithRequestID:((AMapSearchObject *)request).requestID];
    MASearchErrorBlock errorBlock = [requestInfo objectForKey:kSearchErrorBlockKey];
    if (errorBlock) {
        errorBlock(error);
    }
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    [self performBlockWithRequest:request response:response];
}

/* 沿途查询回调函数 */
- (void)onRoutePOISearchDone:(AMapRoutePOISearchRequest *)request response:(AMapRoutePOISearchResponse *)response
{
    [self performBlockWithRequest:request response:response];
}

/* 地理编码查询回调函数 */
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    [self performBlockWithRequest:request response:response];
}

/* 逆地理编码查询回调函数 */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    [self performBlockWithRequest:request response:response];
}

/* 输入提示查询回调函数 */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    [self performBlockWithRequest:request response:response];
}


/* 公交站查询回调函数 */
- (void)onBusStopSearchDone:(AMapBusStopSearchRequest *)request response:(AMapBusStopSearchResponse *)response
{
    [self performBlockWithRequest:request response:response];
}


/* 公交线路关键字查询回调 */
- (void)onBusLineSearchDone:(AMapBusLineBaseSearchRequest *)request response:(AMapBusLineSearchResponse *)response
{
    [self performBlockWithRequest:request response:response];
}


/* 行政区域查询回调函数 */
- (void)onDistrictSearchDone:(AMapDistrictSearchRequest *)request response:(AMapDistrictSearchResponse *)response
{
    [self performBlockWithRequest:request response:response];
}

/* 路径规划查询回调 */
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    [self performBlockWithRequest:request response:response];
}

/* 距离查询回调 */
- (void)onDistanceSearchDone:(AMapDistanceSearchRequest *)request response:(AMapDistanceSearchResponse *)response
{
    [self performBlockWithRequest:request response:response];
}

/* 天气查询回调 */
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response
{
    [self performBlockWithRequest:request response:response];
}

/* 天气查询回调 */
- (void)onRoadTrafficSearchDone:(AMapRoadTrafficSearchBaseRequest *)request response:(AMapRoadTrafficSearchResponse *)response
{
    [self performBlockWithRequest:request response:response];
}

/* 附近搜索回调 */
- (void)onNearbySearchDone:(AMapNearbySearchRequest *)request response:(AMapNearbySearchResponse *)response
{
    [self performBlockWithRequest:request response:response];
}

/* 云图搜索回调 */
- (void)onCloudSearchDone:(AMapCloudSearchBaseRequest *)request response:(AMapCloudPOISearchResponse *)response
{
    [self performBlockWithRequest:request response:response];
}

/* 短串分享搜索回调 */
- (void)onShareSearchDone:(AMapShareSearchBaseRequest *)request response:(AMapShareSearchResponse *)response
{
    [self performBlockWithRequest:request response:response];
}

@end

@implementation AMapSearchObject

- (GTMAMapSearchRequestID)requestID {
    return (long)objc_getAssociatedObject(self, _cmd);
}

- (void)setRequestID:(GTMAMapSearchRequestID)requestID {
    NSNumber *number = [[NSNumber alloc]initWithInteger:requestID];
    objc_setAssociatedObject(self,  @selector(requestID), number, OBJC_ASSOCIATION_ASSIGN);
}

@end
