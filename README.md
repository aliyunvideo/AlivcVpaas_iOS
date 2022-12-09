# 互动直播低代码音视频工厂如何升级到3.0.0

## 前提条件

获取音视频终端SDK License和key，需要包含推流、播放、美颜的授权。
参考[获取License](https://help.aliyun.com/document_detail/438207.html)

## 升级步骤

### 0、3.0版本介绍

低代码音视频工厂3.0版本对底层依赖的媒体SDK进行改造，把依赖的各个SDK（AlivcLivePusher\AliPlayer\Queen）升级为依赖音视频终端SDK（AliVCSDK_PremiumLive或AliVCSDK_Premium），音视频终端SDK具备更多的功能，更好的性能，及更小的包Size。

更多详情参考：[音视频终端SDK](https://help.aliyun.com/document_detail/438206.html)



### 1、集成SDK

- SDK依赖说明

```
├── AlivcVpaas  // PodSpec
│   ├── Frameworks   // SDKs
│      ├── AliStandardLiveRoomBundle.framework           // 含UI直播间（含UI集成）
│      ├── AliInteractiveRoomBundle.framework            // 房间管理引擎（含UI集成/标准集成）
│      ├── AliInteractiveFaceBeautyCore.framework        // 美颜（含UI集成/标准集成）
│      ├── AliInteractiveLiveCore.framework              // 主播端推流（含UI集成/标准集成）
│      ├── AliInteractiveVideoPlayerCore.framework       // 观众端拉流（含UI集成/标准集成）
│   ├── Resources  // 资源包
│      ├── AliStandardLiveRoomResource.bundle            // 含UI直播间资源包（含UI集成）
│      ├── AliInteractiveFaceBeautyCoreResource.bundle   // 美颜资源包（含UI集成/标准集成）
│   ├── Dependency  // 依赖
│      ├── AliVCSDK_PremiumLive 或 AliVCSDK_Premium      // 适用于互动直播场景的音视频终端SDK
```
>底层依赖AliVCSDK_PremiumLive 或 AliVCSDK_Premium，不在依赖AlivcLivePusher\AliPlayer\Queen
>AliVCSDK_PremiumLive 或 AliVCSDK_Premium的说明参考[SDK说明](https://help.aliyun.com/document_detail/440004.html?spm=a2c4g.11186623.0.0.31b7598aOmwN7l#section-icw-ppu-dll)

- 选择接入方式

提供了一下几种subspec，并对使用场景进行说明，请结合自己的业务选择合适的接入方式

|  subspec  | 说明 |  适用场景 |  
| :----: | :------: | :------: |
| Standard_Base_AliVCSDK_PremiumLive |  标准集成，且依赖AliVCSDK_PremiumLive |  直播场景
| Standard_Base_AliVCSDK_Premium     |  标准集成，且依赖AliVCSDK_Premium | 直播+点播场景，使用了短视频SDK
| UI_Base_AliVCSDK_PremiumLive       |  含UI集成，且依赖AliVCSDK_PremiumLive | 直播场景
| UI_Base_AliVCSDK_Premium           |  含UI集成，且依赖AliVCSDK_Premium | 直播+点播场景，使用了短视频SDK

> 有没有使用短视频SDK可以在查看你的APP是否引入了AliyunVideoSDKPro、AliyunVideoSDKStd、AliyunVideoSDKBasic

- 修改podfile       

删除之前的所有集成，包括（AlivcLivePusher、AliPlayer、Queen、AliyunVideoSDKPro、AliyunVideoSDKStd、AliyunVideoSDKBasic），引入AlivcVpaas，根据自己的应用场景，选择合适subspec，版本为3.0.0.20221207001，如下
```ruby
platform :ios, '10.0'

source 'https://github.com/CocoaPods/Specs.git'

target 'app target' do
  
  pod 'AlivcVpaas/Standard_Base_AliVCSDK_PremiumLive', '3.0.0.20221207001'
  
end
```

- 执行“pod install --repo-update”
  
- SDK集成完成

### 2、工程配置

- 编译设置

  - 配置Build Setting > Linking > Other Linker Flags ，添加-ObjC。
  - 配置Build Setting > Build Options > Enable Bitcode，设为NO。
  
- 打开工程info.Plist，添加NSCameraUsageDescription和NSMicrophoneUsageDescription权限

- 如果你需要在APP后台时继续直播，那么需要在XCode中开启“Background Modes”

- 配置License，参考[License配置](https://help.aliyun.com/document_detail/440004.html#section-51r-40z-j1w)


### 3、启动初始化

在app启动后，需要进行SDK相关配置，主要包括注册SDK、设置Log、启动美颜模型下载等，否则无法使用
```ObjC
#import <AliVCSDK_PremiumLive/AliVCSDK_PremiumLive.h>


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [AlivcLiveBase registerSDK];
    [AlivcLiveBase setLogLevel:AlivcLivePushLogLevelDebug];
    [AlivcLiveBase setLogPath:NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject maxPartFileSizeInKB:1024*100];
    BOOL ret = [[QueenMaterial sharedInstance] requestMaterial:kQueenMaterialModel];
    if (ret) {
        NSLog(@"下载Queen模型");
    }

    // 你的其他初始化...


    
    return YES;
}
```

### 4、下载美颜模型数据   
主播端，需要确保美颜模型数据下载完毕，才能进入房间开播，否则美颜无法生效
```ObjC

#import <AliVCSDK_PremiumLive/AliVCSDK_PremiumLive.h>

// 美颜管理器
@interface AUILiveCheckQueenManager :NSObject <QueenMaterialDelegate>

@property (nonatomic, copy) void (^checkResult)(BOOL completed);

@end

@implementation AUILiveCheckQueenManager

+ (instancetype)manager {
    static AUILiveCheckQueenManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AUILiveCheckQueenManager alloc] init];
    });
    return manager;
}

+ (void)checkCompleted:(void (^)(BOOL completed))completed {
    [AUILiveCheckQueenManager manager].checkResult = completed;
    [[AUILiveCheckQueenManager manager] startCheck];
}

- (void)startCheck {
    
    BOOL result = [[QueenMaterial sharedInstance] requestMaterial:kQueenMaterialModel];
    if (!result) {
        if (self.checkResult) {
            self.checkResult(YES);
        }
    }
    else {
        NSLog(@"正在下载美颜模型中，请等待");
        [QueenMaterial sharedInstance].delegate = self;
    }
}

#pragma mark - QueenMaterialDelegate

- (void)queenMaterialOnReady:(kQueenMaterialType)type {
    // 资源下载成功
    if (type == kQueenMaterialModel) {
        NSLog(@"资源下载成功");
        if (self.checkResult) {
            self.checkResult(YES);
        }
    }
}

- (void)queenMaterialOnProgress:(kQueenMaterialType)type withCurrentSize:(int)currentSize withTotalSize:(int)totalSize withProgess:(float)progress {
    // 资源下载进度回调
    if (type == kQueenMaterialModel) {
        NSLog(@"====正在下载资源模型，进度：%f", progress);
    }
}

- (void)queenMaterialOnError:(kQueenMaterialType)type {
    // 资源下载出错
    if (type == kQueenMaterialModel){
        NSLog(@"资源下载出错");
        if (self.checkResult) {
            self.checkResult(NO);
        }
    }
}

@end


- (void)createLiveAction {
    // 检查美颜
    [AUILiveCheckQueenManager checkCompleted:^(BOOL completed) {
        if (completed) {
            // 创建主播房间并进入
            AIRBDAnchorViewController* anchorViewController = [[AIRBDAnchorViewController alloc]init];
            anchorViewController.roomModel = [[AIRBDRoomInfoModel alloc] init];
            anchorViewController.roomModel.title = @"";
            anchorViewController.roomModel.notice = @"";
            anchorViewController.roomModel.userID = [AIRBDLoginManager defaultManager].userID;
            anchorViewController.roomModel.config = [AIRBDLoginManager defaultManager].config;
            [self.navigationController pushViewController:anchorViewController animated:YES];
            [self.navigationController setNavigationBarHidden:YES];
            [anchorViewController createRoomWithCompletion:^(NSString * _Nonnull roomID) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    anchorViewController.roomModel.roomID = roomID;
                    [anchorViewController enterRoom];
                });
            }];
        }
    }];
}

```