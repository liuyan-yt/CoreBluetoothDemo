# CoreBluetoothDemo
CoreBluetooth框架的核心其实是俩东西:peripheral和central,对应他们分别有一组相关的API和类

中心模式,就是以你的app作为中心,连接其他的外设的场景;
外设模式,使用"手机作为外设"连接其他中心设备操作的场景

服务和特征(service and characteristic)
* 每个设备都会有1个or多个服务
* 每个服务里都会有1个or多个特征
* 特征就是具体键值对,提供数据的地方
* 每个特征属性分为:读,写,通知等等

BLE中心模式流程
- 1.建立中心角色
- 2.扫描外设(Discover Peripheral)
- 3.连接外设(Connect Peripheral)
- 4.扫描外设中的服务和特征(Discover Services And Characteristics)
* 4.1 获取外设的services
* 4.2 获取外设的Characteristics,获取characteristics的值,,获取Characteristics的Descriptor和Descriptor的值
- 5.利用特征与外设做数据交互(Explore And Interact)
- 6.订阅Characteristic的通知
- 7.断开连接(Disconnect)

BLE外设模式流程
- 1.启动一个Peripheral管理对象
- 2.本地peripheral设置服务,特征,描述,权限等等
- 3.peripheral发送广告
- 4.设置处理订阅,取消订阅,读characteristic,写characteristic的代理方法





