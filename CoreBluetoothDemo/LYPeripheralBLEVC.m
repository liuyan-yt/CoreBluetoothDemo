//
//  LYPeripheralBLEVC.m
//  CoreBluetoothDemo
//
//  Created by lanou3g on 16/11/14.
//  Copyright © 2016年 liuyan. All rights reserved.
//

#import "LYPeripheralBLEVC.h"
#import <CoreBluetooth/CoreBluetooth.h>

static NSString *const ServiceStr1UUID = @"FFF0";
static NSString *const ServiceStr2UUID = @"FFF0";
static NSString *const notiyCharacteristicStrUUID = @"FFF1";
static NSString *const readwriteCharacteristicStrUUID = @"FFF2";
static NSString *const readCharacteristicStrUUID = @"FFF1";
static NSString *const LocalNaneKey = @"XMGPeripheral";




@interface LYPeripheralBLEVC ()<CBPeripheralManagerDelegate>
@property(nonatomic,strong)CBPeripheralManager *pMgr;
@property(nonatomic,strong)NSTimer *timer;
@end

@implementation LYPeripheralBLEVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"外设";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"606808b7401f33e956b50e7ab3b43810.jpg"]];
    
    
    //调用get方法,初始化CBPeripheralManager状态改变会调用代理方法peripheralManagerDidUpdateState：
    //模拟器永远也不会是peripheralManagerDidUpdateState
    [self pMgr];





}


- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    /*
     CBPeripheralManagerStateUnknown = 0,
     CBPeripheralManagerStateResetting,
     CBPeripheralManagerStateUnsupported,
     CBPeripheralManagerStateUnauthorized,
     CBPeripheralManagerStatePoweredOff,
     peripheralManagerDidUpdateState,
     */
    //在开发中，NS_ENUM是可以直接用==号判断的，NS_OPTIONS类型的枚举要用&（包含）判断
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        //如果是on的话，才会进行操作
        [self setupPMgr];
    }else{
        NSLog(@"not on");
    }
}
#pragma mark --私有方法
-(void)setupPMgr{
    //5.柑橘硬件工程师提供的信息来确定UUID
    //4.创建特征的描述
    CBMutableDescriptor *desT = [[CBMutableDescriptor alloc] initWithType:[CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString] value:@"test"];
    //3.创建特征（服务的特征）
    CBMutableCharacteristic *cha0 = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:readCharacteristicStrUUID] properties:(CBCharacteristicPropertyRead) value:nil//此处也是硬件工程师确定的
        permissions:(CBAttributePermissionsReadable)];
    cha0.descriptors = @[desT];
    //2.设置添加到外设管理者中的服务
    //首先想到的内部结构
    //通常UUID都是硬件工程师确定的
    CBUUID *ser0UUID = [CBUUID UUIDWithString:ServiceStr1UUID];
    CBMutableService *ser0 = [[CBMutableService alloc] initWithType:ser0UUID primary:YES];
    ser0.characteristics = @[cha0];
    //1.添加服务到外设管理者中
    [self.pMgr addService:ser0];
}

// 外设收到读的请求,然后读特征的值赋值给request
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    // 判断是否可读
    if (request.characteristic.properties & CBCharacteristicPropertyRead) {
        NSData *data = request.characteristic.value;
        
        request.value = data;
        // 对请求成功做出响应
        [self.pMgr respondToRequest:request withResult:CBATTErrorSuccess];
    }else
    {
        [self.pMgr respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
}
// 外设收到写的请求,然后读request的值,写给特征
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    NSLog(@"%s, line = %d, requests = %@", __FUNCTION__, __LINE__, requests);
    CBATTRequest *request = requests.firstObject;
    if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
        NSData *data = request.value;
        // 此处赋值要转类型,否则报错
        CBMutableCharacteristic *mChar = (CBMutableCharacteristic *)request.characteristic;
        mChar.value = data;
        // 对请求成功做出响应
        [self.pMgr respondToRequest:request withResult:CBATTErrorSuccess];
    }else
    {
        [self.pMgr respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
}


// 与CBCentral的交互
// 订阅特征
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"%s, line = %d, 订阅了%@的数据", __FUNCTION__, __LINE__, characteristic.UUID);
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                      target:self
                                                    selector:@selector(yf_sendData:)
                                                    userInfo:characteristic
                                                     repeats:YES];
    
    self.timer = timer;
    
    /* 另一种方法 */
    //    NSTimer *testTimer = [NSTimer timerWithTimeInterval:2.0
    //                                                 target:self
    //                                               selector:@selector(yf_sendData:)
    //                                               userInfo:characteristic
    //                                                repeats:YES];
    //    [[NSRunLoop currentRunLoop] addTimer:testTimer forMode:NSDefaultRunLoopMode];
    
}
// 取消订阅特征
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"%s, line = %d, 取消订阅了%@的数据", __FUNCTION__, __LINE__, characteristic.UUID);
    [self.timer invalidate];
    self.timer = nil;
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
}

// 计时器每隔两秒调用的方法
- (BOOL)yf_sendData:(NSTimer *)timer
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yy:MM:dd:HH:mm:ss";
    
    NSString *now = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"now = %@", now);
    
    // 执行回应central通知数据
    return  [self.pMgr updateValue:[now dataUsingEncoding:NSUTF8StringEncoding]
                 forCharacteristic:timer.userInfo
              onSubscribedCentrals:nil];
}


-(CBPeripheralManager *)pMgr{
    if (!_pMgr) {
        _pMgr = [[CBPeripheralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue() options:nil];
    }
    return _pMgr;
}




@end
