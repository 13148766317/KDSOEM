//
//  KDSMQTTOptions.m
//  KaadasLock
//
//  Created by orange on 2019/4/12.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSMQTTOptions.h"

#pragma mark - 主题名
MQTTTopic const MQTTServerTopic = @"/request/app/func";
MQTTTopic const MQTTGWTopic = @"/type/%@/call";

#pragma mark - 方法名。
MQTTFunc const MQTTFuncAllowCateyeJoin = @"allowCateyeJoin";
MQTTFunc const MQTTFuncEndCateyeJoin = @"endCateyeJoin";
MQTTFunc const MQTTFuncGetPower = @"getPower";
MQTTFunc const MQTTFuncGetTime = @"getTime";
MQTTFunc const MQTTFuncSetTime = @"setTime";
MQTTFunc const MQTTFuncDeleteDevice = @"delDevice";
MQTTFunc const MQTTFuncOTA = @"otaNotify";
MQTTFunc const MQTTFuncBindGW = @"bindGatewayByUser";
MQTTFunc const MQTTFuncUnbindGW = @"unbindGateway";
MQTTFunc const MQTTFuncGWList = @"gatewayBindList";
MQTTFunc const MQTTFuncRBMeme = @"RegisterMemeAndBind";
MQTTFunc const MQTTFuncDeviceList = @"getGatewayDevList";
MQTTFunc const MQTTFuncUpdateNickname = @"updateDevNickName";
MQTTFunc const MQTTFuncApproveList = @"getGatewayaprovalList";
MQTTFunc const MQTTFuncApproveGW = @"approvalBindGateway";
MQTTFunc const MQTTFuncUnlockRecord = @"selectOpenLockRecord";
MQTTFunc const MQTTFuncAlarmList = @"getAlarmList";
MQTTFunc const MQTTFuncApproveGWOTA = @"otaApprovateResult";

#pragma mark - MQTT事件通知和子事件。
NSString * const MQTTEventKey = @"MQTTEventKey";
NSString * const MQTTEventParamKey = @"MQTTEventParamKey";
MQTTSubEvent const MQTTSubEventGWOnline = @"MQTTSubEventGWOnline";
MQTTSubEvent const MQTTSubEventGWOffline = @"MQTTSubEventGWOffline";
MQTTSubEvent const MQTTSubEventJoinGW = @"MQTTSubEventJoinGW";
MQTTSubEvent const MQTTSubEventJoinGWAllow = @"MQTTSubEventJoinGWAllow";
MQTTSubEvent const MQTTSubEventJoinGWRefuse = @"MQTTSubEventJoinGWRefuse";
MQTTSubEvent const MQTTSubEventOTA = @"MQTTSubEventOTA";
MQTTSubEvent const MQTTSubEventDevDel = @"MQTTSubEventDevDel";
MQTTSubEvent const MQTTSubEventLowPower = @"MQTTSubEventLowPower";
MQTTSubEvent const MQTTSubEventOTASuccess = @"MQTTSubEventOTASuccess";
MQTTSubEvent const MQTTSubEventOTAFailed = @"MQTTSubEventOTAFailed";
MQTTSubEvent const MQTTSubEventPIRAlarm = @"MQTTSubEventPIRAlarm";
MQTTSubEvent const MQTTSubEventCYHeadLost = @"MQTTSubEventCYHeadLost";
MQTTSubEvent const MQTTSubEventCYBell = @"MQTTSubEventCYBell";
MQTTSubEvent const MQTTSubEventCYHostLost = @"MQTTSubEventCYHostLost";
MQTTSubEvent const MQTTSubEventUnlock = @"MQTTSubEventUnlock";
MQTTSubEvent const MQTTSubEventWifiUnlock = @"MQTTSubEventWifiUnlock";
MQTTSubEvent const MQTTSubEventLock = @"MQTTSubEventLock";
MQTTSubEvent const MQTTSubEventWifiLock = @"MQTTSubEventWifiLock";
MQTTSubEvent const MQTTSubEventGWReset = @"MQTTSubEventGWReset";
MQTTSubEvent const MQTTSubEventDeviceOnline = @"MQTTSubEventDeviceOnline";
MQTTSubEvent const MQTTSubEventDeviceOffline = @"MQTTSubEventDeviceOffline";
MQTTSubEvent const MQTTSubEventCYWakeup = @"MQTTSubEventCYWakeup";
MQTTSubEvent const MQTTSubEventDLAlarm = @"MQTTSubEventDLAlarm";
MQTTSubEvent const MQTTSubEventWIfiLockAlarm = @"MQTTSubEventWIfiLockAlarm";
MQTTSubEvent const MQTTSubEventDLKeyChanged = @"MQTTSubEventDLKeyChanged";
MQTTSubEvent const MQTTSubEventDLInfo = @"MQTTSubEventDLInfo";
MQTTSubEvent const MQTTSubEventWifiLockStateChanged = @"MQTTSubEventWifiLockStateChanged";
