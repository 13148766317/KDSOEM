//
//  KDSWifiLockInfoVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/19.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSWifiLockInfoVC.h"
#import "KDSHomePageLockStatusCell.h"
#import "KDSMQTT.h"
#import "KDSDBManager+GW.h"
#import "MBProgressHUD+MJ.h"
#import "KDSHttpManager.h"
#import "KDSWFRecordDetailsVC.h"
#import "KDSCountdown.h"
#import "NSDate+KDS.h"
#import "KDSFTIndicator.h"
#import "KDSWifiLockOperation.h"
#import "KDSHttpManager+WifiLock.h"



@interface KDSWifiLockInfoVC ()<UITableViewDelegate, UITableViewDataSource>

///最外围的大圆。
@property (strong, nonatomic) UIImageView *bigCircleIV;
///中间的圆。
@property (strong, nonatomic) UIImageView *middleCircleIV;
///内部的小圆
@property (strong, nonatomic) UIImageView *smallCircleIV;
///显示ZigBee图标的视图。
@property (strong, nonatomic) UIImageView *zbLogoIV;
///锁动作提示标签(开锁、连接等)。
@property (nonatomic, strong) UILabel *actionLabel;
///锁状态提示标签(反锁、布防等)。
@property (nonatomic, strong) UILabel *stateLabel;
///wifi锁信息更新的时间
@property (nonatomic, strong) UILabel *updateTimeLb;
///“守护时间”标签，设置语言本地化用。
@property (nonatomic, weak) UILabel *guardianDayLocalizedLabel;
///锁绑定天数标签。
@property (nonatomic, strong) UILabel *dayLabel;
///守护时间“天”标签，设置语言本地化用。
@property (nonatomic, weak) UILabel *dayLocalizedLabel;
///“守护次数”标签，设置语言本地化用。
@property (nonatomic, weak) UILabel *guardianTimesLocalizedLabel;
///锁开锁次数标签。
@property (nonatomic, strong) UILabel *timesLabel;
///守护次数“次”标签，设置语言本地化用。
@property (nonatomic, weak) UILabel *timesLocalizedLabel;
///服务器请求回来的开锁记录数组。
@property (nonatomic, strong) NSMutableArray<KDSWifiLockOperation *> *unlockRecordArr;
///服务器请求回来开锁记录数组后按日期(天)提取的记录分组数组。
@property (nonatomic, strong) NSArray<NSArray<KDSWifiLockOperation *> *> *unlockRecordSectionArr;
///A date formatter with format yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong) NSDateFormatter *dateFmt;
///锁状态。
@property (nonatomic, assign) KDSLockState lockState;
@property (nonatomic, strong) UITableView * tableView;
///记录是否正在进行连接成功，如果是，设置锁状态时直接返回，等动画完毕再设置锁状态。
@property (nonatomic, assign) BOOL animating;
/////锯齿外圈(动画的时候重新赋值添加的图片)
@property (nonatomic, strong) UIImageView *gearIV;
///中间视图的复制(动画的时候重新赋值添加的图片)
@property (nonatomic, strong) UIImageView *cMiddleIV;
///小视图的复制(动画的时候重新赋值添加的图片)
@property (nonatomic, strong) UIImageView *cSmallIV;

@end

@implementation KDSWifiLockInfoVC

