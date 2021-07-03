//
//  CJSkinTool.m
//  CJSkin
//
//  Created by lele8446 on 01/16/2019.
//  Copyright (c) 2019 lele8446. All rights reserved.
//

#import "CJSkinTool.h"
#import "CJSkin.h"
#import "CJFileDownloader.h"

NSNotificationName const CJSkinImageHaveDownloadedNotification         = @"CJ.skin.imageHaveDownloaded.notification";
NSNotificationName const CJSkinUpdateAndImageDownloadAgainNotification = @"CJ.skin.skinUpdateAndImageDownloadAgain.notification";

/** 换肤配置文件 CJSkin.plist 中固定的key 值 */
static NSString * const CJSkinColorTypeKey                = @"Color";
static NSString * const CJSkinImageTypeKey                = @"Image";
static NSString * const CJSkinFontTypeKey                 = @"Font";
static NSString * const CJSkinFontNameKey                 = @"Name";
static NSString * const CJSkinFontSizeKey                 = @"Size";

#define force_inline __inline__ __attribute__((always_inline))
/** rgb颜色 16进制 */
#define CJSkinColorRGB16(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1]

#define CJSkinImageErrorCode    -29999

/**
 十六进制字符串转数字
 
 @param hexString 十六进制字符串（表示颜色）
 @return 十六进制数字
 */
FOUNDATION_EXPORT NSInteger NumberWithHexString(NSString *hexString) {
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    int hexNumber;
    sscanf(hexChar, "%x", &hexNumber);
    return (NSInteger)hexNumber;
}

/**
 根据key获取皮肤信息(Color、Image结果为NSString，Font为NSDictionary)

 @param info 当前皮肤信息
 @param key 皮肤值对应的key
 @param type 皮肤值类型
 @return 皮肤值
 */
static force_inline id SkinPackValueForKey(NSDictionary *info, NSString *key, CJSkinValueType type){
    id value = nil;
    NSDictionary *valueInfo = nil;
    if (type == CJSkinValueTypeColor || type == CJSkinValueTypeImageFromColor) {
        valueInfo = [info valueForKey:CJSkinColorTypeKey];
        value = (NSString *)[valueInfo valueForKey:key];
    }
    else if (type == CJSkinValueTypeImage) {
        valueInfo = [info valueForKey:CJSkinImageTypeKey];
        value = (NSString *)[valueInfo valueForKey:key];
    }
    else if (type == CJSkinValueTypeFont) {
        valueInfo = [info valueForKey:CJSkinFontTypeKey];
        value = (NSDictionary *)[valueInfo valueForKey:key];
    }
    return value;
}
/**不同皮肤包下的缓存路径 */
FOUNDATION_EXPORT NSString* SkinCachePath(NSString *skinName) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *skinImageCachePathName = @"CJSkin";
    if (skinName.length > 0) {
        skinImageCachePathName = [NSString stringWithFormat:@"CJSkin/%@",skinName];
    }
    path = [NSString stringWithFormat:@"%@/%@",path,skinImageCachePathName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

@interface CJSkinTool () {
    
}
@property (nonatomic, assign) BOOL isDefaultSkin;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, assign) CJSkinValueType valueType;
/**皮肤资源为网络图片，图片对应的url */
@property (nonatomic, copy) NSString *imageUrl;
/**当前皮肤包图片已经下载过 */
@property (nonatomic, assign) BOOL imageAlreadyDownloadedSkin;
@property (nonatomic, assign) UIImageRenderingMode imageRenderingMode;
@property (nonatomic, assign) NSTimeInterval skinColorChangeInterval;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CJSkinFontType fontType;
@property (nonatomic, strong) id defaultValue;
+ (BOOL)imagePathIsUrl:(NSString *)str;
@end

@implementation CJSkinTool

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)initWithKey:(NSString *)key valueType:(CJSkinValueType)valueType {
    self = [super init];
    if (self) {
        _alpha = 1;
        _key = key;
        _valueType = valueType;
        _imageRenderingMode = -1;
        _size = CGSizeMake(1.0f, 1.0f);
        _imageUrl = SkinPackValueForKey([CJSkin manager].skinInfo,key,CJSkinValueTypeImage);
        if (valueType == CJSkinValueTypeImage) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skinUpdate) name:CJSkinUpdateAndImageDownloadAgainNotification object:nil];
        }
    }
    return self;
}
- (void)skinUpdate {
    self.imageAlreadyDownloadedSkin = NO;
}

