//
//  KDSHomeViewController.m
//  KaadasLock
//
//  Created by wzr on 2019/1/15.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSHomeViewController.h"
#import "KDSDeviceNicknameView.h"
#import "Masonry.h"
#import "MBProgressHUD+MJ.h"
#import "KDSLockInFoVC.h"
#import "KDSCatEyeInForVC.h"
#import "KDSDBManager+GW.h"
#import "KDSHttpManager+Ble.h"
#import "MJRefresh.h"
#import "YGScrollTitleView.h"
#import "KDSLockInFoVC.h"
#import "KDSAddDeviceVC.h"
#import "KDSMQTT.h"
#import "KDSGWLockInfoVC.h"
#import "KDSHttpManager+User.h"
#import "KDSDBManager+CY.h"
#import "ReactiveObjC.h"
#import "KDSWifiLockInfoVC.h"
#import "KDSZeroFireSingleModel.h"
#import "KDSZeroFireSingleInfoVC.h"


@interface KDSHomeViewController ()<UIScrollViewDelegate>

///添加设备的按钮
@property (weak, nonatomic) IBOutlet UIButton *addDeviceBtn;
///‘守护您的家’label
@property (weak, nonatomic) IBOutlet UILabel *sloganLabel;
///波浪元素--中间位置的小视图
@property (weak, nonatomic) IBOutlet UIImageView *elementImageView;
///显示logo的视图
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
///大的背景图底图
@property (weak, nonatomic) IBOutlet UIImageView *BgImageView;
///从服务器获取的绑定设备[MyDevice, GatewayDeviceModel]。
@property (nonatomic, strong) NSMutableArray *devicesArr;
// 用来放viewController的view
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) YGScrollTitleView *titleView;
/**
 横坐标偏移比例，在[0, devices.count-1]之间。设置此属性前请先设置devices，默认值0.设置此属性同时会设置标签偏移、字体和颜色。
 */
@property (nonatomic, assign) CGFloat offsetX;
///mqtt 'getAllBindDevice' task receipt, if this variable is not nil, don't request server duplicately.
@property (nonatomic, strong) KDSMQTTTaskReceipt *mqttReceipt;

@end

@implementation KDSHomeViewController

#pragma mark - 生命周期、界面设置方法。
- (void)viewDidLoad {
    [super viewDidLoad];
    [[KDSUserManager sharedManager].gateways removeAllObjects];
    [[KDSUserManager sharedManager].locks removeAllObjects];
    [[KDSUserManager sharedManager].cateyes removeAllObjects];
    KDSDBManager *db = [KDSDBManager sharedManager];
    NSArray *bleDevices = [db queryBindedDevices];
    if (bleDevices.count) [self.devicesArr addObjectsFromArray:bleDevices];
    NSArray *gws = [db queryBindedGateways];
    for (GatewayModel *model in gws)
    {
        KDSGW *gw = [KDSGW new];
        gw.model = model;
        [[KDSUserManager sharedManager].gateways addObject:gw];
        if (model.devices) [self.devicesArr addObjectsFromArray:model.devices];
    }
    NSArray * wifiModels = [db queryBindedWifiModels];
    if (wifiModels.count) [self.devicesArr addObjectsFromArray:wifiModels];
    // 设置自动调整ScrollView的ContentInset
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.BgImageView.userInteractionEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    self.addDeviceBtn.layer.masksToBounds = YES;
    self.addDeviceBtn.layer.cornerRadius = 22;
    [self.addDeviceBtn setTintColor:KDSRGBColor(31,150,247)];
    [self.addDeviceBtn setTitle:Localized(@"insetAddDevice") forState:UIControlStateNormal];
    
    _titleView = [[YGScrollTitleView alloc] init];
    _titleView.frame = CGRectMake(0, 44, KDSScreenWidth, 60);
    // 创建滚动视图控制器的scrollView
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleView.frame), KDSScreenWidth,KDSScreenHeight - CGRectGetMaxY(_titleView.frame) - self.tabBarController.tabBar.bounds.size.height)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    [self.BgImageView addSubview:_scrollView];
    [self uploadPushDeviceToken];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockHasBeenDeleted:) name:KDSLockHasBeenDeletedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockDidAlarm:) name:KDSLockDidAlarmNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockHasBeenAdded:) name:KDSLockHasBeenAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachabilityStatusDidChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeLanguageDidChange:) name:KDSLocaleLanguageDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gwOnlineRefreshDevice:) name:KDSGWOnlineNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cateyeHasBeendeleted:) name:KDSCatEyeHasBeenDeletedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBleVersionRefreshDevices:) name:KDSLockUpdateBleVersionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBleVersionRefreshDevices:) name:KDSBleLockUpdateDataSourceNotification object:nil];
    [self refreshChildViewControllersAndTitleView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    ///从服务器获取网关下绑定的设备，并刷新界面。
    [self getAllBindDevice];
    [[KDSUserManager sharedManager] monitorNetWork];
       
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
}

