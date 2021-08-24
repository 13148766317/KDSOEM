//
//  KDSAddDeviceVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/6/25.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAddDeviceVC.h"
#import "SYAlertView.h"
#import "KDSAddGWVCOne.h"
#import "KDSAddCateyeNewVC.h"
#import "KDSBindingGatewayVC.h"
#import "KDSBleBindVC.h"
#import <AVFoundation/AVFoundation.h>
#import "KDSAddDeviceListCell.h"
#import "KDSAddRYGWVC.h"
#import "KDSAddZeroFireSingleStep1VC.h"
#import "RHScanViewController.h"
#import "KDSAddWiFiLockFatherVC.h"


static NSString * const deviceListCellId = @"smarkHomeDevice";

@interface KDSAddDeviceVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

///添加智能锁（蓝牙、zigbee）的父视图
@property (nonatomic,strong)UIView *addLockSupView;
///锁的图标
@property (nonatomic,strong)UIImageView * lockIconImg;
///添加蓝牙锁按钮
@property (nonatomic,strong)UIButton * addBleLockBtn;
///添加zigbee锁按钮
@property (nonatomic,strong)UIButton * addZigBeeLockBtn;
///添加wifi锁按钮
@property (nonatomic,strong)UIButton * addWifiLockBtnBtn;
@property (nonatomic,strong)UIView * line;
@property (nonatomic,strong)UIView * line1;
///其他智能家居提示语
@property (nonatomic,strong)UILabel * tipsLb;
///用来展示其他智能家居列表
@property (nonatomic,readwrite,strong)UICollectionView * collectionView;
///点击添加锁的弹出视图
//@property (nonatomic,strong)KDSAddLockActionSheetView * actionSheetView;
@property (nonatomic,strong)SYAlertView *alertView;
@property (nonatomic,strong)NSArray * deviceNameArray;
@property (nonatomic,strong)NSArray * deviceImgArray;

@end

@implementation KDSAddDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"addDevice");
    [self.view addSubview:self.addLockSupView];
    [self.addLockSupView addSubview:self.lockIconImg];
    [self.addLockSupView addSubview:self.addBleLockBtn];
    [self.addLockSupView addSubview:self.addZigBeeLockBtn];
    [self.addLockSupView addSubview:self.addWifiLockBtnBtn];
    [self.addLockSupView addSubview:self.line];
    [self.addLockSupView addSubview:self.line1];
    [self.view addSubview:self.tipsLb];
    [self.view addSubview:self.collectionView];
    // 注册
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([KDSAddDeviceListCell class]) bundle:nil] forCellWithReuseIdentifier:deviceListCellId];
   
//    self.deviceNameArray = @[@"猫 眼",@"RG4300",@"GW6030",@"GW6010",@"零火单键",@"零火双键"];
    self.deviceNameArray = @[@"猫 眼",@"GW6032",@"GW6010"];
//    self.deviceImgArray  = @[@"cateye_pic",@"RG4300Img",@"GW6030Img",@"GW6010Img",@"ZeroFireSingleBondImg",@"ZeroFireDoubleBondImg"];
    self.deviceImgArray  = @[@"cateye_pic",@"GW6030Img",@"GW6010Img"];
    
    UIButton *scancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    scancleBtn.frame = CGRectMake(KDSScreenWidth - 44, kStatusBarHeight, 44, 44);
    scancleBtn.backgroundColor = UIColor.clearColor;
    [scancleBtn.widthAnchor constraintEqualToConstant:30].active = YES;
    [scancleBtn.heightAnchor constraintEqualToConstant:30].active = YES;
    [scancleBtn setImage:[UIImage imageNamed:@"scancleBlackImg"] forState:UIControlStateNormal];
    [scancleBtn addTarget:self action:@selector(scancleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:scancleBtn];

    [self setUI];
}


