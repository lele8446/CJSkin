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
 注意⚠️：必须在所有控件设置皮肤属性前调用该方法，建议在 application:willFinishLaunchingWithOptions: 或 application:didFinishLaunchingWithOptions:的第一行代码中设置

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
    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    - Example.zip
      - CJSkin.plist
      - newSkin
        - top.png
        - bottom.png
        - ...
    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    注意⚠️： 1、压缩包必须包含 CJSkin.plist 文件
            2、假设新增皮肤包名为"newSkin"的皮肤，需要下发的皮肤资源结构示例：
                 2.1、新建以"newSkin"命名的文件夹，将"newSkin"皮肤下的图片全部放在 "newSkin"文件夹内
                 2.2、CJSkin.plist 文件内填写"newSkin"皮肤的配置信息，其中Image配置为{"顶部图片":"top.png","底部图片":"bottom.png"...}
                 2.3、将"newSkin"文件夹、CJSkin.plist文件放入新建文件夹（Example），并压缩为"Example.zip"
*/
/**
 下载压缩包资源并自动解压更新
 
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
 是否从main bundle内重新读取皮肤配置，若开启，可调试修改 CJSkin.plist 配置中的内容，否则从 app 沙盒内的读取配置
 如果开启，必须在任意控件设置换肤属性前调用
 此开关只在Debug模式下有效（注意⚠️：如果组件是以lib引入，lib要判断下是不是Debug模式下包）
 默认 NO
 @param fromBundle 调试开关
 */
+ (void)loadSkinInfoFromBundle:(BOOL)fromBundle;
@end



/* CJSkin换肤通知 */
UIKIT_EXTERN NSNotificationName const CJSkinUpdateNotification;

/* 换肤配置 CJSkin.plist 文件名 */
#define CJ_SKIN_PLIST_NAME       @"CJSkin"
/* 默认皮肤包名 */
#define CJ_SKIN_DEFAULT_NAME     @"default"
