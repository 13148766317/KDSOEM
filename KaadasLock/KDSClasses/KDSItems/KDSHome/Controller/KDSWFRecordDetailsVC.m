//
//  KDSWFRecordDetailsVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/19.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSWFRecordDetailsVC.h"
#import "KDSMQTT.h"
#import "KDSDBManager+GW.h"
#import "UIButton+Color.h"
#import "MJRefresh.h"
#import "KDSHomePageLockStatusCell.h"
#import "KDSHttpManager+WifiLock.h"

@interface KDSWFRecordDetailsVC ()<UITableViewDelegate, UITableViewDataSource>

///开锁记录按钮。
@property (nonatomic, strong) UIButton *unlockRecBtn;
///报警记录按钮。
@property (nonatomic, strong) UIButton *alarmRecBtn;
///横向滚动的滚动视图，装着开锁记录和报警记录的表视图。
@property (nonatomic, strong) UIScrollView *scrollView;
///显示开锁记录的表视图。
@property (nonatomic, strong) UITableView *unlockTableView;
///显示报警记录的表视图。
@property (nonatomic, strong) UITableView *alarmTableView;
///服务器请求回来的开锁记录数组。
@property (nonatomic, strong) NSMutableArray<KDSWifiLockOperation *> *unlockRecordArr;
///服务器请求回来开锁记录数组后按日期(天)提取的记录分组数组。
@property (nonatomic, strong) NSArray<NSArray<KDSWifiLockOperation *> *> *unlockRecordSectionArr;
///本地存储的报警记录数组。
@property (nonatomic, strong) NSMutableArray<KDSWifiLockAlarmModel *> *alarmRecordArr;
///本地存储报警记录数组后按日期(天)提取的记录分组数组。
@property (nonatomic, strong) NSArray<NSArray<KDSWifiLockAlarmModel *> *> *alarmRecordSectionArr;
///开锁记录页数，初始化1.
@property (nonatomic, assign) int unlockIndex;
///报警记录页数，初始化1.
@property (nonatomic, assign) int alarmIndex;
///获取报警记录时转的菊花。
@property (nonatomic, strong) UIActivityIndicatorView *alarmActivity;
///获取开锁记录时转的菊花。
@property (nonatomic, strong) UIActivityIndicatorView *unlockActivity;
///格式yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong) NSDateFormatter *fmt;

@end

@implementation KDSWFRecordDetailsVC

#pragma mark - getter setter
- (NSMutableArray<KDSWifiLockOperation *> *)unlockRecordArr
{
    if (!_unlockRecordArr)
    {
        _unlockRecordArr = [NSMutableArray array];
    }
    return _unlockRecordArr;
}

- (NSMutableArray<KDSWifiLockAlarmModel *> *)alarmRecordArr
{
    if (!_alarmRecordArr)
    {
        _alarmRecordArr = [NSMutableArray array];
    }
    return _alarmRecordArr;
}

- (UIActivityIndicatorView *)alarmActivity
{
    if (!_alarmActivity)
    {
        _alarmActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGPoint center = CGPointMake(kScreenWidth * 1.5, self.scrollView.bounds.size.height / 2.0);;
        _alarmActivity.center = center;
        [self.scrollView addSubview:_alarmActivity];
    }
    return _alarmActivity;
}
- (UIActivityIndicatorView *)unlockActivity
{
    if (!_unlockActivity)
    {
        _unlockActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGPoint center = CGPointMake(kScreenWidth / 2.0, self.scrollView.bounds.size.height / 2.0);
        _unlockActivity.center = center;
        [self.scrollView addSubview:_unlockActivity];
    }
    return _unlockActivity;
}


- (NSDateFormatter *)fmt
{
    if (!_fmt)
    {
        _fmt = [[NSDateFormatter alloc] init];
        _fmt.timeZone = [NSTimeZone localTimeZone];
        _fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _fmt;
}
#pragma mark - 生命周期、界面设置相关方法。
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.unlockIndex = 1;
    self.alarmIndex = 1;
    [self setupUI];
    [self loadNewUnlockRecord];
    [self loadNewAlarmRecord];
}