/**
 *@abstract 根据device从已显示的设备页中找出是否包含对应的device。
 *@param device 设备，必须为MyDevice或GatewayDeviceModel类型。
 *@return 如果已显示的页面中包含该设备，则将该页面控制器返回，否则返回nil。
 */
- (nullable UIViewController *)childInfoVCForDevice:(id)device
{
    for (UIViewController *vc in self.childViewControllers)
    {
        if ([vc isKindOfClass:[KDSLockInFoVC class]]) {
            KDSLockInFoVC *infoVC = (KDSLockInFoVC *)vc;
            if ([infoVC.lock.device isEqual:device]) return vc;
        }
        else if ([vc isKindOfClass:[KDSCatEyeInForVC class]]) {
            KDSCatEyeInForVC *infoVC = (KDSCatEyeInForVC *)vc;
            if ([infoVC.cateye.gatewayDeviceModel isEqual:device]) return vc;
        }
        else if ([vc isKindOfClass:[KDSGWLockInfoVC class]]) {
            KDSGWLockInfoVC *infoVC = (KDSGWLockInfoVC *)vc;
            if ([infoVC.lock.gwDevice isEqual:device]) return vc;
        }
        else if ([vc isKindOfClass:[KDSWifiLockInfoVC class]]) {
            KDSWifiLockInfoVC *infoVC = (KDSWifiLockInfoVC *)vc;
            if ([infoVC.lock.wifiDevice isEqual:device]) return vc;
        }
    }
    return nil;
}

/**
 *@abstract 当绑定的设备被删除时，或从服务器拉取到新的设备列表时，刷新主界面。调用此方法前，请先更新devicesArr属性。页面刷新完成后会发出通知KDSDeviceSyncNotification
 */
- (void)refreshChildViewControllersAndTitleView
{
    //先记录当前显示的页面设备及索引。
    NSInteger index = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width + 0.5;
    MyDevice *currentDevice = self.devicesArr.count > index ? [self.devicesArr objectAtIndex:index] : nil;
    [self removeOldChildViewControllers];
    [self addNewChildViewControllers];
    
    // 创建YGSrollViewTitleView
    __weak typeof(self) weakSelf = self;
    [self.titleView removeFromSuperview];
    _titleView = [[YGScrollTitleView alloc] initWithFrame:CGRectMake(0, 44, KDSScreenWidth, 60) titles:self.devicesArr.copy callBack:^(NSInteger pageIndex) {
        // 点击头部按钮时的回调
        // 设置scrollView的偏移量
        [weakSelf.scrollView setContentOffset:CGPointMake(pageIndex * weakSelf.scrollView.bounds.size.width, 0) animated:NO];
    }];
    
    [self.BgImageView addSubview:_titleView];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width*self.devicesArr.count, self.scrollView.bounds.size.height);
    //如果更新设备列表前显示的设备还在，那么当前页面继续显示该设备，否则显示之前的索引页或者最后一个设备页。
    NSInteger newIndex = index;
    if ([self.devicesArr containsObject:currentDevice])
    {
        newIndex = [self.devicesArr indexOfObject:currentDevice];
        self.offsetX = newIndex;
    }
    else
    {
        newIndex = index >= self.devicesArr.count ? self.devicesArr.count - 1 : index;
        newIndex = self.devicesArr.count == 0 ? 0 : newIndex;
    }
    self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * index, 0);
    self.logoImageView.hidden = YES;//self.devicesArr.count != 0;
    self.addDeviceBtn.hidden = self.devicesArr.count != 0;
    self.elementImageView.hidden = self.devicesArr.count != 0;
    self.sloganLabel.hidden = self.devicesArr.count != 0;
    //如果新旧的偏移相同就不做偏移操作了。
    if (newIndex != index)
    {
        self.scrollView.contentOffset = CGPointMake(kScreenWidth * newIndex, 0);
        self.offsetX = newIndex;
    }else{
        
        [_titleView selectButtonIndex:self.offsetX];
        [_titleView moveTopViewLine:self.scrollView.contentOffset];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KDSDeviceSyncNotification object:nil userInfo:nil];
}

