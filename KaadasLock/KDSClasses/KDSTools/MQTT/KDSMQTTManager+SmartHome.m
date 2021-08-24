//
//  KDSMQTTManager+SmartHome.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSMQTTManager+SmartHome.h"


@implementation KDSMQTTManager (SmartHome)

- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setTriggerActions:(NSDictionary *)actions time:(NSDictionary *)time trigger:(NSDictionary *)trigger contion:(NSDictionary *)contion completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self gw:gw performFunc:@"triggerAdd" withScene_rule:@{@"triggerId":@"001",@"triggerName":@"周日场景",@"pushNotification":@0,@"enable":@1,@"time":@{@"startdate":@"2020/2/28",@"starttime":@"14:35",@"enddate":@"2020/2/28",@"endtime":@"15:00",@"timezone":@"+0800"},@"trigger":@{@"deviceId":@"ZG01185110817",@"deviceType":@"timer",@"event":@"14:55"},@"contion":@[]/*@{@"deviceId":gw.deviceSN,@"attributeId":@"Attriid",@"operator":@">",@"value":@"111"}*/,@"actions":@[@{@"deviceId":@"00:12:4b:00:1d:40:10:e2",@"func":@"setControlLight",@"params":@{@"optype":@"openLight",@"ch":@1,@"type":@"pin",@"pin":@"147147",@"userid":[KDSUserManager sharedManager].user.uid}}]}  returnCode:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw delTriggerId:(NSString *)triggerId completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self gw:gw performFuncAndNoScene_rule:@"triggerDel" triggerId:triggerId returnCode:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw getTriggerId:(NSString *)triggerId completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self gw:gw performFuncAndNoScene_rule:@"triggerSyn" triggerId:triggerId returnCode:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw upDataTriggerId:(NSString *)triggerId completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self gw:gw performFuncAndNoScene_rule:@"triggerActivation" triggerId:triggerId returnCode:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
        
    }].receipt;
}

- (KDSMQTTTaskReceipt *)addSwitchWithWf:(KDSWifiLockModel *)wf completion:(void (^)(NSError * _Nullable, BOOL, NSInteger, NSString * _Nonnull, NSTimeInterval))completion
{
    return [self wf:wf performFunc:@"addSwitch" withParams:@{} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        
        if (!completion) return;
        if (!success)
        {
            completion(error, nil, -9999,@"",-9999);
        }
        else
        {
            NSString * type = response[@"type"];
            NSString * macaddr = response[@"mac"];
            NSString * tt = response[@"timestamp"];
            NSTimeInterval time = tt.intValue;
            !completion ?: completion(error, success ,type.integerValue,macaddr,time);
        }
    }].receipt;
}

- (KDSMQTTTaskReceipt *)setSwitchWithWf:(KDSWifiLockModel *)wf stParams:(NSArray *)stParams switchEn:(int)switchEn completion:(void (^)(NSError * _Nullable, BOOL))completion
{
    return [self wf:wf performFunc:@"setSwitch" withParams:@{@"switchEn":@(switchEn),@"switchArray":stParams} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
        !completion ?: completion(error, success);
    }].receipt;
}

- (KDSMQTTTaskReceipt *)getSwitchWithWf:(KDSWifiLockModel *)wf completion:(void (^)(NSError * _Nullable, NSArray<KDSDevSwithModel *> * _Nonnull))completion
{
    return [self wf:wf performFunc:@"getSwitch" withParams:@{} returnData:nil completion:^(NSError * _Nullable error, BOOL success, NSDictionary * _Nullable response) {
         NSArray * devSts = [KDSDevSwithModel mj_objectWithKeyValues:response].copy;
         !completion ?: completion(error, success ? devSts : nil);
        
    }].receipt;
}

@end