- (void)viewDidLayoutSubviews
{
    if (CGRectIsEmpty(self.unlockTableView.frame))
    {
        self.scrollView.contentSize = CGSizeMake(kScreenWidth * 2, self.scrollView.bounds.size.height);
        CGRect frame = self.scrollView.bounds;
        frame.origin.x += 10;
        frame.size.width -= 20;
        self.unlockTableView.frame = frame;
        frame.origin.x += kScreenWidth;
        self.alarmTableView.frame = frame;
    }
    
}

- (void)setupUI
{
    //导航栏位置的标题和关闭按钮。
    UIView *bgView = nil;
    if (self.navigationController)
    {
        self.navigationTitleLabel.text = Localized(@"deviceStatus");
    }
    else
    {
        bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kStatusBarHeight + kNavBarHeight)];
        bgView.backgroundColor = UIColor.whiteColor;
        [self.view addSubview:bgView];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, kNavBarHeight)];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = Localized(@"deviceStatus");
        [self.view addSubview:titleLabel];
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *closeImg = [UIImage imageNamed:@"返回"];
        [closeBtn setImage:closeImg forState:UIControlStateNormal];
        closeBtn.frame = CGRectMake(0, kStatusBarHeight, 44, 44);
        [closeBtn addTarget:self action:@selector(clickCloseBtnDismissController:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:closeBtn];
    }
    
    //顶部功能选择按钮
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(bgView.frame) + 10, kScreenWidth-30, 44)];
    view.backgroundColor = UIColor.whiteColor;
    view.layer.cornerRadius = 22;
    [self.view addSubview:view];
    self.unlockRecBtn = [UIButton new];
    [self.unlockRecBtn setTitle:Localized(@"OpRecord") forState:UIControlStateNormal];
    self.unlockRecBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.unlockRecBtn.adjustsImageWhenHighlighted = NO;
    [self.unlockRecBtn addTarget:self action:@selector(clickRecordBtnAdjustScrollViewContentOffset:) forControlEvents:UIControlEventTouchUpInside];
    self.unlockRecBtn.selected = YES;
    self.unlockRecBtn.layer.masksToBounds = YES;
    self.unlockRecBtn.layer.cornerRadius = 22;
    [view addSubview:self.unlockRecBtn];
    self.alarmRecBtn = [UIButton new];
    [self.alarmRecBtn setTitle:Localized(@"alarmRecord") forState:UIControlStateNormal];
    self.alarmRecBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.alarmRecBtn.adjustsImageWhenHighlighted = NO;
    [self.alarmRecBtn addTarget:self action:@selector(clickRecordBtnAdjustScrollViewContentOffset:) forControlEvents:UIControlEventTouchUpInside];
    [self.unlockRecBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    [self.unlockRecBtn setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.unlockRecBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.unlockRecBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [self.alarmRecBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    [self.alarmRecBtn setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.alarmRecBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.alarmRecBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    self.alarmRecBtn.layer.masksToBounds = YES;
    self.alarmRecBtn.layer.cornerRadius = 22;
    [view addSubview:self.alarmRecBtn];
    CGFloat width = (KDSScreenWidth-30)/2;
    [self.unlockRecBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.top.equalTo(view);
        make.width.mas_equalTo(@(width));
        
    }];
    [self.alarmRecBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.top.equalTo(view);
        make.width.mas_equalTo(@(width));
        
    }];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    self.unlockTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.unlockTableView.showsVerticalScrollIndicator = NO;
    self.unlockTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.unlockTableView.dataSource = self;
    self.unlockTableView.delegate = self;
    self.unlockTableView.backgroundColor = self.view.backgroundColor;
    self.unlockTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.01)];
    self.unlockTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewUnlockRecord)];
    self.unlockTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreUnlockRecord)];
    [self.unlockTableView registerNib:[UINib nibWithNibName:@"KDSHomePageLockStatusCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"KDSHomePageLockStatusCell"];
    [self.scrollView addSubview:self.unlockTableView];
    self.alarmTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.alarmTableView.showsVerticalScrollIndicator = NO;
    self.alarmTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.alarmTableView.dataSource = self;
    self.alarmTableView.delegate = self;
    self.alarmTableView.backgroundColor = self.view.backgroundColor;
    self.alarmTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.01)];
    self.alarmTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewAlarmRecord)];
    self.alarmTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreAlarmRecord)];
    [self.alarmTableView registerNib:[UINib nibWithNibName:@"KDSHomePageLockStatusCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"KDSHomePageLockStatusCell"];
    [self.scrollView addSubview:self.alarmTableView];
    self.alarmTableView.rowHeight = self.unlockTableView.rowHeight = 40;
    if (@available(iOS 11.0, *)) {
        self.unlockTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.alarmTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
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
        if (tableView == self.unlockTableView) {
            label.text = Localized(@"noUnlockRecord");
        }else{
            label.text = Localized(@"NoAlarmRecord");
        }
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        label.font = [UIFont systemFontOfSize:12];
        tableView.tableHeaderView = label;
    };
    if (tableView == self.unlockTableView)
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
            noRecord(self.unlockTableView);
        }else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.unlockTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.01)];
                [self.unlockTableView reloadData];
            });
        }
    }
    else
    {
        NSMutableArray *sections = [NSMutableArray array];
        NSMutableArray<KDSWifiLockAlarmModel *> *section = [NSMutableArray array];
        __block NSString *date = nil;
        [self.alarmRecordArr sortUsingComparator:^NSComparisonResult(KDSWifiLockAlarmModel *  _Nonnull obj1, KDSWifiLockAlarmModel *  _Nonnull obj2) {
            if (obj1.time>0 && obj2.time>0)
            {
                return obj2.time < obj1.time ? NSOrderedAscending : NSOrderedDescending;
            }
            else
            {
                return [obj2.date compare:obj1.date];
            }
        }];
        [self.alarmRecordArr enumerateObjectsUsingBlock:^(KDSWifiLockAlarmModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!date)
            {
                date = [obj.date componentsSeparatedByString:@" "].firstObject;
                [section addObject:obj];
            }
            else if ([date isEqualToString:[obj.date componentsSeparatedByString:@" "].firstObject])
            {
                [section addObject:obj];
            }
            else
            {
                [sections addObject:[NSArray arrayWithArray:section]];
                [section removeAllObjects];
                date = [obj.date componentsSeparatedByString:@" "].firstObject;
                [section addObject:obj];
            }
        }];
        [sections addObject:[NSArray arrayWithArray:section]];
        self.alarmRecordSectionArr = [NSArray arrayWithArray:sections];
        if (self.alarmRecordArr.count == 0)
        {
            noRecord(self.alarmTableView);
        }
        else
        {
            self.alarmTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.01)];
        }
        [self.alarmTableView reloadData];
    }
}