-(void)setUI{
    
    ///添加锁的父视图
    [self.addLockSupView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.top.mas_equalTo(self.view.mas_top).offset(15);
        make.height.mas_equalTo(248);
    }];
    [self.tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.addLockSupView.mas_bottom).offset(20);
        make.right.equalTo(self.view);
        make.left.mas_equalTo(self.view.mas_left).offset(18);
        make.height.equalTo(@20);
    }];
    [self.lockIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(159);
        make.width.mas_equalTo(129);
        make.centerX.mas_equalTo(self.addLockSupView.mas_centerX).offset(0);
        make.top.mas_equalTo(self.addLockSupView.mas_top).offset(12);
    }];
    [self.addBleLockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@((KDSScreenWidth-30)/3));
        make.height.equalTo(@40);
        make.left.mas_equalTo(self.addLockSupView.mas_left).offset(0);
        make.bottom.mas_equalTo(self.addLockSupView.mas_bottom).offset(-10);
    }];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@1);
        make.height.equalTo(@33);
        make.left.mas_equalTo(self.addBleLockBtn.mas_right).offset(0);
        make.bottom.mas_equalTo(self.addLockSupView.mas_bottom).offset(-12);
    }];
    [self.addWifiLockBtnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@((KDSScreenWidth-30)/3));
        make.height.equalTo(@40);
        make.left.mas_equalTo(self.addBleLockBtn.mas_right).offset(0);
        make.bottom.mas_equalTo(self.addLockSupView.mas_bottom).offset(-10);
    }];
    [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@1);
        make.height.equalTo(@33);
        make.left.mas_equalTo(self.addWifiLockBtnBtn.mas_right).offset(0);
        make.bottom.mas_equalTo(self.addLockSupView.mas_bottom).offset(-12);
    }];
    [self.addZigBeeLockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@((KDSScreenWidth-30)/3));
        make.height.equalTo(@40);
        make.left.mas_equalTo(self.addWifiLockBtnBtn.mas_right).offset(0);
        make.bottom.mas_equalTo(self.addLockSupView.mas_bottom).offset(-10);
    }];
    ////添加猫眼、网关父视图
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.top.mas_equalTo(self.tipsLb.mas_bottom).offset(15);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(17));
    }];
    
}
- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
}

#pragma mark - getter

- (SYAlertView *)alertView
{
    if (_alertView == nil) {
        _alertView = [[SYAlertView alloc] init];
        _alertView.isAnimation = YES;
        _alertView.userInteractionEnabled = YES;
    }
    return _alertView;
}
#pragma mark 点击事件

-(void)scancleBtnAction:(UIButton *)sender
{
    ///鉴权相机权限
    RHScanViewController *vc = [RHScanViewController new];
    vc.isOpenInterestRect = YES;
    vc.isVideoZoom = YES;
    vc.fromWhereVC = @"AddDeviceVC";//添加设备
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)addBleLockBtnClick:(UIButton *)sender
{
    NSLog(@"点击了蓝牙锁的按钮");
    
    KDSBleBindVC *vc = [KDSBleBindVC new];
    vc.step = 0;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)addGWLockBtnClick:(UIButton *)sender
{
    NSLog(@"点击了网关锁的按钮");
    [self backUpZigBeeConfigureWithFromStrValue:3];
    
}
-(void)addWifiLockBtnClick:(UIButton *)sender
{
    NSLog(@"点击了wifi锁的按钮");
    KDSAddWiFiLockFatherVC * vc = [KDSAddWiFiLockFatherVC new];
    [self.navigationController pushViewController:vc animated:YES];
    
}
#pragma mark:内部调用

-(void)backUpZigBeeConfigureWithFromStrValue:(NSUInteger)fromStrValue
{
    ///用来判断当前用户是否绑定网关
    ///如果用户绑定过网关才可以进行绑定猫眼和锁
    if (self.gateways.count >0) {
        KDSBindingGatewayVC * bindGatewayVC = [KDSBindingGatewayVC new];
        bindGatewayVC.fromStrValue = fromStrValue;
        [self.navigationController pushViewController:bindGatewayVC animated:YES];
    }else{
        ///反之提醒用户去设置网关
        
        UIAlertController * aler = [UIAlertController alertControllerWithTitle:Localized(@"NoZigBeeGatewayAvailable") message:Localized(@"addZigBeeSettingsnYouNeedConfigureGatewayConfiguringIt") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * ok = [UIAlertAction actionWithTitle:Localized(@"ToConfigure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ///点击配置网关
            
            KDSAddGWVCOne *vc = [[KDSAddGWVCOne alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
        }];
        UIAlertAction * cancle = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:nil];
        
        //修改message
        NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:Localized(@"addZigBeeSettingsnYouNeedConfigureGatewayConfiguringIt")];
        [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:KDSRGBColor(153, 153, 153) range:NSMakeRange(0, alertControllerMessageStr.length)];
        [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, alertControllerMessageStr.length)];
        [aler setValue:alertControllerMessageStr forKey:@"attributedMessage"];
        [cancle setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
        [aler addAction:cancle];
        [aler addAction:ok];
        [self presentViewController:aler animated:YES completion:nil];
        
    }
    
}

#pragma mark Lazy --load

- (UIView *)addLockSupView
{
    if (!_addLockSupView) {
        _addLockSupView = [UIView new];
        _addLockSupView.backgroundColor = UIColor.whiteColor;
        _addLockSupView.layer.cornerRadius = 4;
    }
    return _addLockSupView;
}

- (UIImageView *)lockIconImg
{
    if (!_lockIconImg) {
        _lockIconImg = [UIImageView new];
        _lockIconImg.backgroundColor = UIColor.whiteColor;
        _lockIconImg.image = [UIImage imageNamed:@"addDeviceIconImg"];
    }
    return _lockIconImg;
}
- (UIView *)line
{
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = KDSRGBColor(221, 221, 221);
    }
    return _line;
}
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.layer.masksToBounds = YES;
        _collectionView.layer.shadowColor = [UIColor colorWithRed:121/255.0 green:146/255.0 blue:167/255.0 alpha:0.1].CGColor;
        _collectionView.layer.shadowOffset = CGSizeMake(0,-4);
        _collectionView.layer.shadowOpacity = 1;
        _collectionView.layer.shadowRadius = 12;
        _collectionView.layer.cornerRadius = 5;
    }
    return _collectionView;
}