#pragma mark - getter setter
- (NSMutableArray<KDSWifiLockOperation *> *)unlockRecordArr
{
    if (!_unlockRecordArr)
    {
        _unlockRecordArr = [NSMutableArray array];
    }
    return _unlockRecordArr;
}
- (NSDateFormatter *)dateFmt
{
    if (!_dateFmt)
    {
        _dateFmt = [[NSDateFormatter alloc] init];
        _dateFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _dateFmt;
}
///目前wifi锁的模式：开锁状态>布防>反锁>安全>面容>节能
- (void)setLockState:(KDSLockState)lockState
{
    _lockState = lockState;
    self.lock.state = lockState;
    self.zbLogoIV.hidden = NO;
    self.actionLabel.textColor = UIColor.whiteColor;
    self.bigCircleIV.image = [UIImage imageNamed:@"bigBlueCircle"];
    self.zbLogoIV.image = [UIImage imageNamed:@"wifiLock-homeIcon"];
    switch (lockState)
    {
        case KDSLockStateDefence:
            self.middleCircleIV.image = [UIImage imageNamed:@"lockDefence"];
            self.smallCircleIV.image = [UIImage imageNamed:@"closedLock"];
            self.actionLabel.text = nil;
            self.stateLabel.text = Localized(@"Deployment mode started");
            break;
            
        case KDSLockStateLockInside:
            self.middleCircleIV.image = [UIImage imageNamed:@"lockInside"];
            self.smallCircleIV.image = [UIImage imageNamed:@"closedLock"];
            self.actionLabel.text = nil;
            self.zbLogoIV.image = [UIImage imageNamed:@"wifi连接失败"];
            self.stateLabel.text = Localized(@"LockInside&unlockInside");
            break;
            
        case KDSLockStateSecurityMode:
            self.bigCircleIV.image = [UIImage imageNamed:@"securityModeBigCircle"];
            self.middleCircleIV.image = [UIImage imageNamed:@"securityMode"];
            self.smallCircleIV.image = [UIImage imageNamed:@"closedLock"];
            self.actionLabel.text = nil;
            self.stateLabel.text = Localized(@"Security mode started");
            break;
        case KDSLockStateEnergy:
            self.middleCircleIV.image = [UIImage imageNamed:@"energyModel"];
            self.smallCircleIV.image = [UIImage imageNamed:@"energySmallIcon"];
            self.actionLabel.text = nil;
            self.stateLabel.text = Localized(@"Energy saving mode started");
            break;
        case KDSLockStateFaceTurnedOff:
            self.middleCircleIV.image = [UIImage imageNamed:@"faceTurnedOffModel"];
            self.smallCircleIV.image = [UIImage imageNamed:@"faceTurnedOffModelSmallIcon"];
            self.actionLabel.text = nil;
            self.stateLabel.text = Localized(@"Face recognition turned off");
            break;
        case KDSLockStateOnline:
            self.middleCircleIV.image = [UIImage imageNamed:@"bleConnected"];
            self.smallCircleIV.image = [UIImage imageNamed:@"closedLock"];
            self.actionLabel.text = nil;
            break;
            
        case KDSLockStateUnlocking:
            self.stateLabel.text = Localized(@"unlocking");
            [self stagingLockOperationAnimation:1];
            break;
            
        case KDSLockStateUnlocked:
            self.lock.wifiDevice.openStatus = 2;
            [self stagingLockOperationAnimation:2];
            break;
            
        case KDSLockStateFailed:
            self.stateLabel.text = Localized(@"Closedstate");
            [self stagingLockOperationAnimation:3];
            [self setLockState:KDSLockStateOnline];
            break;
            
        case KDSLockStateClosed:
            self.lock.wifiDevice.openStatus = 1;
            [self stagingLockOperationAnimation:4];
            [self setLockState:KDSLockStateOnline];
            break;
            
        default:
            self.middleCircleIV.image = [UIImage imageNamed:@"bleNotConnect"];
            self.smallCircleIV.image = [UIImage imageNamed:@"wifiOffline"];
            self.actionLabel.text = Localized(@"deviceOffline");
            self.actionLabel.textColor = KDSRGBColor(0x14, 0xa6, 0xf5);
            self.stateLabel.text = nil;
            self.zbLogoIV.hidden = YES;
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.clearColor;
    [self setupUI];
    [self getUnlockRecord];
    self.timesLabel.text = @"0";
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(KDSHomePageLockStatusCell.class) bundle:nil] forCellReuseIdentifier:NSStringFromClass([self class])];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeLanguageDidChange:) name:KDSLocaleLanguageDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifimqttEventNotification:) name:KDSMQTTEventNotification object:nil];
        
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getUnlockTimes];
    ///网关锁守护天数
    self.dayLabel.text = @(floor(([[NSDate date] timeIntervalSince1970] - self.lock.wifiDevice.createTime) / 24 / 3600)).stringValue;
    if (!self.lock.wifiDevice.updateTime) {
        self.lock.wifiDevice.updateTime = [[NSDate date] timeIntervalSince1970];
    }
    NSString * dateTime= [self.dateFmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.lock.wifiDevice.updateTime]];
    self.updateTimeLb.text = [dateTime stringByReplacingOccurrencesOfString:@"-" withString:@"."];
     ///目前wifi锁的模式：开锁状态>布防>反锁>安全>面容>节能
    if (self.lock.wifiDevice.powerSave.intValue == 1) {
        self.lock.state = KDSLockStateEnergy;
    }if (self.lock.wifiDevice.faceStatus.intValue == 1) {
        self.lock.state = KDSLockStateFaceTurnedOff;
    }if (self.lock.wifiDevice.safeMode.intValue == 1) {
        self.lock.state = KDSLockStateSecurityMode;
    }if (self.lock.wifiDevice.operatingMode.intValue == 1) {
        self.lock.state = KDSLockStateLockInside;
    }if (self.lock.wifiDevice.defences.intValue == 1) {
        self.lock.state = KDSLockStateDefence;
    }if (self.lock.wifiDevice.defences.intValue ==0 && self.lock.wifiDevice.operatingMode.intValue ==0 && self.lock.wifiDevice.safeMode.intValue == 0 && self.lock.wifiDevice.powerSave.intValue ==0 && self.lock.wifiDevice.faceStatus.intValue == 0 && self.lock.wifiDevice.openStatus != 2) {//正常状态（关闭状态）
        self.lock.state = KDSLockStateOnline;
        self.stateLabel.text = Localized(@"door has been locked");
    }if (self.lock.wifiDevice.openStatus == 2 && self.lock.state != KDSLockStateUnlocked) {//门未上锁（开锁状态）
        self.bigCircleIV.image = [UIImage imageNamed:@"openStatusIocnImg"];
        self.middleCircleIV.image = [UIImage imageNamed:@""];
        self.cMiddleIV.image = [UIImage imageNamed:@""];
        self.gearIV.image = [UIImage imageNamed:@""];
        self.smallCircleIV.image = [UIImage imageNamed:@"Unlocked"];
        self.actionLabel.text = nil;
        self.stateLabel.text = Localized(@"door has been unlocked");
        NSString * openStatusTime = [self.dateFmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.lock.wifiDevice.updateTime]];
       self.updateTimeLb.text = [openStatusTime stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        return;
    }
     [self setLockState:self.lock.state];
}

