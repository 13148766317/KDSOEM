//
//  KDSAddWiFiLockFatherVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/5/26.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddWiFiLockFatherVC.h"
#import "KDSWifiLockHelpVC.h"
#import "RHScanViewController.h"
#import "MBProgressHUD+MJ.h"
#import "KDSAddNewWiFiLockStep1VC.h"
#import "KDSAddBleAndWiFiLockStep1.h"

@interface KDSAddWiFiLockFatherVC ()
///锁型号输入框
@property (nonatomic,strong)UITextField * devTextField;

@end

@implementation KDSAddWiFiLockFatherVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"选择配网";
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    
    [self setUI];
}

-(void)setUI
{
    UIView * topView = [UIView new];
    topView.backgroundColor = UIColor.whiteColor;
    topView.layer.cornerRadius = 16;
    topView.layer.masksToBounds = YES;
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(12);
        make.right.equalTo(self.view.mas_right).offset(-60);
        make.top.equalTo(self.view.mas_top).offset(11);
        make.height.equalTo(@40);
    }];
    UIImageView * searchIconImg = [UIImageView new];
    searchIconImg.image = [UIImage imageNamed:@"searchIconImg"];
    [topView addSubview:searchIconImg];
    [searchIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@16);
        make.left.equalTo(topView.mas_left).offset(13);
        make.centerY.equalTo(topView);
        
    }];
    _devTextField = [UITextField new];
    _devTextField.borderStyle = UITextBorderStyleNone;
    _devTextField.font = [UIFont systemFontOfSize:15];
    _devTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _devTextField.placeholder = @"请输入您的门锁型号";
    [topView addSubview:_devTextField];
    [_devTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_devTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchIconImg.mas_right).offset(7);
        make.right.equalTo(topView.mas_right).offset(0);
        make.top.equalTo(topView.mas_top).offset(0);
        make.bottom.equalTo(topView.mas_bottom).offset(0);
    }];
    
    UIButton * addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.backgroundColor = UIColor.clearColor;
    [addBtn setTitle:@"添加" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [addBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [self.view addSubview:addBtn];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.left.equalTo(topView.mas_right).offset(0);
        make.height.equalTo(@40);
        make.centerY.equalTo(topView);
    }];
    
    UIView * bootomView = [UIView new];
    bootomView.layer.masksToBounds = YES;
    bootomView.layer.cornerRadius = 10;
    bootomView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:bootomView];
    [bootomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.height.equalTo(@296);
        make.top.equalTo(topView.mas_bottom).offset(12);
    }];
    
    UILabel * tipsLb = [UILabel new];
    tipsLb.text = @"在门锁后面板找到配网二维码";
    tipsLb.font = [UIFont systemFontOfSize:15];
    tipsLb.textAlignment = NSTextAlignmentCenter;
    tipsLb.textColor = KDSRGBColor(125, 125, 125);
    [bootomView addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bootomView.mas_top).offset(30);
        make.height.equalTo(@18);
        make.centerX.equalTo(bootomView);
    }];
    
    UIButton * scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanBtn setImage:[UIImage imageNamed:@"addWiFiLockSearchImg"] forState:UIControlStateNormal];
    [scanBtn addTarget:self action:@selector(scanBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bootomView addSubview:scanBtn];
    [scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@139);
        make.height.equalTo(@127);
        make.top.equalTo(tipsLb.mas_bottom).offset(40);
        make.centerX.equalTo(bootomView);
    }];
}

#pragma mark 控件点击事件

-(void)navRightClick
{
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
///扫描：扫面二维码适配配网方式
-(void)scanBtnClick:(UIButton *)sender
{
    ///鉴权相机权限
    RHScanViewController *vc = [RHScanViewController new];
    vc.isOpenInterestRect = YES;
    vc.isVideoZoom = YES;
    vc.fromWhereVC = @"AddDeviceVC";//添加设备
    [self.navigationController pushViewController:vc animated:YES];
}
///通过锁型号适配配网方式
-(void)addBtnClick:(UIButton *)sender
{
    //目前是客户端管理锁型号，每次发布新的锁（Wi-Fi/ble+wifi）记得在数组里面添加对应的锁型号-----目前是这种笨方法后期最好有服务器管理
    NSArray * wifiLockModel = @[@"X1",@"F1",@"K11",@"S110",@"K9-W",@"K10-W",@"K12",@"K13（兰博）",@"S118",@"A6",@"A7-W",@"F1S",@"K13F",@"F1S"];
    NSArray * bleWifiLockModel = @[@"S110M",@"S110-D1",@"S110-D2",@"S110-D3",@"S110-D4"];
    if (self.devTextField.text.length >0) {
        for (int i = 0; i < wifiLockModel.count; i ++) {
            ///[string caseInsensitiveCompare:string2] == NSOrderedSame
             if ([self.devTextField.text caseInsensitiveCompare:wifiLockModel[i]] == NSOrderedSame) {
               //wifi配网
                 KDSAddNewWiFiLockStep1VC * vc = [KDSAddNewWiFiLockStep1VC new];
                 [self.navigationController pushViewController:vc animated:YES];
                 return;
            }
        }
        for (int k = 0; k < bleWifiLockModel.count; k ++) {
            if ([self.devTextField.text caseInsensitiveCompare:bleWifiLockModel[k]] == NSOrderedSame) {
                //ble+wifi
                KDSAddBleAndWiFiLockStep1 * vc = [KDSAddBleAndWiFiLockStep1 new];
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }
        }
        
       MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
       hud.mode =MBProgressHUDModeText;
       hud.detailsLabel.text = @"请输入正确的门锁型号，或者\n扫码添加";
       hud.bezelView.backgroundColor = [UIColor blackColor];
       hud.detailsLabel.textColor = [UIColor whiteColor];
       hud.detailsLabel.font = [UIFont systemFontOfSize:15];
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           [hud hideAnimated:YES];
       });
    }else{
        [MBProgressHUD showError:@"锁型号不能为空"];
    }
    
}

///设备型号输入框
- (void)textFieldDidChange:(UITextField *)textField{
   
}

@end