+ (CJSkinTool *)skinToolWithKey:(NSString *)key type:(CJSkinValueType)type {
    CJSkinTool *skinTool = [[CJSkinTool alloc]initWithKey:key valueType:type];
    CJSkinTool *defaultSkinTool = [CJSkinTool defaultSkinToolWithKey:key type:type];
    skinTool.defaultValue = [defaultSkinTool skinValue];
    return skinTool;
}

+ (CJSkinTool *)defaultSkinToolWithKey:(NSString *)key type:(CJSkinValueType)type {
    CJSkinTool *skinTool = [[CJSkinTool alloc]initWithKey:key valueType:type];
    skinTool.isDefaultSkin = YES;
    return skinTool;
}

+ (BOOL)skinExistsWithKey:(NSString *)key type:(CJSkinValueType)type {
    BOOL result = YES;
    NSDictionary *skinInfo = [CJSkin manager].skinInfo;
    id skinValue = nil;
    if (type == CJSkinValueTypeColor) {
        skinValue = SkinPackValueForKey(skinInfo, key, CJSkinValueTypeColor);
    }
    else if (type == CJSkinValueTypeFont) {
        skinValue = SkinPackValueForKey(skinInfo, key, CJSkinValueTypeFont);
    }
    else if (type == CJSkinValueTypeImage) {
        NSString *imageUrl = SkinPackValueForKey(skinInfo,key,CJSkinValueTypeImage);
        skinValue = [CJSkinTool skinImageForKey:key skinName:[CJSkin manager].skinName imageUrl:imageUrl];
    }
    else if (type == CJSkinValueTypeImageFromColor) {
        skinValue = SkinPackValueForKey(skinInfo, key, CJSkinValueTypeColor);
    }
    if (!skinValue) {
        result = NO;
    }
    return result;
}