- (void)setupUI
{
    CGFloat rate = kScreenHeight / 667;
    rate = rate<1 ? rate : 1;
    self.bigCircleIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bigBlueCircle"]];
    [self.view addSubview:self.bigCircleIV];
    [self.bigCircleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kScreenHeight<667 ? 10 : 26);
        make.centerX.equalTo(@0);
        make.width.height.equalTo(@(179 * rate));
    }];
    /*Wi-Fi锁首页不允许点击*/
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureImageViewUnlock:)];
    [self.bigCircleIV addGestureRecognizer:tapGesture];
    self.bigCircleIV.userInteractionEnabled = YES;
    self.middleCircleIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bleNotConnect"]];
    [self.view addSubview:self.middleCircleIV];
    [self.middleCircleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bigCircleIV);
        make.width.height.equalTo(@(142 * rate));
    }];
    self.smallCircleIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifiOffline"]];
    self.smallCircleIV.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.smallCircleIV];
    [self.smallCircleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bigCircleIV);
        make.centerY.equalTo(self.bigCircleIV).offset(-6 * rate);
        make.width.height.equalTo(@(30 * rate));
    }];
    self.zbLogoIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifiLock-homeIcon"]];
    self.zbLogoIV.hidden = YES;
    [self.view addSubview:self.zbLogoIV];
    [self.zbLogoIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bigCircleIV);
        make.bottom.equalTo(self.smallCircleIV.mas_top).offset(-14 * rate);
        make.width.height.equalTo(@(18 * rate));
    }];
    self.actionLabel = [self createLabelWithText:Localized(@"deviceOffline") color:KDSRGBColor(0x14, 0xa6, 0xf5) font:[UIFont systemFontOfSize:12]];
    [self.view addSubview:self.actionLabel];
    [self.actionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.smallCircleIV.mas_bottom).offset(kScreenHeight<667 ? 5 : 10);
        make.centerX.equalTo(self.bigCircleIV);
    }];
    self.stateLabel = [self createLabelWithText:Localized(@"") color:KDSRGBColor(0xc6, 0xf5, 0xff) font:[UIFont systemFontOfSize:15]];
    [self.view addSubview:self.stateLabel];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bigCircleIV.mas_bottom).offset(10);
        make.centerX.equalTo(self.bigCircleIV);
    }];
    self.updateTimeLb = [self createLabelWithText:@"2019.12.28 13:05:56" color:UIColor.whiteColor font:[UIFont systemFontOfSize:11]];
    [self.view addSubview:self.updateTimeLb];
    [self.updateTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stateLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.bigCircleIV);
        
    }];
    
    UIView *cornerView = [UIView new];
    cornerView.layer.cornerRadius = 4;
    cornerView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:cornerView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToViewDeviceDynamicDetails:)];
    [cornerView addGestureRecognizer:tap];
    [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bigCircleIV.mas_bottom).offset(57 * rate);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@80);
    }];
    UIImageView *arrowIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"箭头Hight"]];
    [cornerView addSubview:arrowIV];
    [arrowIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(@0);
        make.right.equalTo(cornerView).offset(-20);
        make.size.mas_equalTo(arrowIV.image.size);
    }];
    UILabel *timeLabel = [self createLabelWithText:Localized(@"guardianTime") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:12]];
    self.guardianDayLocalizedLabel = timeLabel;
    UILabel *timesLabel = [self createLabelWithText:Localized(@"guardianTimes") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:12]];
    self.guardianTimesLocalizedLabel = timesLabel;
    [cornerView addSubview:timeLabel];
    [cornerView addSubview:timesLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cornerView).offset(6);
        make.top.equalTo(cornerView).offset(13);
        make.right.equalTo(timesLabel.mas_left).offset(0);
        make.width.equalTo(timesLabel);
    }];
    [timesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeLabel);
        make.left.equalTo(timeLabel.mas_right).offset(6);
        make.right.equalTo(arrowIV.mas_left).offset(-6);
        make.width.equalTo(timeLabel);
                
    }];
    UIView * lineView = [UIView new];
    lineView.backgroundColor = KDSRGBColor(220, 220, 220);
    [cornerView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@1);
        make.top.mas_equalTo(cornerView.mas_top).offset(10);
        make.bottom.mas_equalTo(cornerView.mas_bottom).offset(-10);
        make.centerX.mas_equalTo(cornerView.mas_centerX).offset(0);
    }];
    self.dayLabel = [self createLabelWithText:nil color:KDSRGBColor(0x1f, 0x96, 0xf7) font:[UIFont systemFontOfSize:23]];
    [cornerView addSubview:self.dayLabel];
    [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(cornerView);
        make.left.right.equalTo(timeLabel);
    }];
    ///开锁次数
    self.timesLabel = [self createLabelWithText:self.timesLabel.text color:KDSRGBColor(0x1f, 0x96, 0xf7) font:[UIFont systemFontOfSize:23]];
    [cornerView addSubview:self.timesLabel];
    [self.timesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(cornerView);
        make.left.right.equalTo(timesLabel);
    }];
    UILabel *dLabel = [self createLabelWithText:Localized(@"days") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:12]];
    self.dayLocalizedLabel = dLabel;
    [cornerView addSubview:dLabel];
    [dLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(timeLabel);
        make.bottom.equalTo(cornerView).offset(-12);
    }];
    UILabel *tLabel = [self createLabelWithText:Localized(@"times") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:12]];
    self.timesLocalizedLabel = tLabel;
    [cornerView addSubview:tLabel];
    [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(timesLabel);
        make.bottom.equalTo(cornerView).offset(-12);
    }];
    
    UIView * synview = [UIView new];
    synview.backgroundColor = UIColor.whiteColor;
    synview.layer.cornerRadius = 4;
    [self.view addSubview:synview];
    [synview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cornerView.mas_bottom).offset(8);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@40);
    }];
    UILabel * tipsLb = [UILabel new];
    tipsLb.text = Localized(@"Synchronous door lock status");
    tipsLb.textColor = KDSRGBColor(44, 44, 44);
    tipsLb.font = [UIFont systemFontOfSize:12];
    tipsLb.textAlignment = NSTextAlignmentLeft;
    [synview addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(synview.mas_left).offset(14);
        make.top.bottom.mas_equalTo(0);
        make.width.equalTo(@100);
    }];
    UIButton * synBtn = [UIButton new];
    [synBtn setTitle:Localized(@"syncRecord") forState:UIControlStateNormal];
    [synBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    synBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    synBtn.layer.cornerRadius = 11;
    synBtn.layer.borderWidth = 1;
    synBtn.layer.borderColor = KDSRGBColor(31, 150, 247).CGColor;
    [synview addSubview:synBtn];
    [synBtn addTarget:self action:@selector(synBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [synBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@80);
        make.height.equalTo(@25);
        make.right.mas_equalTo(synview.mas_right).offset(-8);
        make.centerY.mas_equalTo(synview.mas_centerY).offset(0);
    }];
    
    UIView *grayView = [UIView new];
    grayView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
    [self.view insertSubview:grayView belowSubview:cornerView];
    [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cornerView.mas_centerY);
        make.left.bottom.right.equalTo(self.view);
    }];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(synview.mas_bottom).offset(0);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
    }];
    self.tableView.rowHeight = 40;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.001)];
    self.tableView.sectionFooterHeight = 0.0001;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getUnlockRecord)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
}

