//
//  LYCenterBLEVC.m
//  CoreBluetoothDemo
//
//  Created by lanou3g on 16/11/14.
//  Copyright © 2016年 liuyan. All rights reserved.
//

#import "LYCenterBLEVC.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface LYCenterBLEVC ()<CBCentralManagerDelegate,CBPeripheralDelegate>
//centerMa中心管理者
@property(nonatomic,strong)CBCentralManager *cMgr;
//链接到的外设
@property(nonatomic,strong)CBPeripheral *peripheral;
@end

@implementation LYCenterBLEVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"中心";
    //ios5之前的系统，再通过图片设置背景颜色的时候，用下面办法，有闪屏的bug出现
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"23e34efd81e423c22e9964c3cf675f00.jpg"]];
    //调用get方法，现将中心管理者初始化
    [self cMgr];
#warning 不能在CBCentralManagerStatePoweredOn以外的状态对中心管理者进行操作
    //搜索外设
   // [self.cMgr scanForPeripheralsWithServices:nil options:nil];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self ly_dismissContentedWithPeripheral:self.peripheral];
}
-(CBCentralManager *)cMgr{
    if (!_cMgr) {
        _cMgr = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:nil];
        
    }
    return _cMgr;
}
#pragma mark ----CBCentralManagerDelegate必须实现的方法
//最重要的，初始化就会调用这个方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    /*
     CBCentralManagerStateUnknown = 0,
     CBCentralManagerStateResetting,
     CBCentralManagerStateUnsupported,
     CBCentralManagerStateUnauthorized,
     CBCentralManagerStatePoweredOff,
     CBCentralManagerStatePoweredOn,
     */
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:{
            NSLog(@"CBCentralManagerStatePoweredOn");
            //在中心管理者成功开启进行一些操作
            //搜索外设
            [self.cMgr scanForPeripheralsWithServices:nil//通过某些服务筛选外设
                                              options:nil//dict，条件
             //搜索成功，调用找到外设的代理方法
             //- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI;
             ];
        }
            break;
        default:
            break;
    }
}
//发现外设后调用的方法
- (void)centralManager:(CBCentralManager *)central//中心管理者
    didDiscoverPeripheral:(CBPeripheral *)peripheral//外设
    advertisementData:(NSDictionary<NSString *, id> *)advertisementData//外设携带的数据
    RSSI:(NSNumber *)RSSI//外设发出的蓝牙信号强度，一般为负值，40以上才链接，可设定
{
    NSLog(@"%s,line=%d",__FUNCTION__,__LINE__);
    //NSLog(@"%s,line=%d,cental=%@,peripheral=%@,advertisementData=%@,RSSI=%@",__FUNCTION__,__LINE__,central,peripheral,advertisementData,RSSI);
#warning OBand手环
//    if ([peripheral.name hasPrefix:@"OBand"]&&ABS(RSSI.integerValue)>35) {
    if (ABS(RSSI.integerValue)>35) {
        //在此处对我们的advertisementData(外设携带的广播数据)进行一些处理
        //通常通过过滤，我们会得到一些外设，然后将外设缓存到我们的可变数组中
        //先按一个设备进行处理
        self.peripheral = peripheral;
        //发现完之后是进行链接
        [self.cMgr connectPeripheral:self.peripheral options:nil];
    }
    
}
//链接外设成功之后调用的方法
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"链接成功");
    //链接成功之后可以进行服务和特征的发现
    //获取外设的服务
        //设置外设代理
    self.peripheral.delegate = self;
        //外设发现服务，传nil代表不过滤
        //这里会触发外设的代理方法-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
    [self.peripheral discoverServices:nil];
    
    
    
    
    
    
    
}
//连接失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接失败");
}
//丢失链接
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"丢失连接");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ---外设服务的代理方法
//发现外设的服务后调用的方法
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"%s,line=%d",__FUNCTION__,__LINE__);
    //判断是否失败
    if (error) {
        NSLog(@"%s,line=%d,error = %@",__FUNCTION__,__LINE__,error.localizedDescription);
        return;
    }
#warning 以下方法中含有error的均需进行判断
    for (CBService *service in peripheral.services) {
        //发现服务后，让设备再发现服务内部的特征
        [peripheral discoverCharacteristics:nil forService:service];
    }
}
//发现外设服务的特征的时候调用的代理方法
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error{
    
    NSLog(@"%s,line=%d",__FUNCTION__,__LINE__);
    //遍历服务里的特征
    for (CBCharacteristic *cha in service.characteristics) {
        NSLog(@"%s,line=%d,cha = %@",__FUNCTION__,__LINE__,cha);
        //获取特征对应的描述 didUpdateValueForDescriptor
        [peripheral discoverDescriptorsForCharacteristic:cha];
        //获取特征的值 didUpdateValueForCharacteristic
        [peripheral readValueForCharacteristic:cha];
    }
}
//更新特征的value的时候调用
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        //它会触发
        [peripheral readValueForDescriptor:descriptor];
    }
}
//更新特征的描述的值的时候会调用
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //这里当我们的描述的值更新的时候，直接调用此方法即可
    [peripheral readValueForDescriptor:descriptor];

}
//发现外设特征的描述数组
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"%s,line=%d",__FUNCTION__,__LINE__);
    //在此读取描述即可
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        [peripheral readValueForDescriptor:descriptor];
    }
}
#pragma 自定义方法

//外设写数据到特征中
//需要注意的是特征的属性是否支持写数据
-(void)ly_peripheral:(CBPeripheral *)peripheral didWriteData:(NSData *)data forCharacteristic:(nonnull CBCharacteristic *)characteristic{
    //此时由于枚举属性是NS_OPTINS，所以一枚举可以对应多个类型，所以判断不能用=，而应该用包含&
    if (characteristic.properties  &CBCharacteristicPropertyWrite ) {
        //核心代码
        [peripheral writeValue:data forCharacteristic:characteristic type:(CBCharacteristicWriteWithResponse)];
    }
}


//通知的订阅和取消订阅
//实际核心代码的一个方法
//一般这两个方法要根据产品需求进行
-(void)ly_peripheral:(CBPeripheral *)peripheral regNotifyWithCharacteristic:(nonnull CBCharacteristic *)characteristic{
    //外设为我们订阅通知 数据会进入 peripheral：didUpdateValueForCharacteristic：error方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}
-(void)ly_peripheral:(CBPeripheral *)peripheral CancelWithCharacteristic:(nonnull CBCharacteristic *)characteristic{
    //外设为我们取消订阅通知
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}
//断开链接
-(void)ly_dismissContentedWithPeripheral:(CBPeripheral *)peripheral {
    //停止扫描
    [self.cMgr stopScan];
    //断开连接
    [self.cMgr cancelPeripheralConnection:peripheral];
}



@end