- (id)skinValue {
    id value = nil;
    if (self.valueType == CJSkinValueTypeColor) {
        value = [self skinColorForKey:self.key];
    }
    else if (self.valueType == CJSkinValueTypeFont) {
        value = [self skinFontForKey:self.key];
    }
    else if (self.valueType == CJSkinValueTypeImage) {
        value = [self skinImageForKey:self.key];;
    }
    else if (self.valueType == CJSkinValueTypeImageFromColor) {
        value = [self skinImageFromColorForKey:self.key];;
    }
//    NSLog(@"retain  count = %ld",CFGetRetainCount((__bridge  CFTypeRef)(value)));
    return value;
}
/** 获取颜色色值 */
- (id)skinColorForKey:(NSString *)key {
    NSDictionary *skinInfo = [CJSkin manager].skinInfo;
    NSString *skinName = [CJSkin manager].skinName;
    if (self.isDefaultSkin) {
        skinInfo = [CJSkin manager].defaultSkinInfo;
        skinName = [CJSkin manager].defaultSkinName;
    }
    NSString *colorValue = SkinPackValueForKey(skinInfo, key, CJSkinValueTypeColor);
    id color = nil;
    if (colorValue.length > 0) {
        color = CJSkinColorRGB16(NumberWithHexString(colorValue));
    }
    if (!color) {
        color = self.defaultValue;
        if (!color) {
            if (self.isDefaultSkin) {
                NSLog(@"CJSkin 当前皮肤包：%@，颜色色值、默认色值均不存在：%@，defaultValue取 [UIColor whiteColor]",skinName,key);
            }
            color = [UIColor whiteColor];
        }else{
            NSLog(@"CJSkin 当前皮肤包：%@，获取颜色色值不存在：%@，降级读取 defaultValue 成功",skinName,key);
        }
    }
    if (self.alpha < 1) {
        color = [color colorWithAlphaComponent:self.alpha];
    }
    return color;
}
/** 获取字体 */
- (id)skinFontForKey:(NSString *)key {
    NSDictionary *skinInfo = [CJSkin manager].skinInfo;
    NSString *skinName = [CJSkin manager].skinName;
    if (self.isDefaultSkin) {
        skinInfo = [CJSkin manager].defaultSkinInfo;
        skinName = [CJSkin manager].defaultSkinName;
    }
    NSDictionary *fontValue = SkinPackValueForKey(skinInfo, key, CJSkinValueTypeFont);
    id font = nil;
    if (fontValue) {
        NSString *fontName = [fontValue valueForKey:CJSkinFontNameKey];
        CGFloat fontSize = [[fontValue valueForKey:CJSkinFontSizeKey] floatValue];
        fontSize = (fontSize==0)?14:fontSize;
        if (fontName.length > 0) {
            font = [UIFont fontWithName:fontName size:fontSize];
        }
        if (!font) {
            if (self.fontType == CJSkinFontTypeBold) {
                font = [UIFont boldSystemFontOfSize:fontSize];
            }
            else if (self.fontType == CJSkinFontTypeItalic) {
                font = [UIFont italicSystemFontOfSize:fontSize];
            }else{
                font = [UIFont systemFontOfSize:fontSize];
            }
        }
    }else{
        font = self.defaultValue;
        if (!font) {
            if (self.isDefaultSkin) {
                NSLog(@"CJSkin 当前皮肤包：%@，获取字体、默认字体均不存在：%@，defaultValue取 [UIFont systemFontOfSize:14]",skinName,key);
            }
            font = [UIFont systemFontOfSize:14];
        }else{
            NSLog(@"CJSkin 当前皮肤包：%@，获取字体不存在：%@，降级读取 defaultValue 成功",skinName,key);
        }
    }
    return font;
}
/** 根据颜色获取图片 */
- (id)skinImageFromColorForKey:(NSString *)key {
    NSDictionary *skinInfo = [CJSkin manager].skinInfo;
    NSString *skinName = [CJSkin manager].skinName;
    if (self.isDefaultSkin) {
        skinInfo = [CJSkin manager].defaultSkinInfo;
        skinName = [CJSkin manager].defaultSkinName;
    }
    NSString *colorValue = SkinPackValueForKey(skinInfo, key, CJSkinValueTypeColor);
    UIColor *color = nil;
    if (colorValue.length > 0) {
        color = CJSkinColorRGB16(NumberWithHexString(colorValue));
    }
    UIImage *image = nil;
    if (color) {
        image = [self getImageFromColor:color size:self.size];
        
        if (image && self.imageRenderingMode >= 0) {
            image = [image imageWithRenderingMode:self.imageRenderingMode];
        }
        if (!image) {
            NSLog(@"CJSkin 当前皮肤包：%@，根据颜色生成图片失败：%@，取 [UIImage new]",[CJSkin manager].skinName,key);
            image = [UIImage new];
        }
    }
    else{
        if (self.defaultValue && [self.defaultValue isKindOfClass:[UIImage class]]) {
            image = self.defaultValue;
        }else{
            image = [UIImage new];
        }
    }
    return image;
}