#pragma mark - 控件等事件方法。
///点击开锁记录、预警信息按钮调整滚动视图的偏移，切换页面。
- (void)clickRecordBtnAdjustScrollViewContentOffset:(UIButton *)sender
{
    if (sender.selected) return;
    self.unlockRecBtn.selected = self.alarmRecBtn.selected = NO;
    sender.selected = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.contentOffset = CGPointMake(sender == self.unlockRecBtn ? 0 : kScreenWidth, 0);
    }];
}

///dismiss控制器。
- (void)clickCloseBtnDismissController:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MQTT网络请求相关方法。
///获取第一页的开锁记录。
- (void)loadNewUnlockRecord
{
    [[KDSHttpManager sharedManager] getWifiLockBindedDeviceOperationWithWifiSN:self.lock.wifiDevice.wifiSN index:1 success:^(NSArray<KDSWifiLockOperation *> * _Nonnull operations) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
           if (operations.count == 0)
           {
               self.unlockTableView.mj_header.state = MJRefreshStateNoMoreData;
               return;
           }
          [self.unlockTableView.mj_footer resetNoMoreData];
           BOOL contain = NO;
           for (KDSWifiLockOperation * operation in operations)
           {
               if ([self.unlockRecordArr containsObject:operation])
               {
                   contain = YES;
                   break;
               }
               operation.date = [self.fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:operation.time]];
               [self.unlockRecordArr insertObject:operation atIndex:[operations indexOfObject:operation]];
           }
           if (!contain)
           {
               [self.unlockRecordArr removeAllObjects];
               [self.unlockRecordArr addObjectsFromArray:operations];
           }
        [self reloadTableView:self.unlockTableView];
        self.unlockTableView.mj_header.state = MJRefreshStateIdle;
    } error:^(NSError * _Nonnull error) {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         self.unlockTableView.mj_header.state = MJRefreshStateIdle;
    } failure:^(NSError * _Nonnull error) {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         self.unlockTableView.mj_header.state = MJRefreshStateIdle;
    }];
    
}

