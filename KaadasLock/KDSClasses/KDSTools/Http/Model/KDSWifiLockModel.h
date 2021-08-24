//
//  KDSWifiLockModel.h
//  KaadasLock
//
//  Created by zhaona on 2019/12/17.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSWifiLockModel : KDSCodingObject
///wifi锁SN
@property (nonatomic,strong)NSString * wifiSN;
///锁SN
@property (nonatomic,strong)NSString * productSN;
///产品型号
@property (nonatomic,strong)NSString * productModel;
///门锁昵称
@property (nonatomic,strong)NSString * lockNickname;
///用户ID
@property (nonatomic,strong)NSString * uid;
///设备软件版本
@property (nonatomic,strong)NSString * softwareVersion;
///wifi锁的功能集
@property (nonatomic,strong)NSString * functionSet;
///1:管理员 0：普通用户
@property (nonatomic, copy)NSString *isAdmin;
///绑定的时候从锁上获取的28字节的随机数
@property (nonatomic,strong)NSString * randomCode;
///wifi名称（设备绑定的wifi名称)
@property (nonatomic,strong)NSString * wifiName;
///设备的唯一ID
@property (nonatomic,strong)NSString * _id;
///设备管理员账号
@property (nonatomic,strong)NSString * adminName;
///主用户的Uid
@property (nonatomic,strong)NSString * adminUid;
///分享用户ID
@property (nonatomic,strong)NSString * appId;
///推送开关： 1(0默认开启)开启推送 2关闭推送
@property (nonatomic,strong)NSString * pushSwitch;
///用户账号
@property (nonatomic,strong)NSString * uname;
///蓝牙版本号
@property (nonatomic,strong)NSString * bleVersion;
///wifi锁固件版本
@property (nonatomic,strong)NSString * lockFirmwareVersion;
///wifi锁设备软件版本
@property (nonatomic,strong)NSString * lockSoftwareVersion;
///mqtt版本号
@property (nonatomic,strong)NSString * mqttVersion;
///wifi版本号
@property (nonatomic,strong)NSString * wifiVersion;
///wifi锁的语言：en/zh
@property (nonatomic,strong)NSString * language;
///wifi锁语音模式：0语音模式 1静音模式
@property (nonatomic,strong)NSString * volume;
///模式：0自动模式 1手动模式
@property (nonatomic,strong)NSString * amMode;
///安全模式：0通用模式 1安全模式
@property (nonatomic,strong)NSString * safeMode;
///布防：0撤防 1布防
@property (nonatomic,strong)NSString * defences;
///反锁：0解除反锁1反锁
@property (nonatomic,strong)NSString * operatingMode;
///面容识别模式:0面容识别开启，1面容识别关闭
@property (nonatomic,strong)NSString * faceStatus;
///节能模式:1节能模式开启，0节能模式关闭
@property (nonatomic,strong)NSString * powerSave;
///更新数据的时间距离1970年的秒数
@property (nonatomic,assign)NSTimeInterval updateTime;
///绑定设备的时间距离1970年的秒数
@property (nonatomic,assign)NSTimeInterval createTime;
///服务器当前时间距离1970年的秒数
@property (nonatomic, assign)NSTimeInterval currentTime;
///wifi锁的电量
@property (nonatomic, assign)int power;
///门锁开关状态：1关 2开
@property (nonatomic, assign)int openStatus;
///门锁开关状态更新时间
@property (nonatomic, assign)NSTimeInterval openStatusTime;
///单火开关的json数据
@property (nonatomic, strong)NSDictionary * switchDev;
///单火开关的键位昵称
@property (nonatomic, strong)NSArray * switchNickname;


@end

NS_ASSUME_NONNULL_END