- (UIImage *)getImageFromColor:(UIColor *)color size:(CGSize)size {
    UIImage *image = nil;
    @autoreleasepool {
        CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

/** 获取图片 */
- (id)skinImageForKey:(NSString *)key {
    NSDictionary *skinInfo = [CJSkin manager].skinInfo;
    NSString *skinName = [CJSkin manager].skinName;
    if (self.isDefaultSkin) {
        skinInfo = [CJSkin manager].defaultSkinInfo;
        skinName = [CJSkin manager].defaultSkinName;
    }
    NSString *imageUrl = SkinPackValueForKey(skinInfo,key,CJSkinValueTypeImage);
    id image = [CJSkinTool skinImageForKey:key skinName:skinName imageUrl:imageUrl];
    if (!image) {
        image = self.defaultValue;
        if (!image) {
#if defined(DEBUG) && DEBUG
            if (self.isDefaultSkin && ![CJSkinTool imagePathIsUrl:key]) {
                NSLog(@"CJSkin 当前皮肤包：%@， 获取图片、默认图片均不存在：%@，defaultValue取 [UIImage new]",skinName,key);
            }
#endif
            image = [self getImageFromColor:[UIColor whiteColor] size:CGSizeMake(0.1, 0.1)];
        }else{
            if ([image isKindOfClass:[UIImage class]]) {
                if (self.imageRenderingMode >= 0) {
                    image = [image imageWithRenderingMode:self.imageRenderingMode];
                }
            }
            NSLog(@"CJSkin 当前皮肤包：%@， 图片不存在：%@，降级读取 defaultValue 成功",skinName,key);
        }
    }else{
        if ([image isKindOfClass:[UIImage class]]) {
            if (self.imageRenderingMode >= 0) {
                image = [image imageWithRenderingMode:self.imageRenderingMode];
            }
        }
    }
    return image;
}
/** 从指定皮肤包获取图片 */
+ (UIImage *)skinImageForKey:(NSString *)key skinName:(NSString *)skinName imageUrl:(NSString *)imageUrl {
    UIImage *image = nil;
    NSString *oldImageUrl = imageUrl;
    NSString *skinBundlePath = [[NSBundle mainBundle] pathForResource:skinName ofType:@"bundle"];
    NSBundle *skinBundle = [NSBundle bundleWithPath:skinBundlePath];
    if (skinBundle) {
        NSString *imageName = [NSString stringWithFormat:@"%@.bundle/%@",skinName,key];
        image = [UIImage imageNamed:imageName];
        if (!image) {
            NSString *imageName = [NSString stringWithFormat:@"%@.bundle/%@",skinName,imageUrl];
            image = [UIImage imageNamed:imageName];
        }
    }
    
    // 处理图片z地址为http链接，或者图片是从下载的整体皮肤压缩包里读取的情况
    if (!image && imageUrl.length > 0) {
        if ([self imagePathIsUrl:imageUrl]) {
            NSString *imageFilePath = [[CJFileDownloader manager]cacheFilePathWithUrl:[NSURL URLWithString:imageUrl] customCachePath:SkinCachePath(skinName)];
            if (imageFilePath.length > 0) {
//                image = [UIImage imageWithContentsOfFile:imageUrl];
                NSURL *imageFilePathURL = [NSURL fileURLWithPath:imageFilePath];
                NSData *imgData = [NSData dataWithContentsOfURL:imageFilePathURL options:NSDataReadingMappedIfSafe error:nil];
                image = [UIImage imageWithData:imgData scale:[UIScreen mainScreen].scale];
#if defined(DEBUG) && DEBUG
                if (!image) {
                    NSLog(@"CJSkin 当前皮肤包：%@， 获取图片出错：%@，缓存路径：%@",skinName,key,imageFilePath);
                }
#endif
            }
        }else{
            if (imageUrl.length > 1 && [[imageUrl substringToIndex:1] isEqualToString:@"/"]) {
                imageUrl = [imageUrl substringFromIndex:1];
            }
            imageUrl = [NSString stringWithFormat:@"%@/%@",SkinCachePath([CJSkin manager].skinName),imageUrl];
            image = [UIImage imageWithContentsOfFile:imageUrl];
            NSData *imgData = nil;
            if (!image) {
                NSURL *imageFilePathURL = [NSURL fileURLWithPath:imageUrl];
                imgData = [NSData dataWithContentsOfURL:imageFilePathURL options:NSDataReadingMappedIfSafe error:nil];
            }else{
                imgData = UIImagePNGRepresentation(image);
            }
            if (imgData) image = [UIImage imageWithData:imgData scale:[UIScreen mainScreen].scale];
        }
    }
    //默认default 皮肤包还会读取 Assets.xcassets 以及项目主工程中的图片
    if (!image && [skinName isEqualToString:[CJSkin manager].defaultSkinName]) {
            image = [UIImage imageNamed:key];
            if (!image) {
                if (oldImageUrl.length > 0) {
                   image = [UIImage imageNamed:oldImageUrl];
                }
            }
    }
#if defined(DEBUG) && DEBUG
    if (!image) {
        NSLog(@"CJSkin 当前皮肤包：%@， 获取从压缩包下载的图片出错，图片路径%@",skinName,imageUrl);
    }
#endif
    return image;
}
+ (BOOL)imagePathIsUrl:(NSString *)str {
    if (str == nil || str.length == 0) return NO;
    
//    //必须是在主线程调用
//    {
//        NSString *url;
//        if (![str hasPrefix:@"http://"] && ![str hasPrefix:@"https://"]) {
//            url = [NSString stringWithFormat:@"http://%@",self];
//        }else{
//            url = str;
//        }
//        return [UIApplication.sharedApplication canOpenURL:[NSURL URLWithString:url]];
//    }
    
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *matches = [detector matchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, str.length)];
    if (matches.count == 1) {
        NSTextCheckingResult *result = matches.firstObject;
        if (result.range.location == 0) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}
@end
/** 快速获取皮肤资源，颜色转换工具类实例 */
FOUNDATION_EXPORT CJSkinTool* SkinColorTool(NSString *key) {
    return [CJSkinTool skinToolWithKey:key type:CJSkinValueTypeColor];
}
/** 快速获取皮肤资源，图片转换工具类实例 */
FOUNDATION_EXPORT CJSkinTool* SkinImageTool(NSString *key) {
    return [CJSkinTool skinToolWithKey:key type:CJSkinValueTypeImage];
}
/** 快速获取皮肤资源，字体转换工具类实例 */
FOUNDATION_EXPORT CJSkinTool* SkinFontTool(NSString *key) {
    return [CJSkinTool skinToolWithKey:key type:CJSkinValueTypeFont];
}
/** 快速获取皮肤资源，根据颜色生成图片转换工具类实例 */
FOUNDATION_EXPORT CJSkinTool* SkinImageFromColorTool(NSString *key) {
    return [CJSkinTool skinToolWithKey:key type:CJSkinValueTypeImageFromColor];
}
/** 判断是否存在指定颜色 */
FOUNDATION_EXPORT BOOL SkinColorExists(NSString *key) {
    return [CJSkinTool skinExistsWithKey:key type:CJSkinValueTypeColor];
}
/** 判断是否存在指定图片 */
FOUNDATION_EXPORT BOOL SkinImageExists(NSString *key) {
    return [CJSkinTool skinExistsWithKey:key type:CJSkinValueTypeImage];
}
/** 判断是否存在指定字体 */
FOUNDATION_EXPORT BOOL SkinFontExists(NSString *key) {
    return [CJSkinTool skinExistsWithKey:key type:CJSkinValueTypeFont];
}

@implementation CJSkinTool(CJSkinColor)
+ (CJSkinTool *)SkinColorAnimated:(NSTimeInterval)skinColorChangeInterval key:(NSString *)key alpha:(CGFloat)alpha {
    CJSkinTool *skinTool = [CJSkinTool skinToolWithKey:key type:CJSkinValueTypeColor];
    skinTool.skinColorChangeInterval = skinColorChangeInterval;
    skinTool.alpha = alpha;
    return skinTool;
}
@end
FOUNDATION_EXPORT UIColor* SkinColor(NSString *key) {
    return SkinColorAnimated(key, 0);
}
FOUNDATION_EXPORT UIColor* SkinColorAnimated(NSString *key, NSTimeInterval skinColorChangeInterval) {
    return [[CJSkinTool SkinColorAnimated:skinColorChangeInterval key:key alpha:1] skinValue];
}
FOUNDATION_EXPORT UIColor* SkinColorAlpha(NSString *key, CGFloat alpha) {
    return [[CJSkinTool SkinColorAnimated:0 key:key alpha:alpha] skinValue];
}


@implementation CJSkinTool(CJSkinImage)
+ (CJSkinTool *)SkinImageRenderingMode:(UIImageRenderingMode)imageRenderingMode key:(NSString *)key {
    CJSkinTool *skinTool = [CJSkinTool skinToolWithKey:key type:CJSkinValueTypeImage];
    skinTool.imageRenderingMode = imageRenderingMode;
    return skinTool;
}
- (BOOL)needDownloadImage {
    BOOL needDownload = NO;
    if (self.valueType == CJSkinValueTypeImage) {
        NSDictionary *skinInfo = self.isDefaultSkin?[CJSkin manager].defaultSkinInfo:[CJSkin manager].skinInfo;
        NSString *imageUrl = SkinPackValueForKey(skinInfo,self.key,CJSkinValueTypeImage);
        if (imageUrl.length > 0 && [CJSkinTool imagePathIsUrl:imageUrl]) {
            NSString *imageFilePath = [[CJFileDownloader manager]cacheFilePathWithUrl:[NSURL URLWithString:imageUrl] customCachePath:SkinCachePath([CJSkin manager].skinName)];
            if (imageFilePath.length > 0) {
                needDownload = NO;
            }else{
                needDownload = !self.imageAlreadyDownloadedSkin;
            }
        }
    }
    return needDownload;
}
/**
 - CJSkinInvokeMethodForSelector: withArguments: 消息转发中 启动图片下载
 
 @param noticInfo 图片下载完成后的通知内容:
 @{
     CJSkinInvSelKey:标识包含该图片参数的方法的key,
     CJSkinImageDownloadInSkinName:下载该图片对应的皮肤包的名字
 }
 */
- (void)downloadImageWithNoticInfo:(NSDictionary *)noticInfo {
    [self downloadImageWithNoticInfo:noticInfo resultBlock:nil];
}
/**
 异步获取皮肤包下的网络图片
 */
- (void)asyncGetSkinImage:(void(^)(BOOL success, NSError *error, UIImage *image))resultBlock {
    [self downloadImageWithNoticInfo:nil resultBlock:resultBlock];
}

- (void)downloadImageWithNoticInfo:(NSDictionary *)noticInfo resultBlock:(void(^)(BOOL success, NSError *error, UIImage *image))resultBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.valueType == CJSkinValueTypeImage) {
            NSDictionary *skinInfo = [CJSkin manager].skinInfo;
            NSString *skinName = [CJSkin manager].skinName;
            if (self.isDefaultSkin) {
                skinInfo = [CJSkin manager].defaultSkinInfo;
                skinName = [CJSkin manager].defaultSkinName;
            }
            NSString *imagePath = SkinPackValueForKey(skinInfo,self.key,CJSkinValueTypeImage);
            if ([CJSkinTool imagePathIsUrl:imagePath]) {
                [self downloadImageSkinName:skinName key:self.key imageURLStr:imagePath result:^(BOOL success, NSError *error) {
                    if (success) {
                        if (resultBlock) {
                            [self getImageCacheWithSkinName:skinName imageURLStr:imagePath resultBlock:^(BOOL success, NSError *error, UIImage *image) {
                                resultBlock(success,error,image);
                            }];
                        }
                    }else{
                        if (resultBlock) {
                            resultBlock(NO,error,nil);
                        }
                    }
                    if (noticInfo) {
                        self.imageAlreadyDownloadedSkin = YES;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:CJSkinImageHaveDownloadedNotification object:noticInfo];
                        });
                    }
                }];
            }else{
                if (imagePath.length > 1 && [[imagePath substringToIndex:1] isEqualToString:@"/"]) {
                    imagePath = [imagePath substringFromIndex:1];
                }
                imagePath = [NSString stringWithFormat:@"%@/%@",SkinCachePath([CJSkin manager].skinName),imagePath];
                NSURL *imageFilePathURL = [NSURL fileURLWithPath:imagePath];
                NSData *imgData = [NSData dataWithContentsOfURL:imageFilePathURL options:NSDataReadingMappedIfSafe error:nil];
                UIImage *image = [UIImage imageWithData:imgData scale:[UIScreen mainScreen].scale];
                BOOL result = YES;
                NSError *error = nil;
                NSString *errorStr = nil;
                if (!image) {
                    result = NO;
                    errorStr = [NSString stringWithFormat:@"CJSkin 从指定皮肤资源路径读取图片失败，皮肤包：%@，图片key：%@，图片路径：%@",skinName,self.key,imagePath];
                    NSLog(@"%@",errorStr);
                    error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinImageErrorCode userInfo:@{NSLocalizedDescriptionKey:errorStr}];
                }
                if (resultBlock) {
                    resultBlock(result,error,image);
                }
                if (noticInfo) {
                    self.imageAlreadyDownloadedSkin = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:CJSkinImageHaveDownloadedNotification object:noticInfo];
                    });
                }
            }
        }
    });
}
- (void)downloadImageSkinName:(NSString *)skinName key:(NSString *)key imageURLStr:(NSString *)imageURLStr result:(void(^)(BOOL success, NSError *error))result {
    NSURL *imageURL = [NSURL URLWithString:imageURLStr];
    [[CJFileDownloader manager]CJFileDownLoadWithUrl:imageURL parameters:nil cookies:nil cachePolicy:NSURLRequestUseProtocolCachePolicy  customCachePath:SkinCachePath(skinName) taskIdentifier:nil progress:nil success:^(id taskIdentifier, BOOL cache, NSURLResponse *response, NSURL *filePath, NSString *MIMEType) {
        if (result) {
            NSError *error = nil;
            NSData *imgData = [NSData dataWithContentsOfURL:filePath options:NSDataReadingMappedIfSafe error:&error];
            UIImage *image = [UIImage imageWithData:imgData];
            BOOL success = YES;
            if (!image) {
                NSString *errorStr = [NSString stringWithFormat:@"CJSkin 图片下载后获取图片出错，皮肤包：%@，图片key：%@，缓存路径：%@,\n%@",skinName,self.key,filePath.absoluteString,error.localizedDescription];
                NSLog(@"%@",errorStr);
                error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinImageErrorCode userInfo:@{NSLocalizedDescriptionKey:errorStr}];
                success = NO;
                [[CJFileDownloader manager] clearCacheWithUrl:imageURL customCachePath:SkinCachePath(skinName) resultBlock:nil];
            }
            result(success,error);
        }
    } failure:^(id taskIdentifier, NSInteger statusCode, NSError *error) {
        NSLog(@"CJSkin 图片下载失败：%@，皮肤包名：%@，error = %@",key,skinName,error);
        if (result) {
            result(NO,error);
        }
    }];
}
//从本地缓存中获取图片
- (void)getImageCacheWithSkinName:(NSString *)skinName imageURLStr:(NSString *)imageURLStr resultBlock:(void(^)(BOOL success, NSError *error, UIImage *image))resultBlock {
    NSString *imageFilePath = [[CJFileDownloader manager]cacheFilePathWithUrl:[NSURL URLWithString:imageURLStr] customCachePath:skinName];
    BOOL result = YES;
    UIImage *image = nil;
    NSError *error = nil;
    NSString *errorStr = nil;
    if (imageFilePath.length > 0) {
        NSURL *imageFilePathURL = [NSURL fileURLWithPath:imageFilePath];
        NSData *imgData = [NSData dataWithContentsOfURL:imageFilePathURL options:NSDataReadingMappedIfSafe error:nil];
        image = [UIImage imageWithData:imgData scale:[UIScreen mainScreen].scale];
        if (!image) {
            result = NO;
            errorStr = [NSString stringWithFormat:@"CJSkin 下载后读取图片失败，皮肤包：%@，图片key：%@，缓存路径：%@",skinName,self.key,imageFilePath];
            NSLog(@"%@",errorStr);
            error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinImageErrorCode userInfo:@{NSLocalizedDescriptionKey:errorStr}];
        }
    }else{
        result = NO;
        errorStr = [NSString stringWithFormat:@"CJSkin 图片下载失败，皮肤包：%@，图片key：%@，图片地址：%@",skinName,self.key,imageURLStr];
        NSLog(@"%@",errorStr);
        error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinImageErrorCode userInfo:@{NSLocalizedDescriptionKey:errorStr}];
    }
    resultBlock(result,error,image);
}
@end
FOUNDATION_EXPORT UIImage* SkinImage(NSString *key) {
    return SkinImageRenderingMode(key, -1);
}
FOUNDATION_EXPORT UIImage* SkinImageRenderingMode(NSString *key, UIImageRenderingMode imageRenderingMode) {
    return [[CJSkinTool SkinImageRenderingMode:imageRenderingMode key:key] skinValue];
}