///获取更多开锁记录。
- (void)loadMoreUnlockRecord
{
    int page = self.unlockIndex + 1;
    [[KDSHttpManager sharedManager] getWifiLockBindedDeviceOperationWithWifiSN:self.lock.wifiDevice.wifiSN index:page success:^(NSArray<KDSWifiLockOperation *> * _Nonnull operations) {
        if (operations.count == 0)
        {
            self.unlockTableView.mj_footer.state = MJRefreshStateNoMoreData;
            return;
        }
        self.unlockTableView.mj_footer.state = MJRefreshStateIdle;
        self.unlockIndex++;
        for (KDSWifiLockOperation *operation in operations)
        {
            if ([self.unlockRecordArr containsObject:operation]) continue;
            operation.date = [self.fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:operation.time]];
            [self.unlockRecordArr addObject:operation];
        }
        [self reloadTableView:self.unlockTableView];
    } error:^(NSError * _Nonnull error) {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         self.unlockTableView.mj_footer.state = MJRefreshStateIdle;
    } failure:^(NSError * _Nonnull error) {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         self.unlockTableView.mj_footer.state = MJRefreshStateIdle;
    }];
}

///获取第一页的报警记录。
- (void)loadNewAlarmRecord
{
    [[KDSHttpManager sharedManager] getWifiLockBindedDeviceAlarmRecordWithWifiSN:self.lock.wifiDevice.wifiSN index:1 success:^(NSArray<KDSWifiLockAlarmModel *> * _Nonnull models) {
        if (models.count == 0)
        {
            self.alarmTableView.mj_header.state = MJRefreshStateNoMoreData;
            return;
        }
        [self.alarmTableView.mj_footer resetNoMoreData];
        BOOL contain = NO;
        for (KDSWifiLockAlarmModel * alarm in models)
        {
            if ([self.alarmRecordArr containsObject:alarm])
            {
                contain = YES;
                break;
            }
            alarm.date = [self.fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:alarm.time]];
            [self.alarmRecordArr insertObject:alarm atIndex:[models indexOfObject:alarm]];
        }
        if (!contain)
        {
            [self.alarmRecordArr removeAllObjects];
            [self.alarmRecordArr addObjectsFromArray:models];
        }
        [self reloadTableView:self.alarmTableView];
        self.alarmTableView.mj_header.state = MJRefreshStateIdle;
    } error:^(NSError * _Nonnull error) {
        self.alarmTableView.mj_header.state = MJRefreshStateIdle;
    } failure:^(NSError * _Nonnull error) {
        self.alarmTableView.mj_header.state = MJRefreshStateIdle;
    }];
}
///上拉报警记录表视图加载新的报警记录。
- (void)loadMoreAlarmRecord
{
    [[KDSHttpManager sharedManager] getWifiLockBindedDeviceAlarmRecordWithWifiSN:self.lock.wifiDevice.wifiSN index:self.alarmIndex + 1 success:^(NSArray<KDSWifiLockAlarmModel *> * _Nonnull models) {
         if (models.count == 0)
        {
            self.alarmTableView.mj_footer.state = MJRefreshStateNoMoreData;
            return;
        }
        self.alarmTableView.mj_footer.state = MJRefreshStateIdle;
        self.alarmIndex++;
        for (KDSWifiLockAlarmModel *model in models)
        {
            if ([self.alarmRecordArr containsObject:model]) continue;
            model.date = [self.fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.time]];
            [self.alarmRecordArr addObject:model];
        }
        [self reloadTableView:self.alarmTableView];
        
    } error:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.alarmTableView.mj_footer.state = MJRefreshStateIdle;
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.alarmTableView.mj_footer.state = MJRefreshStateIdle;
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView)
    {
        self.unlockRecBtn.selected = scrollView.contentOffset.x == 0;
        self.alarmRecBtn.selected = !self.unlockRecBtn.selected;
        
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.unlockTableView)
    {
        return self.unlockRecordSectionArr.count;
    }
    else
    {
        return self.alarmRecordSectionArr.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.unlockTableView)
    {
        return self.unlockRecordSectionArr[section].count;
    }
    else
    {
        return self.alarmRecordSectionArr[section].count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSHomePageLockStatusCell * cell = [tableView dequeueReusableCellWithIdentifier:@"KDSHomePageLockStatusCell"];
    if (tableView == self.unlockTableView)
    {
        ///操作记录
        cell.alarmRecLabel.hidden = YES;
        cell.topLine.hidden = indexPath.row == 0;
        cell.bottomLine.hidden = indexPath.row == self.unlockRecordSectionArr[indexPath.section].count - 1;
        KDSWifiLockOperation *record = self.unlockRecordSectionArr[indexPath.section][indexPath.row];
        cell.timerLabel.text = record.date.length > 16 ? [record.date substringWithRange:NSMakeRange(11, 5)] : record.date;
        //type记录类型：1开锁 2关锁 3添加密钥 4删除密钥 5修改管理员密码 6自动模式 7手动模式 8常用模式切换 9安全模式切换 10反锁模式 11布防模式
        //pwdType密码类型：1密码 2指纹 3卡片 4APP用户
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
    }
    else
    {
        cell.topLine.hidden = indexPath.row == 0;
        cell.bottomLine.hidden = indexPath.row == self.alarmRecordSectionArr[indexPath.section].count - 1;
        cell.alarmRecLabel.hidden = NO;
        cell.userNameLabel.hidden = YES;
        cell.unlockModeLabel.hidden = YES;
        cell.dynamicImageView.image = [UIImage imageNamed:@"Alert message_icon 拷贝"];
        KDSWifiLockAlarmModel *m = self.alarmRecordSectionArr[indexPath.section][indexPath.row];
        cell.timerLabel.text = m.date.length > 16 ? [m.date substringWithRange:NSMakeRange(11, 5)] :m.date;
        switch (m.type) {
            case 1://锁定报警（输入错误密码或指纹或卡片超过 10 次就报 警系统锁定）
                cell.alarmRecLabel.text = @"您的门锁错误验证多次，门锁系统锁定100秒！";
                break;
            case 2:// 劫持报警（输入防劫持密码或防劫持指纹开锁就报警）
                cell.alarmRecLabel.text = @"有人使用劫持密码开启门锁，赶紧联系或报警";
                break;
            case 3:// 三次错误报警
                cell.alarmRecLabel.text = @"您的智能锁已多次验证开门失败，请回家或联系保安查看";
                break;
            case 4:// 防撬报警（锁被撬开）
                cell.alarmRecLabel.text = @"已监测到您的门锁被撬，请联系家人或小区保安";
                break;
            case 8:// 机械钥匙报警（使用机械钥匙开锁）
                cell.alarmRecLabel.text = @"门锁正在被机械钥匙开启，请回家或联系保安查看";
                break;
            case 16:// 低电压报警（电池电量不足）
                cell.alarmRecLabel.text = @"您的门锁电量过低，请及时更换";
                break;
            case 32:// 锁体异常报警（旧:门锁不上报警）
                cell.alarmRecLabel.text = @"您的门锁有故障，请注意";
                break;
            case 64:// 门锁布防报警
                cell.alarmRecLabel.text = @"您的门锁处于布防状态，有从门内开锁情况";
                break;
            case 128://低电量关人脸
                cell.alarmRecLabel.text = @"您的智能门锁面容识别已关闭，如需重新开启面容识别，请更换电池";
                break;
                
            default:
                break;
        }
    }
    return cell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 40)];
    headerView.backgroundColor = self.view.backgroundColor;
    
    UIView * line = [UIView new];
    line.backgroundColor = KDSRGBColor(216, 216, 216);
    line.frame = CGRectMake(10, 0, KDSScreenWidth-20, 1);
    line.hidden = section == 0;
    [headerView addSubview:line];
    
    ///显示日期：今天、昨天、///开锁时间:（yyyy-MM-dd ）
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 20)];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:titleLabel];

    NSString *todayStr = [[self.fmt stringFromDate:[NSDate date]] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSInteger today = [todayStr substringToIndex:8].integerValue;
    NSString *dateStr = nil;
    if (tableView == self.unlockTableView)
    {
        dateStr = self.unlockRecordSectionArr[section].firstObject.date;
    }
    else
    {
        dateStr = self.alarmRecordSectionArr[section].firstObject.date;
    }
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
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}



@end