///删除子控制器。如果某一子控制器对应的设备已被删除，将该子控制器从界面删除，调用此方法前，请先更新devicesArr属性。
- (void)removeOldChildViewControllers
{
    KDSUserManager *manager = [KDSUserManager sharedManager];
    for (UIViewController *vc in self.childViewControllers)
    {
        BOOL existed = YES;
        if ([vc isKindOfClass:[KDSLockInFoVC class]]) {
            KDSLockInFoVC *infoVC = (KDSLockInFoVC *)vc;
            if (![self.devicesArr containsObject:infoVC.lock.device])
            {
                [manager.locks removeObject:infoVC.lock];
                existed = NO;
            }
        }
        else if ([vc isKindOfClass:[KDSCatEyeInForVC class]]) {
            KDSCatEyeInForVC *infoVC = (KDSCatEyeInForVC *)vc;
            if (![self.devicesArr containsObject:infoVC.cateye.gatewayDeviceModel])
            {
                [manager.cateyes removeObject:infoVC.cateye];
                existed = NO;
            }
        }
        else if ([vc isKindOfClass:[KDSGWLockInfoVC class]]) {
            KDSGWLockInfoVC *infoVC = (KDSGWLockInfoVC *)vc;
            if (![self.devicesArr containsObject:infoVC.lock.gwDevice])
            {
                [manager.locks removeObject:infoVC.lock];
                existed = NO;
            }
        }
        else if ([vc isKindOfClass:[KDSWifiLockInfoVC class]]) {
            KDSWifiLockInfoVC *infoVC = (KDSWifiLockInfoVC *)vc;
            if (![self.devicesArr containsObject:infoVC.lock.wifiDevice])
            {
                [manager.locks removeObject:infoVC.lock];
                existed = NO;
            }
        }
        if (!existed)
        {
            [vc.view removeFromSuperview];
            [vc removeFromParentViewController];
        }
    }
}

