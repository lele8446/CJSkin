//
//  CJSkinTool.h
//  CJSkin
//
//  Created by lele8446 on 01/16/2019.
//  Copyright (c) 2019 lele8446. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class CJSkinTool;

#if (DEBUG)
    #define NSLog(...) do {                        \
        NSLog(__VA_ARGS__);                        \
    } while (0)
#else
    #define NSLog(...)
#endif


/* CJSkin换肤后皮肤包图片重新触发下载逻辑的通知 */
UIKIT_EXTERN NSNotificationName const CJSkinUpdateAndImageDownloadAgainNotification;
/* CJSkin换肤图片下载完成通知 */
UIKIT_EXTERN NSNotificationName const CJSkinImageHaveDownloadedNotification;
/**不同皮肤包下的缓存路径 */
FOUNDATION_EXPORT NSString* SkinCachePath(NSString *skinName);

/**皮肤资源类型 */
typedef NS_ENUM(NSInteger, CJSkinValueType) {
    CJSkinValueTypeColor = 0,          //颜色
    CJSkinValueTypeImage,              //图片
    CJSkinValueTypeFont,               //字体
    CJSkinValueTypeImageFromColor,     //根据颜色生成图片
};

/** 快速获取皮肤资源，颜色转换工具类实例 */
FOUNDATION_EXPORT CJSkinTool* SkinColorTool(NSString *key);
/** 快速获取皮肤资源，图片转换工具类实例 */
FOUNDATION_EXPORT CJSkinTool* SkinImageTool(NSString *key);
/** 快速获取皮肤资源，字体转换工具类实例 */
FOUNDATION_EXPORT CJSkinTool* SkinFontTool(NSString *key);
/** 快速获取皮肤资源，根据颜色生成图片转换工具类实例 */
FOUNDATION_EXPORT CJSkinTool* SkinImageFromColorTool(NSString *key);
/**
 换肤资源转换类，通过该类的实例映射获取不同皮肤包内对应的颜色、图片、字体
 */
@interface CJSkinTool : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**皮肤资源key */
@property (nonatomic, copy,   readonly) NSString *key;
/**皮肤资源类型 */
@property (nonatomic, assign, readonly) CJSkinValueType valueType;

/**
 从当前皮肤包初始化皮肤资源的实例方法

 @param key 皮肤值的key
 @param type 皮肤值的类型
 @return CJSkinTool
 */
+ (CJSkinTool *)skinToolWithKey:(NSString *)key type:(CJSkinValueType)type;

/**
 从默认皮肤包获取皮肤资源的实例方法
 
 @param key 皮肤值的key
 @param type 皮肤值的类型
 @return CJSkinTool
 */
+ (CJSkinTool *)defaultSkinToolWithKey:(NSString *)key type:(CJSkinValueType)type;

/**
 获取皮肤资源。
 1、同步方法，首先从当前皮肤包获取对应的皮肤资源（UIColor、UIImage或者UIFont），
 2、如果不存在则取 defaultValue，如果未主动设置defaultValue，则defaultValue对应默认皮肤包“default”中的同名资源，
 3、默认皮肤包“default” 中 CJSkinTool 实例对应的defaultValue 也为nil，则取：[UIColor whiteColor]、[UIFont systemFontOfSize:14]、[UIImage new]

 @return UIColor、UIImage或者UIFont
 */
- (id)skinValue;

/// 判断资源是否存在
/// @param key 皮肤值的key
/// @param type 皮肤值的类型
+ (BOOL)skinExistsWithKey:(NSString *)key type:(CJSkinValueType)type;
@end

/**
 从当前皮肤包，快速获取颜色
 */
FOUNDATION_EXPORT UIColor* SkinColor(NSString *key);
/**
 从当前皮肤包，快速获取，并指定颜色透明度
 */
FOUNDATION_EXPORT UIColor* SkinColorAlpha(NSString *key, CGFloat alpha);
/**
 从当前皮肤包，快速获取，并指定颜色切换动画时间
 */
FOUNDATION_EXPORT UIColor* SkinColorAnimated(NSString *key, NSTimeInterval skinColorChangeInterval);
/**
 判断是否存在指定颜色
 */
FOUNDATION_EXPORT BOOL SkinColorExists(NSString *key);
@interface CJSkinTool (CJSkinColor)
/** 皮肤资源为颜色，换肤切换颜色时动画的持续时间（值为0时为无动画， 默认0） */
@property (nonatomic, assign, readwrite) NSTimeInterval skinColorChangeInterval;
/**皮肤资源为颜色，当前皮肤包颜色加载失败时候的默认颜色（默认defaultValue对应默认皮肤包“default”中的同名资源，如果均不存在则取[UIColor whiteColor]） */
@property (nonatomic, strong, readwrite) UIColor *defaultValue;
/** 皮肤资源为颜色，颜色透明度（默认1） */
@property (nonatomic, assign, readwrite) CGFloat alpha;
@end