- (UIButton *)addBleLockBtn
{
    if (!_addBleLockBtn) {
        _addBleLockBtn = [UIButton new];
        [_addBleLockBtn setImage:[UIImage imageNamed:@"addBleLockIcon"] forState:UIControlStateNormal];
        [_addBleLockBtn setTitle:@"蓝牙锁" forState:UIControlStateNormal];
        _addBleLockBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_addBleLockBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        CGFloat    space = 10;// 图片和文字的间距
        [_addBleLockBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0)];
        [_addBleLockBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0)];
        [_addBleLockBtn addTarget:self action:@selector(addBleLockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBleLockBtn;
}
- (UIButton *)addZigBeeLockBtn
{
    if (!_addZigBeeLockBtn) {
        _addZigBeeLockBtn = [UIButton new];
        [_addZigBeeLockBtn setImage:[UIImage imageNamed:@"addZigBeeLockIcon"] forState:UIControlStateNormal];
        [_addZigBeeLockBtn setTitle:@"网关锁" forState:UIControlStateNormal];
        _addZigBeeLockBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_addZigBeeLockBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        CGFloat    space = 10;// 图片和文字的间距
        [_addZigBeeLockBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0)];
        [_addZigBeeLockBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0)];
        
        [_addZigBeeLockBtn addTarget:self action:@selector(addGWLockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addZigBeeLockBtn;
}
-(UIButton *)addWifiLockBtnBtn
{
    if (!_addWifiLockBtnBtn) {
        _addWifiLockBtnBtn = [UIButton new];
        [_addWifiLockBtnBtn setImage:[UIImage imageNamed:@"addDoorLockSuit"] forState:UIControlStateNormal];
        [_addWifiLockBtnBtn setTitle:@"WiFi锁" forState:UIControlStateNormal];
        _addWifiLockBtnBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_addWifiLockBtnBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        CGFloat    space = 10;// 图片和文字的间距
        [_addWifiLockBtnBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0)];
        [_addWifiLockBtnBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0)];
        
        [_addWifiLockBtnBtn addTarget:self action:@selector(addWifiLockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _addWifiLockBtnBtn;
}
- (UIView *)line1
{
    if (!_line1) {
        _line1 = [UIView new];
        _line1.backgroundColor = KDSRGBColor(234, 233, 233);
    }
    return _line1;
}
- (UILabel *)tipsLb
{
    if (!_tipsLb) {
        _tipsLb = [UILabel new];
        _tipsLb.text = @"其他智能家居";
        _tipsLb.textColor = KDSRGBColor(51, 51, 51);
        _tipsLb.font = [UIFont systemFontOfSize:15];
        _tipsLb.backgroundColor = UIColor.clearColor;
        _tipsLb.textAlignment = NSTextAlignmentLeft;
    }
    
    return _tipsLb;
}

#pragma mark UICollecionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return self.deviceNameArray.count;

}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    KDSAddDeviceListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:deviceListCellId forIndexPath:indexPath];

    cell.backgroundColor = UIColor.clearColor;
    cell.deviceNameLb.text = self.deviceNameArray[indexPath.row];
    cell.deviceNameImg.image = [UIImage imageNamed:self.deviceImgArray[indexPath.row]];
    cell.line.hidden = (indexPath.row + 1) % 3 == 0 ? YES : NO;
    return cell;

}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float cellWidth = (KDSScreenWidth-33) / 3.0;
    CGSize size = CGSizeMake(cellWidth, 110);
    return size;
}

// 两个cell之间的最小间距，是由API自动计算的，只有当间距小于该值时，cell会进行换行
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}
// 两行之间的最小间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0://猫眼
             [self backUpZigBeeConfigureWithFromStrValue:2];
            break;
        case 1:
        case 2:
        {//网关
            KDSAddGWVCOne *vc = [[KDSAddGWVCOne alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {//瑞瀛网关
//            KDSAddRYGWVC * vc = [KDSAddRYGWVC new];
//            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4:
        {
//            KDSAddZeroFireSingleStep1VC * vc = [KDSAddZeroFireSingleStep1VC new];
//            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}


@end