///有新设备绑定时添加子控制器。调用此方法前，请先更新devicesArr属性。
- (void)addNewChildViewControllers
{
    KDSUserManager *manager = [KDSUserManager sharedManager];
    for (id device in self.devicesArr)
    {
        NSLog(@"self.devicesArr = %@",self.devicesArr);
        UIViewController *viewController = [self childInfoVCForDevice:device];
        if (viewController)
        {
            CGRect frame = self.scrollView.bounds;
            frame.origin.x = [self.devicesArr indexOfObject:device] * self.scrollView.bounds.size.width;
            viewController.view.frame = frame;
            continue;
        }
        if ([device isKindOfClass:MyDevice.class])
        {
            MyDevice *dev = device;
            KDSLockInFoVC *vc = [KDSLockInFoVC new];
            KDSLock *lock = [[KDSLock alloc] init];
            lock.power = [[KDSDBManager sharedManager] queryPowerWithBleName:dev.lockName];
            lock.device = dev;
            [manager.locks addObject:lock];
            vc.lock = lock;
            /*__weak typeof(self) weakSelf = self;
            vc.pulldownRefreshBlock = ^{
                [weakSelf getAllBindDevice];
                [weakSelf syncChildViewControllersViewRefreshState:MJRefreshStateRefreshing];
            };*/
            viewController = vc;
        }
        else if ([device isKindOfClass:GatewayDeviceModel.class])
        {
            GatewayDeviceModel *dev = device;
            KDSGW *gw = [manager.gateways filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K like %@", @"model.deviceSN", dev.gwId]].firstObject;
            if (!gw) continue;//如果找不到对应的网关，有可能是新绑定，本地缓存没有，等网络请求结束再刷新。
            if ([dev.device_type isEqualToString:@"kdszblock"])
            {
                KDSLock *lock = [KDSLock new];
                lock.gw = gw;
                lock.gwDevice = dev;
                lock.power = [[KDSDBManager sharedManager] queryPowerWithLock:dev];
                KDSGWLockInfoVC *vc = [KDSGWLockInfoVC new];
                vc.lock = lock;
                [manager.locks addObject:lock];
                viewController = vc;
            }
            else
            {
                KDSCatEyeInForVC * cateyeVC = [KDSCatEyeInForVC new];
                KDSCatEye * cateye = [[KDSCatEye alloc] init];
                cateye.gatewayDeviceModel = dev;
                cateye.gw = gw;
                cateye.powerStr = [[[KDSDBManager sharedManager] queryCateyePowerWithDeviceId:cateye.gatewayDeviceModel.deviceId] intValue];
                [manager.cateyes addObject:cateye];
                cateyeVC.cateye = cateye;
                viewController = cateyeVC;
            }
        }else if ([device isKindOfClass:KDSWifiLockModel.class])
        {
            KDSWifiLockModel *dev = device;
            KDSWifiLockInfoVC *vc = [KDSWifiLockInfoVC new];
            KDSLock *lock = [[KDSLock alloc] init];
            lock.power = [[KDSDBManager sharedManager] queryPowerWithBleName:dev.wifiSN];
            lock.wifiDevice = dev;
            [manager.locks addObject:lock];
            vc.lock = lock;
            viewController = vc;
        }else if ([device isKindOfClass:KDSZeroFireSingleModel.class]){
            KDSZeroFireSingleInfoVC * vc = [KDSZeroFireSingleInfoVC new];
            viewController = vc;
        }
        
        [self addChildViewController:viewController];
        [self.scrollView addSubview:viewController.view];
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = [self.devicesArr indexOfObject:device] * self.scrollView.bounds.size.width;
        viewController.view.frame = frame;
    }
    //这里判断用户账号下面是否存在猫眼设备
    [KDSUserDefaults setObject:manager.cateyes.count!=0 ?@"true":@"false" forKey:KDSUserBindingedCateye];
//    if (manager.cateyes.count != 0) {
//        [self startCateye];
//    }
}

///子控制器下拉刷新时，为保持同步，需将每个子控制的状态都设置为同一刷新中状态。
- (void)syncChildViewControllersViewRefreshState:(MJRefreshState)state
{
    //0.5秒大概比mj_header动画时间多一点，不然置空下拉刷新没效果。置空下拉刷新回调是防止循环调用。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(state == MJRefreshStateRefreshing ? 0 : 0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf __unused = self;
        for (KDSLockInFoVC *vc in self.childViewControllers)
        {
            if (![vc respondsToSelector:@selector(pulldownRefreshBlock)]) continue;
            /*vc.pulldownRefreshBlock = state == MJRefreshStateRefreshing ? nil : ^{
                [weakSelf getAllBindDevice];
                [weakSelf syncChildViewControllersViewRefreshState:MJRefreshStateRefreshing];
            };*/
        }
        
        for (KDSLockInFoVC *vc in self.childViewControllers)
        {
            if (![vc respondsToSelector:@selector(tableView)]) continue;
            vc.tableView.mj_header.state = state;
        }
    });
}

#pragma mark - 网络请求方法。
-(void)uploadPushDeviceToken{
    NSString *deviceToken = [KDSTool getDeviceToken];
    NSString *VoIPToken = [KDSTool getVoIPDeviceToken];
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"--{Kaadas}--上传deviceToken=%@,VoIPToken=%@,准备",deviceToken,VoIPToken);

    if (!deviceToken) return;
    if (!VoIPToken) return;
    [[KDSHttpManager sharedManager] uploadPushToken:deviceToken remoteNotificationToken:VoIPToken withUid:[KDSUserManager sharedManager].user.uid mobileInfo:@{@"moble": phoneVersion,@"vesion":[KDSTool getIphoneType]} success:^{
        KDSLog(@"--{Kaadas}--上传deviceToken,成功");
    } error:^(NSError * _Nonnull error) {
        KDSLog(@"%@", [NSString stringWithFormat:@"--{Kaadas}--上传deviceToken,失败-error=%@",error.localizedDescription]);
//        [MBProgressHUD showError:error.localizedDescription];
    } failure:^(NSError * _Nonnull error) {
        KDSLog(@"%@", [NSString stringWithFormat:@"--{Kaadas}--上传deviceToken,失败-failure=%@",error.localizedDescription]);
//        [MBProgressHUD showError:error.localizedDescription];
    }];
};

/**
 *@abstract 当绑定的设备被删除时，或从服务器拉取到新的设备列表时，刷新主界面。加入了缓存数据，没有网络的时候应该使用缓存数据刷新。
 */