///根据各属性创建一个label，返回的label已计算好bounds。alignment center.
- (UILabel *)createLabelWithText:(NSString *)text color:(UIColor *)color font:(UIFont *)font
{
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = color;
    label.font = font;
    label.textAlignment = NSTextAlignmentCenter;
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName : font}];
    label.bounds = CGRectMake(0, 0, ceil(size.width), ceil(size.height));
    return label;
}

/**
 *@brief 启动开锁/关锁各阶段动画。
 *@param stage 阶段，其中：1表示开锁过程动画，2表示开锁成功动画，3表示开锁失败动画，4表示关锁动画。当开锁失败或者关锁时移除视图。
 */
- (void)stagingLockOperationAnimation:(int)stage
{
    NSInteger gearTag = @"gearIV".hash, cMiddleTag = @"cMiddleIV".hash, cSmallTag = @"cSmallIV".hash;
     self.gearIV= [self.view viewWithTag:gearTag];//锯齿外圈
     self.cMiddleIV = [self.view viewWithTag:cMiddleTag];//中间视图的复制
     self.cSmallIV = [self.view viewWithTag:cSmallTag];//小视图的复制
    self.bigCircleIV.tag = 1;
    if (!self.gearIV)
    {
        self.gearIV = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"unlockGear78.png" ofType:nil]]];
        self.gearIV.tag = gearTag;
        self.gearIV.frame = self.middleCircleIV.frame;
        [self.view addSubview:self.gearIV];
        
        self.cMiddleIV = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"unlockMiddleCircle78.png" ofType:nil]]];
        self.cMiddleIV.tag = cMiddleTag;
        self.cMiddleIV.frame = self.middleCircleIV.frame;
        [self.view addSubview:self.cMiddleIV];
        
        self.cSmallIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"closedLock"]];
        self.cSmallIV.contentMode = UIViewContentModeScaleAspectFit;
        self.cSmallIV.tag = cSmallTag;
        self.cSmallIV.frame = self.smallCircleIV.frame;
        [self.view addSubview:self.cSmallIV];
        
        self.middleCircleIV.hidden = self.smallCircleIV.hidden = YES;
        [self.view bringSubviewToFront:self.zbLogoIV];
        [self.view bringSubviewToFront:self.actionLabel];
    }
    if (stage == 1)//开锁过程动画，初始化动画视图。
    {
        int capacity = 78;
        NSMutableArray *bigImages = [NSMutableArray arrayWithCapacity:capacity];
        NSMutableArray *gearImages = [NSMutableArray arrayWithCapacity:capacity];
        NSMutableArray *middleImages = [NSMutableArray arrayWithCapacity:capacity];
        for (int i = 0; i < capacity; ++i)
        {
            UIImage *bigImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"unlockBigCircle%d.png", i + 1] ofType:nil]];
            [bigImages addObject:bigImg];
            UIImage *gearImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"unlockGear%d.png", i + 1] ofType:nil]];
            [gearImages addObject:gearImg];
            UIImage *middleImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"unlockMiddleCircle%d.png", i + 1] ofType:nil]];
            [middleImages addObject:middleImg];
        }
        self.middleCircleIV.hidden = self.smallCircleIV.hidden = YES;
        self.bigCircleIV.animationImages = bigImages;
        self.bigCircleIV.animationDuration = bigImages.count * 0.04;
        self.bigCircleIV.animationRepeatCount = 1;

        [self.bigCircleIV startAnimating];
        
        self.gearIV.animationImages = gearImages;
        self.gearIV.animationRepeatCount = 1;
        self.gearIV.animationDuration = gearImages.count * 0.04;
        [self.gearIV startAnimating];
        
        self.cMiddleIV.animationImages = middleImages;
        self.cMiddleIV.animationRepeatCount = 1;
        self.cMiddleIV.animationDuration = middleImages.count * 0.04;
        [self.cMiddleIV startAnimating];
        
        [UIView animateWithDuration:capacity * 0.01 animations:^{
            self.zbLogoIV.transform = CGAffineTransformMakeScale(0.9, 0.9);
            self.zbLogoIV.alpha = 0.0;
            self.actionLabel.transform = CGAffineTransformMakeScale(0.9, 0.9);
            self.actionLabel.alpha = 0.0;
            self.cSmallIV.center = self.bigCircleIV.center;
        }];
        
        return;
    }
    
    if (self.gearIV.animating) [self.gearIV stopAnimating];
    if (self.cMiddleIV.animating) [self.cMiddleIV stopAnimating];
    if (self.bigCircleIV.animating) [self.bigCircleIV stopAnimating];
    self.gearIV.animationImages = nil;
    self.cMiddleIV.animationImages = nil;
    self.bigCircleIV.animationImages = nil;
    if (stage == 2)//开锁成功动画
    {
        self.stateLabel.text = Localized(@"door has been unlocked");
        self.actionLabel.alpha = 0.0;
        self.zbLogoIV.alpha = 0.0;
        int capacity = 25;
        NSMutableArray *successImages = [NSMutableArray arrayWithCapacity:capacity];
        for (int i = 54; i < capacity + 54; ++i)
        {
            UIImage *successImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"unlockSuccess%d.png", i] ofType:nil]];
            [successImages addObject:successImg];
        }
        self.cSmallIV.image = successImages.lastObject;
        self.cSmallIV.animationImages = successImages;
        self.cSmallIV.animationDuration = capacity * 0.04;
        self.cSmallIV.animationRepeatCount = 1;
        [self.cSmallIV startAnimating];
        return;
    }
    void(^stopAnimationAndRemoveViews)(void) = ^{
        if (self.cSmallIV.animating) [self.cSmallIV stopAnimating];
        self.cSmallIV.animationImages = nil;
        [self.cSmallIV removeFromSuperview];
        self.middleCircleIV.hidden = self.smallCircleIV.hidden = NO;
        [self.gearIV removeFromSuperview];
        [self.cMiddleIV removeFromSuperview];
        self.zbLogoIV.transform = self.actionLabel.transform = CGAffineTransformIdentity;
        self.zbLogoIV.alpha = self.actionLabel.alpha = 1.0;
        self.bigCircleIV.tag = 0;
    };
    if (stage == 3)//开锁失败动画
    {
        stopAnimationAndRemoveViews();
        return;
    }
    if (stage == 4)//关锁动画
    {
        self.stateLabel.text = Localized(@"door has been locked");
        self.cSmallIV.center = self.smallCircleIV.center;
        self.cSmallIV.bounds = CGRectZero;
        self.cSmallIV.image = [UIImage imageNamed:@"closedLock"];
        [UIView animateWithDuration:27 * 0.04 animations:^{
            self.cSmallIV.frame = self.smallCircleIV.frame;
        } completion:^(BOOL finished) {
            stopAnimationAndRemoveViews();
        }];
        return;
    }
}