@implementation CJSkinTool(CJSkinImageFromColor)
+ (CJSkinTool *)SkinImageFromColorWithSize:(CGSize)size key:(NSString *)key {
    CJSkinTool *skinTool = [CJSkinTool skinToolWithKey:key type:CJSkinValueTypeImageFromColor];
    skinTool.size = size;
    return skinTool;
}
@end
FOUNDATION_EXPORT UIImage* SkinImageFromColor(NSString *key) {
    return SkinImageFromColorWithSize(key, CGSizeMake(1.0f, 1.0f));
}
FOUNDATION_EXPORT UIImage* SkinImageFromColorWithSize(NSString *key, CGSize size) {
    return [[CJSkinTool SkinImageFromColorWithSize:size key:key] skinValue];
}


@implementation CJSkinTool(CJSkinFontType)
+ (CJSkinTool *)SkinFontWithFontType:(CJSkinFontType)fontType key:(NSString *)key {
    CJSkinTool *skinTool = [CJSkinTool skinToolWithKey:key type:CJSkinValueTypeFont];
    skinTool.fontType = fontType;
    return skinTool;
}
@end
FOUNDATION_EXPORT UIFont* SkinFont(NSString *key) {
    return SkinFontWithFontType(key, CJSkinFontTypeRegular);
}
FOUNDATION_EXPORT UIFont* SkinFontWithFontType(NSString *key, CJSkinFontType fontType) {
    return [[CJSkinTool SkinFontWithFontType:fontType key:key] skinValue];
}


@implementation CJSkinNull
@end