-(void)getAllBindDevice
{
    static NSURLSessionDataTask *task = nil;
    if (task)
    {
        [task cancel];
        task = nil;
    }
    MBProgressHUD *hud = nil;
    if (!_devicesArr)//首次进入转菊花。
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.removeFromSuperViewOnHide = YES;
    }
    void(^errorBlock)(NSError *) = ^(NSError *error){//网络请求出错执行的回调。
        NSArray<MyDevice *> *devices = [[KDSDBManager sharedManager] queryBindedDevices];
        if (devices.count)
        {
            [self.devicesArr removeAllObjects];
            [self.devicesArr addObjectsFromArray:devices];
            [self refreshChildViewControllersAndTitleView];
        }
        else
        {
            NSString *msg = error.userInfo ? error.localizedDescription : [NSString stringWithFormat:@"error, code = %ld", (long)error.code];
            [MBProgressHUD showError:msg];
        }
    };
     __weak typeof(self) weakSelf = self;
    task = [[KDSHttpManager sharedManager] getBindedDeviceListWithUid:[KDSUserManager sharedManager].user.uid success:^(NSArray<MyDevice *> * _Nonnull devices, NSArray * _Nonnull productInfoListArr) {
        task = nil;
        [hud hideAnimated:YES];
        [self syncChildViewControllersViewRefreshState:MJRefreshStateIdle];
        KDSUserManager * userManger = [KDSUserManager sharedManager];
        if (!userManger.user.token) return;
        if (productInfoListArr.count > 0) [userManger.productInfoList removeAllObjects];
        for (KDSProductInfoList * product in productInfoListArr) {
            if (product) {
                [userManger.productInfoList addObject:product];
            }
        }
        //先删除设备。
        for (NSUInteger i = 0; i < weakSelf.devicesArr.count; ++i)
        {
            id device = weakSelf.devicesArr[i];
            if ([device isKindOfClass:MyDevice.class] && ![devices containsObject:device])
            {
                [weakSelf.devicesArr removeObjectAtIndex:i];
                i--;
            }
        }
        //再添加设备。
        for (MyDevice *bledevice in devices)
        {
            NSUInteger index = [weakSelf.devicesArr indexOfObject:bledevice];
            if (index == NSNotFound)
            {
                [weakSelf.devicesArr addObject:bledevice];
            }
            else
            {
                [weakSelf.devicesArr replaceObjectAtIndex:index withObject:bledevice];
                KDSLockInFoVC *vc = (KDSLockInFoVC *)[weakSelf childInfoVCForDevice:bledevice];
                vc.lock.device = bledevice;
            }
        }
        [self refreshChildViewControllersAndTitleView];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[KDSDBManager sharedManager] updateBindedDevices:devices];
        });
                
    } error:^(NSError * _Nonnull error) {
        task = nil;
        [hud hideAnimated:YES];
        [self syncChildViewControllersViewRefreshState:MJRefreshStateIdle];
        errorBlock(error);
    
    } failure:^(NSError * _Nonnull error) {
        task = nil;
        [hud hideAnimated:YES];
        [self syncChildViewControllersViewRefreshState:MJRefreshStateIdle];
        if (error.code != NSURLErrorCancelled)
        {
            errorBlock(error);
        }
                
    }];
}

-(void)startCateye{
    static dispatch_once_t disOnce;
    dispatch_once(&disOnce,^ {
        //只执行一次的代码
//        [self startSip];
    });
}