#pragma mark - 控件等事件方法。
///长按中间的浅绿色视图开锁。为方便其它页面发起的通知开锁，sender传nil和手势共用一个方法。
- (void)tapGestureImageViewUnlock:(UITapGestureRecognizer *)sender
{
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:nil message:@"不可点击" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alerVC animated:YES completion:nil];
    [self performSelector:@selector(dismiss:) withObject:alerVC afterDelay:2.0];
    return;
}

-(void)synBtnClick:(UIButton *)sender
{
    [self getUnlockRecord];
}

///点击动态所在父视图进入开锁和报警记录详情页。
- (void)tapToViewDeviceDynamicDetails:(UITapGestureRecognizer *)sender
{
    KDSWFRecordDetailsVC * vc = [KDSWFRecordDetailsVC new];
    vc.lock = self.lock;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

///点击更多按钮查看更多记录。
- (void)moreButtonClick:(UIButton *)sender
{
    KDSWFRecordDetailsVC * vc = [KDSWFRecordDetailsVC new];
    vc.lock = self.lock;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 通知相关方法。

///收到更改了本地语言的通知，更新页面文字。
- (void)localeLanguageDidChange:(NSNotification *)noti
{
    self.lockState = self.lockState;
    self.guardianDayLocalizedLabel.text = Localized(@"guardianTime");
    self.guardianTimesLocalizedLabel.text = Localized(@"guardianTimes");
    self.dayLocalizedLabel.text = Localized(@"days");
    self.timesLocalizedLabel.text = Localized(@"times");
    [self.tableView reloadData];
}
///mqtt上报事件通知。
- (void)wifimqttEventNotification:(NSNotification *)noti
{
    MQTTSubEvent event = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
   if ([event isEqualToString:MQTTSubEventWifiUnlock]){
        if (![param[@"wfId"] isEqualToString:self.lock.wifiDevice.wifiSN]) return;
        [self setLockState:KDSLockStateUnlocked];
        [self getUnlockRecord];
        [self getUnlockTimes];
        int eventType = [param[@"eventType"] intValue]/*, uid = [param[@"userID"] intValue] */, eventSource = [param[@"eventSource"] intValue];
        if (eventType== 2)
        {
            //指纹、卡片开锁不区分是否是胁迫
            [KDSFTIndicator showNotificationWithTitle:Localized(@"Be careful") message:[NSString stringWithFormat:Localized(@"theLock%@UnlckWithMenace%@"), self.lock.wifiDevice.lockNickname ?: self.lock.wifiDevice.wifiSN, Localized((eventSource==0 ? @"password" : (eventSource==3 ? @"card"/*@"menaceCard"*/ : @"fingerprint"/*@"menaceFingerprint"*/)))] tapHandler:^{
            }];
        }
       return;
    }
    else if ([event isEqualToString:MQTTSubEventWifiLock])
    {
        if (![param[@"wfId"] isEqualToString:self.lock.wifiDevice.wifiSN]) return;
        if (self.lockState != KDSLockStateClosed){
           [self setLockState:KDSLockStateClosed];
        }
    }else if ([event isEqualToString:MQTTSubEventWifiLockStateChanged]){
        if (self.lock.state == KDSLockStateUnlocked) {
            return;
        }
        if (![param[@"wfId"] isEqualToString:self.lock.wifiDevice.wifiSN]) return;
        //timestamp
        self.lock.wifiDevice.defences = param[@"defences"];
        self.lock.wifiDevice.operatingMode = param[@"operatingMode"];
        self.lock.wifiDevice.safeMode = param[@"safeMode"];
        self.lock.wifiDevice.defences = param[@"defences"];
        self.lock.wifiDevice.volume = param[@"volume"];
        self.lock.wifiDevice.language = param[@"language"];
        self.lock.wifiDevice.faceStatus = param[@"faceStatus"];
        self.lock.wifiDevice.powerSave = param[@"powerSave"];
        ///目前wifi锁的模式：开锁状态>布防>反锁>安全>面容>节能
        if (self.lock.wifiDevice.powerSave.intValue == 1) {
            self.lock.state = KDSLockStateEnergy;
        }if (self.lock.wifiDevice.faceStatus.intValue == 1) {
            self.lock.state = KDSLockStateFaceTurnedOff;
        }if (self.lock.wifiDevice.safeMode.intValue == 1) {
            self.lock.state = KDSLockStateSecurityMode;
        }if (self.lock.wifiDevice.operatingMode.intValue == 1) {
            self.lock.state = KDSLockStateLockInside;
        }if (self.lock.wifiDevice.defences.intValue == 1) {
            self.lock.state = KDSLockStateDefence;
        }if (self.lock.wifiDevice.defences.intValue ==0 && self.lock.wifiDevice.operatingMode.intValue ==0 && self.lock.wifiDevice.safeMode.intValue == 0 && self.lock.wifiDevice.powerSave.intValue == 0 && self.lock.wifiDevice.faceStatus.intValue == 0) {//正常状态
            self.lock.state = KDSLockStateOnline;
            self.stateLabel.text = Localized(@"door has been locked");
        }
        [self setLockState:self.lock.state];
        self.updateTimeLb.text = [KDSTool timeStringFromTimestamp:param[@"timestamp"]];
        
    }
}


#pragma mark - Http相关方法。

///获取第一页的开锁记录。
- (void)getUnlockRecord
{
    void (^noRecord) (UITableView *) = ^(UITableView *tableView) {
        UILabel *label = [[UILabel alloc] initWithFrame:tableView.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        if (tableView == self.tableView) {
            label.text = Localized(@"noUnlockRecord,pleaseSync");
        }else{
            label.text = Localized(@"NoAlarmRecord");
        }
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        label.font = [UIFont systemFontOfSize:12];
        tableView.tableHeaderView = label;
    };
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"synchronizingRecord") toView:self.view];
    [[KDSHttpManager sharedManager] getWifiLockBindedDeviceOperationWithWifiSN:self.lock.wifiDevice.wifiSN index:1 success:^(NSArray<KDSWifiLockOperation *> * _Nonnull operations) {
        [hud hideAnimated:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.unlockRecordArr removeAllObjects];
           if (operations.count == 0)
           {
               self.tableView.mj_header.state = MJRefreshStateNoMoreData;
                noRecord(self.tableView);
               return;
           }
          [self.tableView.mj_footer resetNoMoreData];
           for (KDSWifiLockOperation * operation in operations)
           {
               operation.date = [self.dateFmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:operation.time]];
               [self.unlockRecordArr insertObject:operation atIndex:[operations indexOfObject:operation]];
           }
        [self reloadTableView:self.tableView];
        self.tableView.mj_header.state = MJRefreshStateIdle;
//        [MBProgressHUD showSuccess:Localized(@"syncComplete")];
    } error:^(NSError * _Nonnull error) {
         [hud hideAnimated:YES];
         [MBProgressHUD showSuccess:Localized(@"synchronizeFailed")];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         self.tableView.mj_header.state = MJRefreshStateIdle;
    } failure:^(NSError * _Nonnull error) {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [hud hideAnimated:YES];
         [MBProgressHUD showSuccess:Localized(@"synchronizeFailed")];
         self.tableView.mj_header.state = MJRefreshStateIdle;
    }];
    
}
/**
 *@abstract 刷新表视图，调用此方法前请确保开锁或者报警记录的属性数组内容已经更新。方法执行时会自动提取分组记录。
 *@param tableView 要刷新的表视图。
 */
