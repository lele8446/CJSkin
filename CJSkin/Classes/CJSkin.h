//
//  CJSkin.h
//  CJSkin
//
//  Created by lele8446 on 01/16/2019.
//  Copyright (c) 2019 lele8446. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSkinTool.h"
#import "NSObject+CJSkin.h"
#import "UIKit+CJSkin.h"

//换肤操作自定义错误码
#define CJSkinErrorCode    -19999

@interface CJSkin : NSObject
/** 默认皮肤包名字 */
@property (nonatomic, copy, readonly) NSString *defaultSkinName;
/** 默认皮肤包信息 */
@property (nonatomic, copy, readonly) NSDictionary *defaultSkinInfo;
/** 当前皮肤包名字 */
@property (nonatomic, copy, readonly) NSString *skinName;
/** 当前皮肤包信息 */
@property (nonatomic, copy, readonly) NSDictionary *skinInfo;
/**记录所有皮肤配置信息的 Dictionary */
@property (nonatomic, strong, readonly) NSMutableDictionary *skinPlistInfo;

/** CJSkin单例 */
+ (instancetype)manager;
/** 当前皮肤包名字 */
+ (NSString *)skinName;

/**
 主动设置换肤配置CJSkin.plist文件的解密内容
 
 针对App安全保密性要求，可在项目编译之前通过脚本将CJSkin.plist文件进行加密，再在App启动执行时调用该方法获取CJSkin.plist文件的解密内容
 
 注意⚠️：必须在所有控件设置皮肤属性前调用该方法，建议在 application:willFinishLaunchingWithOptions: 或 application:didFinishLaunchingWithOptions: 的第一行代码中设置

 @param setUpBlock 设置回调，返回配置对应的NSDictionary
 */
+ (void)setUpDecodeSkinPlistBlock:(NSDictionary *(^)(NSString *CJSkinPlistPath))setUpBlock;

/**
 触发换肤

 @param skinName 皮肤包名
 @param resultBlock 换肤结果回调
 @return 换肤结果
 */
+ (BOOL)changeSkinWithName:(NSString *)skinName resultBlock:(void(^)(NSError *error))resultBlock;

/**
 下载皮肤包压缩资源并自动解压更新
 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 - Example.zip
    - CJSkin.plist
    - newSkin
        - top.png
        - bottom.png
        - ...
 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 皮肤包压缩资源示例说明：
 1、压缩包内必须包含 CJSkin.plist 皮肤配置说明文件，“newSkin”文件夹表示新增皮肤包名称（新增皮肤包可以多个），其与CJSkin.plist处于同级文件目录下
 2、CJSkin.plist 文件内填写"newSkin"皮肤的配置信息，如果有多个皮肤则全部都要对应填写
 3、“newSkin”文件夹内放置该皮肤包的所有图片资源，如果图片有别名则在CJSkin.plist内配置说明；
     例如：{"newSkin":{"Image":{"顶部图片":"top"}}}，key为“顶部图片”，对应的实际图片可以是top@2x.png、top@3x.png，或者top.jpeg
 4、将"newSkin"文件夹、CJSkin.plist文件放入新建文件夹（Example），压缩为"Example.zip"则是最终的皮肤包压缩资源
 
 @param skinZipResourceUrl    压缩包资源下载地址
 @param parameters            请求参数
 @param cookies               请求cookies
 @param downloadProgressBlock 下载进度回调
 @param resultBlock 结果回调
 */
+ (void)downloadSkinZipResourceWithUrl:(NSString *)skinZipResourceUrl
                            parameters:(id)parameters
                               cookies:(NSDictionary <NSString*, NSString*>*)cookies
                              progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                           resultBlock:(void(^)(BOOL success, NSError *error))resultBlock;

/**
 更新皮肤包配置信息（只是更新新皮肤包的配置信息，新皮肤内的网络图片在需要显示的时候才会加载）

 @param skinPlistInfo 需要更新的皮肤信息
 @param resultBlock 更新皮肤包结果回调
 */
+ (void)updateSkinPlistInfo:(NSDictionary *)skinPlistInfo resultBlock:(void(^)(BOOL success, NSError *error))resultBlock;

/**
 删除指定皮肤包，如果删除的刚好是当前皮肤包，则将APP皮肤更换为默认模式

 @param skinName 皮肤包名
 @param resultBlock 删除结果回调
 @return 删除结果
 */
+ (BOOL)removeSkinPackWithName:(NSString *)skinName resultBlock:(void(^)(NSError *error))resultBlock;

/**
 清除所有在线皮肤图片缓存

 @param completion 清除结果回调
 */
+ (void)clearAllSkinImageCache:(void(^)(BOOL result, NSString *str))completion;

/**
 是否从main bundle内重新读取皮肤配置，若设置，可调试修改 CJSkin.plist 配置中的内容，否则从 app 沙盒内的读取配置
 如果开启，必须在任意控件设置换肤属性前调用
 此开关只在Debug模式下有效（注意⚠️：如果组件是以lib引入，lib要判断下是不是Debug模式下包）
 */
+ (void)loadSkinInfoFromBundle;
@end



/* CJSkin换肤通知 */
UIKIT_EXTERN NSNotificationName const CJSkinUpdateNotification;

/* 换肤配置 CJSkin.plist 文件名 */
#define CJ_SKIN_PLIST_NAME       @"CJSkin"
/* 默认皮肤包名 */
#define CJ_SKIN_DEFAULT_NAME     @"default"
