//
//  KDSMQTTManager+SmartHome.h
//  KaadasLock
//
//  Created by zhaona on 2020/2/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSMQTTManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSMQTTManager (SmartHome)

/**
 *@brief 增加/更新一个设备联动（场景）。
 *@param gw 场景所在的网关。
 *@param contion  场景（pushNotification状态，time策略时间，trigger设备唯一标识，conditions，actions）
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw setTriggerActions:(NSDictionary *)actions time:(NSDictionary *)time trigger:(NSDictionary *)trigger contion:(NSDictionary *)contion completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 删除一个设备联动（场景）。
 *@param gw 场景所在的网关。
 *@param triggerId  场景（要删除的场景的trigger设备唯一标识，）
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw delTriggerId:(NSString *)triggerId completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 查询一个设备联动（场景）。
 *@param gw 场景所在的网关。
 *@param triggerId  场景（要删除的场景的trigger设备唯一标识，）
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw getTriggerId:(NSString *)triggerId completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
 *@brief 上传一个联动事件（场景）。
 *@param gw 场景所在的网关。
 *@param triggerId  场景（要删除的场景的trigger设备唯一标识，）
 *@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
 *@return the receipt of the task.
 */
- (KDSMQTTTaskReceipt *)gw:(GatewayModel *)gw upDataTriggerId:(NSString *)triggerId completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

//----------------------单火开关涉及到的接口------------------------------
/**
*@brief ②　添加锁外围（开关）
*@param wf Wi-Fi锁的模型 。
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
*@return the receipt of the task.
*/
- (KDSMQTTTaskReceipt *)addSwitchWithWf:(KDSWifiLockModel *)wf completion:(nullable void(^)(NSError * __nullable error,BOOL success, NSInteger typeValue,NSString * macaddr,NSTimeInterval switchBindTime))completion;
/**
*@brief 锁外围（开关）设置 Wi-Fi锁的外围设备。
*@param stParams 开关（一、二、三、四健）参数的对应数组。
*@param wf Wi-Fi锁的模型 。
*@switchEn  生效设置(策略总开关，on/off)
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
*@return the receipt of the task.
*/
- (KDSMQTTTaskReceipt *)setSwitchWithWf:(KDSWifiLockModel *)wf stParams:(NSArray *)stParams switchEn:(int)switchEn completion:(nullable void(^)(NSError * __nullable error, BOOL success))completion;

/**
*@brief  ①　查询锁外围（开关）
*@param  wf 单火开关相关锁的设备模型。
*@param completion 请求结束执行的回调。如果error不为nil，则ack出错或返回失败，返回失败时error的code请参考KDSGatewayError枚举；成功时error为nil且success为YES。
*@return the receipt of the task.
*/
- (KDSMQTTTaskReceipt *)getSwitchWithWf:(KDSWifiLockModel *)wf completion:(nullable void(^)(NSError * __nullable error,NSArray<KDSDevSwithModel *> * devSwithModel))completion;

@end

NS_ASSUME_NONNULL_END