- (void)reloadTableView:(UITableView *)tableView
{
    void (^noRecord) (UITableView *) = ^(UITableView *tableView) {
        UILabel *label = [[UILabel alloc] initWithFrame:tableView.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        if (tableView == self.tableView) {
            label.text = Localized(@"noUnlockRecord,pleaseSync");
        }else{
            label.text = Localized(@"NoAlarmRecord");
        }
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        label.font = [UIFont systemFontOfSize:12];
        tableView.tableHeaderView = label;
    };
    if (tableView == self.tableView)
    {
        [self.unlockRecordArr sortUsingComparator:^NSComparisonResult(KDSWifiLockOperation *  _Nonnull obj1, KDSWifiLockOperation *  _Nonnull obj2) {
            return obj1.time < obj2.time;
        }];
        NSMutableArray *sections = [NSMutableArray array];
        NSMutableArray *elements = [NSMutableArray array];
        __block NSString *date = nil;
        [self.unlockRecordArr enumerateObjectsUsingBlock:^(KDSWifiLockOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj.date componentsSeparatedByString:@" "].firstObject isEqualToString:date])
            {
                [elements addObject:obj];
            }
            else
            {
                date = [obj.date componentsSeparatedByString:@" "].firstObject;
                if (elements.count > 0) {
                   [sections addObject:elements.copy];
                }
                [elements removeAllObjects];
                [elements addObject:obj];
            }
        }];
        if (elements.count) [sections addObject:elements.copy];
        self.unlockRecordSectionArr = sections;
        if (self.unlockRecordArr.count == 0)
        {
            noRecord(self.tableView);
        }else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.01)];
                [self.tableView reloadData];
            });
        }
    }
}