///点击添加设备的按钮
- (IBAction)addDeviceBtn:(id)sender {
    
    KDSAddDeviceVC *vc = [[KDSAddDeviceVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.gateways = [KDSUserManager sharedManager].gateways;
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark -- 通知事件---

- (void)appDidBecomeActive:(NSNotification *)noti
{
//    [self getAllBindDevice];
}
-(void)gwOnlineRefreshDevice:(NSNotification *)noti
{
    [self getAllBindDevice];
}
-(void)updateBleVersionRefreshDevices:(NSNotification *)noti
{
    [self getAllBindDevice];
}
///设备被删除的通知。
- (void)lockHasBeenDeleted:(NSNotification *)noti
{
    KDSLock *deleted = noti.userInfo[@"lock"];
    KDSUserManager *userMgr = [KDSUserManager sharedManager];
    KDSDBManager *dbMgr = [KDSDBManager sharedManager];
    [userMgr.locks removeObject:deleted];
    if (deleted.device)
    {
        NSMutableArray *array = [NSMutableArray array];
        for (KDSLock *lock in userMgr.locks)
        {
            if (lock.device) [array addObject:lock.device];
        }
        [self.devicesArr removeObject:deleted.device];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [dbMgr updateBindedDevices:array];
        });
    }
    else if (deleted.gwDevice)
    {
        [self.devicesArr removeObject:deleted.gwDevice];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [dbMgr deleteGWLocks:@[deleted.gwDevice] sn:nil];
        });
    }
    else if (deleted.gw && !deleted.gwDevice)
    {
        [userMgr.gateways removeObject:deleted.gw];
        for (NSInteger i = 0; i < self.devicesArr.count; ++i)
        {
            GatewayDeviceModel *device = self.devicesArr[i];
            if ([device isKindOfClass:GatewayDeviceModel.class] && [device.gwId isEqualToString:deleted.gw.model.deviceSN])
            {
                [self.devicesArr removeObjectAtIndex:i];
                i--;
            }
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [dbMgr deleteGWLocks:nil sn:deleted.gw.model.deviceSN];
            NSMutableArray *array = [NSMutableArray array];
            for (KDSGW *gw in userMgr.gateways)
            {
                [array addObject:gw.model];
            }
            [[KDSDBManager sharedManager] updateBindedGateways:array];
        });
    }else if (deleted.wifiDevice){
        [self.devicesArr removeObject:deleted.wifiDevice];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [dbMgr deleteGWLocks:@[deleted.wifiDevice] sn:nil];
        });
    }
    [self refreshChildViewControllersAndTitleView];
}
///猫眼删除设备的通知。
-(void)cateyeHasBeendeleted:(NSNotification *)noti
{
    KDSCatEye * cateye = noti.userInfo[@"cateye"];
    [[KDSUserManager sharedManager].cateyes removeObject:cateye];
    if (cateye.gatewayDeviceModel) {
        [self.devicesArr removeObject:cateye.gatewayDeviceModel];
    }
     [self refreshChildViewControllersAndTitleView];
}

///锁上报报警通知。
- (void)lockDidAlarm:(NSNotification *)noti
{
    CBPeripheral *p = noti.userInfo[@"peripheral"];
    NSData *data = noti.userInfo[@"data"];
    [[KDSUserManager sharedManager] addAlarmForLockWithBleName:p.advDataLocalName data:data];
}

///绑定新设备的通知。
- (void)lockHasBeenAdded:(NSNotification *)noti
{
    id device = noti.userInfo[@"device"];
    NSMutableArray *devices = [NSMutableArray array];
    if ([device isKindOfClass:MyDevice.class])
    {
        for (KDSLock *lock in [KDSUserManager sharedManager].locks)
        {
            if (lock.device) [devices addObject:lock.device];
        }
        [devices addObject:device];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[KDSDBManager sharedManager] updateBindedDevices:devices];
        });
    }
    if (![self.devicesArr containsObject:device]) [self.devicesArr addObject:device];
    [self refreshChildViewControllersAndTitleView];
}

///收到更改了本地语言的通知，刷新表视图。
- (void)localeLanguageDidChange:(NSNotification *)noti
{
    [self.addDeviceBtn setTitle:Localized(@"insetAddDevice") forState:UIControlStateNormal];
}

// 允许自动旋转
-(BOOL)shouldAutorotate{
    return NO;
}

///网络状态改变的通知。当网络不可用时，会将网关、猫眼和网关锁的状态设置为离线后发出通知KDSDeviceSyncNotification
- (void)networkReachabilityStatusDidChange:(NSNotification *)noti
{
    NSNumber *number = noti.userInfo[AFNetworkingReachabilityNotificationStatusItem];
    AFNetworkReachabilityStatus status = number.integerValue;
    KDSUserManager *manager = [KDSUserManager sharedManager];
    for (KDSGW *gw in manager.gateways)
    {
        gw.networkAvailable = (status==AFNetworkReachabilityStatusReachableViaWWAN || status==AFNetworkReachabilityStatusReachableViaWiFi);
    }
    switch (status)
    {
        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusReachableViaWiFi:
            [self getAllBindDevice];
            break;
            
        default:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:KDSDeviceSyncNotification object:nil userInfo:nil];
        }

            break;
    }
}


#pragma arguments  ---- 懒加载 ----
- (NSMutableArray *)devicesArr
{
    if (_devicesArr == nil)
    {
        _devicesArr = [NSMutableArray array];
    }
    return _devicesArr;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    
    [_titleView selectButtonIndex:index];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_titleView moveTopViewLine:scrollView.contentOffset];
}

-(void)dealloc{
    [KDSNotificationCenter removeObserver:self];
    NSLog(@"%@被销毁了",self.class);
}
@end