/**
 从当前皮肤包，快速获取图片（只能获取本地图片）
 注意⚠️：如果当前皮肤包下该图片未下载成功，则返回的是[UIImage new]，此时应该使用 CJSkinTool 的 -asyncGetSkinImage:方法获取图片
 */
FOUNDATION_EXPORT UIImage* SkinImage(NSString *key);
/**
 从当前皮肤包，快速获取图片，并指定图片渲染模式（只能获取本地图片）
 注意⚠️：如果当前皮肤包下该图片未下载成功，则返回的是[UIImage new]，此时应该使用 CJSkinTool 的 -asyncGetSkinImage:方法获取图片
 */
FOUNDATION_EXPORT UIImage* SkinImageRenderingMode(NSString *key, UIImageRenderingMode imageRenderingMode);
/**
 判断是否存在指定图片
 */
FOUNDATION_EXPORT BOOL SkinImageExists(NSString *key);
@interface CJSkinTool (CJSkinImage)
/**皮肤资源为图片，是否需要下载 */
@property (nonatomic, assign, readonly) BOOL needDownloadImage;
/**皮肤资源为网络图片，图片对应的url （可能为nil）*/
@property (nonatomic, copy,   readonly) NSString *imageUrl;
/**皮肤资源为图片，图片渲染模式 */
@property (nonatomic, assign, readwrite) UIImageRenderingMode imageRenderingMode;
/**皮肤资源为图片，当前皮肤包图片加载失败时候的默认图片（默认defaultValue对应默认皮肤包“default”中的同名资源，如果均不存在则取[UIImage new]）；当前皮肤包图片存在时，defaultValue=nil */
@property (nonatomic, strong, readwrite) UIImage *defaultValue;
/**
 异步获取皮肤包下的网络图片

 @param resultBlock 获取网络图片结果回调
 */
- (void)asyncGetSkinImage:(void(^)(BOOL success, NSError *error, UIImage *image))resultBlock;
@end



/**
 从当前皮肤包，快速读取颜色生成图片
 */
FOUNDATION_EXPORT UIImage* SkinImageFromColor(NSString *key);
/**
 从当前皮肤包，快速读取颜色生成图片皮肤资源，并指定图片大小
 */
FOUNDATION_EXPORT UIImage* SkinImageFromColorWithSize(NSString *key, CGSize size);
@interface CJSkinTool (CJSkinImageFromColor)
/**皮肤资源为由颜色生成的图片，图片大小 (默认 {1.0f,1.0f} ) */
@property (nonatomic, assign, readwrite) CGSize size;
/**皮肤资源为由颜色生成的图片，当前皮肤包图片加载失败时候的默认图片（默认defaultValue对应默认皮肤包“default”中的同名资源，如果均不存在则取[UIImage new]） */
@property (nonatomic, strong, readwrite) UIImage *defaultValue;
@end



/**皮肤资源为字体，字体类型(正常、加粗、斜体)，默认正常 */
typedef NS_ENUM(NSInteger, CJSkinFontType) {
    CJSkinFontTypeRegular = 0,          //正常
    CJSkinFontTypeBold,                 //加粗
    CJSkinFontTypeItalic,               //斜体
};
/**
 从当前皮肤包，快速获取字体
 */
FOUNDATION_EXPORT UIFont* SkinFont(NSString *key);
/**
 从当前皮肤包，快速获取字体
 */
FOUNDATION_EXPORT UIFont* SkinFontWithFontType(NSString *key, CJSkinFontType fontType);
/**
 判断是否存在指定字体
 */
FOUNDATION_EXPORT BOOL SkinFontExists(NSString *key);
@interface CJSkinTool (CJSkinFont)
/**皮肤资源为字体，字体类型(正常、加粗、斜体)，默认正常。只在字体样式为系统字体的情况下有效 */
@property (nonatomic, assign, readwrite) CJSkinFontType fontType;
/**皮肤资源为字体，当前皮肤包字体加载失败时候的默认字体（默认defaultValue对应默认皮肤包“default”中的同名资源，如果均不存在则取[UIFont systemFontOfSize:14]） */
@property (nonatomic, strong, readwrite) UIFont *defaultValue;
@end


@interface CJSkinNull : NSObject
@end