///获取开锁次数，并更新页面。
- (void)getUnlockTimes
{
    [[KDSHttpManager sharedManager] getWifiLockBindedDeviceOperationCountWithUid:[KDSUserManager sharedManager].user.uid wifiSN:self.lock.wifiDevice.wifiSN index:1 success:^(int count) {
        self.timesLabel.text = @(count).stringValue;
    } error:nil failure:nil];
}

#pragma mark - UITableViewDelegate, UITableViewDataSourc
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.unlockRecordSectionArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.unlockRecordSectionArr[section].count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSHomePageLockStatusCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
   ///操作记录
       cell.alarmRecLabel.hidden = YES;
       cell.topLine.hidden = indexPath.row == 0;
       cell.bottomLine.hidden = indexPath.row == self.unlockRecordSectionArr[indexPath.section].count - 1;
       KDSWifiLockOperation *record = self.unlockRecordSectionArr[indexPath.section][indexPath.row];
       cell.timerLabel.text = record.date.length > 16 ? [record.date substringWithRange:NSMakeRange(11, 5)] : record.date;
       //type记录类型：1开锁 2关锁 3添加密钥 4删除密钥 5修改管理员密码 6自动模式 7手动模式 8常用模式切换 9安全模式切换 10反锁模式 11布防模式 12修改密码昵称 13添加分享用户 14删除分享用户
       //pwdType密码类型：0密码 3卡片 4指纹 8APP用户 9机械钥匙 10室内open键开锁 11室内感应把手开锁
    //开锁记录昵称（zigbee、蓝牙，都有昵称，么有昵称显示编号）
     cell.userNameLabel.text = @"";
           if (record.type == 1)
           {
               switch (record.pwdType) {
                   case 0:
                       cell.unlockModeLabel.text = Localized(@"密码");
                       cell.userNameLabel.text = record.userNickname ?: [NSString stringWithFormat:@"编号%02d",record.pwdNum];
                       break;
                   case 3:
                       cell.unlockModeLabel.text = Localized(@"卡片");
                       cell.userNameLabel.text = record.userNickname ?: [NSString stringWithFormat:@"编号%02d",record.pwdNum];
                       break;
                   case 4:
                       cell.unlockModeLabel.text = Localized(@"指纹");
                       cell.userNameLabel.text = record.userNickname ?: [NSString stringWithFormat:@"编号%02d",record.pwdNum];
                       break;
                   case 7:
                       cell.unlockModeLabel.text = Localized(@"面容识别");
                       cell.userNameLabel.text = record.userNickname ?: [NSString stringWithFormat:@"编号%02d",record.pwdNum];
                       break;
                   case 8:
                       cell.unlockModeLabel.text = Localized(@"appUnlock");
                       cell.userNameLabel.text = @"";
                       break;
                   case 9:
                       cell.userNameLabel.text = Localized(@"机械钥匙");
                       cell.unlockModeLabel.text = @"";
                       break;
                   case 10:
                       cell.userNameLabel.text = Localized(@"室内open键");
                       cell.unlockModeLabel.text = @"";
                       break;
                   case 11:
                       cell.userNameLabel.text = Localized(@"室内感应把手");
                       cell.unlockModeLabel.text = @"";
                       break;
                       
                   default:
                       cell.unlockModeLabel.text = @"开锁";
                       cell.userNameLabel.text = record.userNickname ?: [NSString stringWithFormat:@"编号%02d",record.pwdNum];
                       break;
               }
               if (record.pwdNum == 252) {
                   cell.userNameLabel.text = @"临时密码开锁";
                   cell.unlockModeLabel.text = @"";
               }else if (record.pwdNum == 250){
                    cell.userNameLabel.text = @"临时密码开锁";
                    cell.unlockModeLabel.text = @"";
               }else if (record.pwdNum == 253){
                    cell.userNameLabel.text = @"访客密码开锁";
                    cell.unlockModeLabel.text = @"";
               }else if (record.pwdNum == 254){
                    cell.userNameLabel.text = @"管理员密码开锁";
                    cell.unlockModeLabel.text = @"";
               }
               
           }else if (record.type == 2)
           {
               cell.unlockModeLabel.text = @"";
               cell.userNameLabel.text = @"门锁已上锁";
           }else if (record.type == 3){
               switch (record.pwdType) {
                   case 0:
                       cell.userNameLabel.text = [NSString stringWithFormat:@"门锁添加编号%02d密码",record.pwdNum];
                       break;
                   case 4:
                       cell.userNameLabel.text = [NSString stringWithFormat:@"门锁添加编号%02d指纹",record.pwdNum];
                       break;
                   case 3:
                       cell.userNameLabel.text = [NSString stringWithFormat:@"门锁添加编号%02d卡片",record.pwdNum];
                       break;
                    case 7:
                       cell.userNameLabel.text = [NSString stringWithFormat:@"门锁添加编号%02d面容识别",record.pwdNum];
                       break;
       
                   default:
                       cell.userNameLabel.text = @"添加密钥";
                       break;
               }
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 4){
               switch (record.pwdType) {
                   case 0:
                   {
                      if (record.pwdNum == 255) {
                           cell.userNameLabel.text = [NSString stringWithFormat:@"门锁删除所有密码"];
                       }else{
                           cell.userNameLabel.text = [NSString stringWithFormat:@"门锁删除编号%02d密码",record.pwdNum];
                       }
                   }
                       break;
                   case 4:
                   {
                       if (record.pwdNum == 255) {
                           cell.userNameLabel.text = [NSString stringWithFormat:@"门锁删除所有指纹"];
                       }else{
                           cell.userNameLabel.text = [NSString stringWithFormat:@"门锁删除编号%02d指纹",record.pwdNum];
                       }
                   }
                       break;
                   case 3:
                   {
                       if (record.pwdNum == 255) {
                           cell.userNameLabel.text = [NSString stringWithFormat:@"门锁删除所有卡片"];
                       }else{
                           cell.userNameLabel.text = [NSString stringWithFormat:@"门锁删除编号%02d卡片",record.pwdNum];
                       }
                   }
                       break;
                    case 7:
                   {
                       if (record.pwdNum == 255) {
                           cell.userNameLabel.text = [NSString stringWithFormat:@"门锁删除所有面容识别"];
                       }else{
                           cell.userNameLabel.text = [NSString stringWithFormat:@"门锁删除编号%02d面容识别",record.pwdNum];
                       }
                   }
                       break;
                   default:
                       cell.userNameLabel.text = @"删除密钥";
                       break;
               }
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 5){
               cell.userNameLabel.text = @"门锁修改管理员密码";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 6){
               cell.userNameLabel.text = @"门锁切换自动模式";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 7){
               cell.userNameLabel.text = @"门锁切换手动模式";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 8){
               cell.userNameLabel.text = @"门锁切换常用模式";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 9){
               cell.userNameLabel.text = @"门锁切换安全模式";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 10){
               cell.userNameLabel.text = @"门锁启动反锁模式";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 11){
               cell.userNameLabel.text = @"门锁启动布防模式";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 12){
               ///更改01密码昵称为妈妈
               switch (record.pwdType) {
                   case 0:
                       cell.unlockModeLabel.text = [NSString stringWithFormat:@"更改编号%02d密码昵称为%@",record.pwdNum,record.pwdNickname];
                       break;
                   case 3:
                       cell.unlockModeLabel.text = [NSString stringWithFormat:@"更改编号%02d卡片昵称为%@",record.pwdNum,record.pwdNickname];
                       break;
                   case 4:
                       cell.unlockModeLabel.text = [NSString stringWithFormat:@"更改编号%02d指纹昵称为%@",record.pwdNum,record.pwdNickname];
                       break;
                    case 7:
                       cell.unlockModeLabel.text = [NSString stringWithFormat:@"更改编号%02d面容识别昵称为%@",record.pwdNum,record.pwdNickname];
                       break;
                   default:
                       break;
               }
               cell.userNameLabel.text = record.userNickname;
           }else if (record.type == 13){
               ///添加明明为门锁授权使用
               cell.unlockModeLabel.text = [NSString stringWithFormat:@"授权%@使用门锁",record.shareUserNickname ?: record.shareAccount];
               cell.userNameLabel.text = record.userNickname;
           }else if (record.type == 14){
               ///删除明明为门锁授权使用
               cell.unlockModeLabel.text = [NSString stringWithFormat:@"删除%@使用门锁",record.shareUserNickname ?: record.shareAccount];
               cell.userNameLabel.text = record.userNickname;
           }else if (record.type == 15){
               ///修改管理指纹
               cell.userNameLabel.text = @"门锁修改管理员指纹";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 16){
               ///16添加管理员指纹
               cell.userNameLabel.text = @"门锁添加管理员指纹";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 17){
               ///17启动节能模式
               cell.userNameLabel.text = @"门锁启动节能模式";
               cell.unlockModeLabel.text = @"";
           }else if (record.type == 18){
               ///18关闭节能模式
               cell.userNameLabel.text = @"门锁关闭节能模式";
               cell.unlockModeLabel.text = @"";
           }else{
               cell.userNameLabel.text = Localized(@"未知操作");
               cell.unlockModeLabel.text = @"";
           }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 40)];
    headerView.backgroundColor = UIColor.clearColor;
    ///线
    UIView * line = [UIView new];
    line.backgroundColor = KDSRGBColor(216, 216, 216);
    line.frame = CGRectMake(15, 0, KDSScreenWidth-30, 1);
    line.hidden = section == 0;
    [headerView addSubview:line];
    
    ///显示日期：今天、昨天、///开锁时间:（yyyy-MM-dd ）
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 20)];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:titleLabel];
    NSString *todayStr = [[self.dateFmt stringFromDate:[NSDate date]] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSInteger today = [todayStr substringToIndex:8].integerValue;
    NSString *dateStr = self.unlockRecordSectionArr[section].firstObject.date;
    NSInteger date = [[dateStr stringByReplacingOccurrencesOfString:@"-" withString:@""] substringToIndex:8].integerValue;
    if (today == date)
    {
        titleLabel.text = Localized(@"today");
    }
    else if (today - date == 1)
    {
        titleLabel.text = Localized(@"yesterday");
    }
    else
    {
        titleLabel.text = [[dateStr componentsSeparatedByString:@" "].firstObject stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    }
    ///更多按钮
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(KDSScreenWidth-80, 10, 40, 20)];
    [btn setTitleColor:KDSRGBColor(17, 117, 231) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    btn.backgroundColor = [UIColor clearColor];
    btn.hidden = section != 0;
    [btn setTitle:Localized(@"more") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:btn];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (void)dismiss:(UIAlertController *)alert{
    [alert dismissViewControllerAnimated:YES completion:nil];
}


@end
