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

/// 沙盒中记录所有在线图片缓存的文件夹名称
#define CJSkinImageCahcePathName    @"CJSkinImage"

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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
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

/** 皮肤资源为网络图片，图片下载成功后对应的图片内存缓存*/
FOUNDATION_EXPORT NSCache* SkinImageCache() {
    NSCache *imageCache = [CJSkin.manager valueForKey:@"imageCache"];
    return imageCache;
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
    if (type != CJSkinValueTypeImage) {
        CJSkinTool *defaultSkinTool = [CJSkinTool defaultSkinToolWithKey:key type:type];
        skinTool.defaultValue = [defaultSkinTool skinValue];
    }
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
        CJSkinTool *skinTool = [CJSkinTool skinToolWithKey:key type:CJSkinValueTypeImage];
        skinValue = [skinTool getSkinImageForKey:key skinInfo:[CJSkin manager].skinInfo skinName:[CJSkin manager].skinName readDefaultValue:NO needDownload:NO completionHandler:^(BOOL result, NSString *message, NSString *skinName, UIImage *image, BOOL networkImage) {
        }];
        
//        NSString *imageUrl = SkinPackValueForKey(skinInfo,key,CJSkinValueTypeImage);
//        skinValue = [CJSkinTool skinImageForKey:key skinName:[CJSkin manager].skinName imageUrl:imageUrl];
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
        value = [self skinImageForKey:self.key skinInfo:CJSkin.manager.skinInfo skinName:CJSkin.manager.skinName];
        
//        value = [self skinImageForKey:self.key];
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

///TODO: 获取图片
/// 获取图片
- (id)skinImageForKey:(NSString *)key skinInfo:(NSDictionary *)skinInfo skinName:(NSString *)skinName {
    UIImage *image = [self getSkinImageForKey:key skinInfo:skinInfo skinName:skinName readDefaultValue:YES needDownload:YES completionHandler:^(BOOL result, NSString *message, NSString *skinName, UIImage *image, BOOL networkImage) {
//        if (result && [skinName isEqualToString:[CJSkin skinName]] && networkImage) {
//
//        }
    }];
    if (self.imageRenderingMode >= 0 && [image isKindOfClass:[UIImage class]]) {
        image = [image imageWithRenderingMode:self.imageRenderingMode];
    }
    return image;
}
- (id)getSkinImageForKey:(NSString *)key
                skinInfo:(NSDictionary *)skinInfo
                skinName:(NSString *)skinName
        readDefaultValue:(BOOL)readDefaultValue
            needDownload:(BOOL)needDownload
       completionHandler:(void(^)(BOOL result, NSString* message, NSString* skinName, UIImage* image, BOOL networkImage))completionHandler {
    //从内存缓存NSCache读取
    UIImage *image = [SkinImageCache() objectForKey:[self imageCacheKey:key skinName:skinName]];
    if (image) {
        completionHandler(YES,@"获取图片成功",skinName,image,NO);
        return image;
    }
    
    //判断CJSkin.plist记录的皮肤信息包中是否存在该图片信息，如果没有，图片名取key
    NSString *imageName = SkinPackValueForKey(skinInfo,key,CJSkinValueTypeImage);
    if (!imageName || imageName.length == 0) {
        imageName = key;
    }
    
    /// 图片无需下载，图片引入包含3种方式：
    /// 1、默认皮肤包，Assets.xcassets内或直接放在项目工程下
    /// 2、其他皮肤包，项目初始化阶段以skin1.bundle的形式导入
    /// 3、在线下载的皮肤压缩包，解压后存储在：Library/Caches/CJSkin/皮肤包名/xxx.png路径下
    if (![CJSkinTool imagePathIsUrl:imageName]) {
        //默认皮肤包，首先从Assets.xcassets或项目工程中读取图片
        if ([skinName isEqualToString:CJ_SKIN_DEFAULT_NAME]) {
            image = [UIImage imageNamed:imageName];
            if (image) {
                completionHandler(YES,@"获取图片成功",skinName,image,NO);
                return image;
            }
        }
        
        //再从 Bundle 文件夹读取图片
        NSString *skinBundlePath = [[NSBundle mainBundle] pathForResource:skinName ofType:@"bundle"];
        NSBundle *skinBundle = [NSBundle bundleWithPath:skinBundlePath];
        if (skinBundle) {
            NSString *imageNameStr = [NSString stringWithFormat:@"%@.bundle/%@",skinName,imageName];
            image = [UIImage imageNamed:imageNameStr];
            if (image) {
                completionHandler(YES,@"获取图片成功",skinName,image,NO);
                return image;
            }
        }
        
        //在线下载的皮肤压缩包，从沙盒路径读取：Library/Caches/CJSkin/皮肤包名/xxx.png
        if (imageName.length > 1 && [[imageName substringToIndex:1] isEqualToString:@"/"]) {
            imageName = [imageName substringFromIndex:1];
        }
        NSString *localFilePath = SkinCachePath(skinName);
        image = [self getImageFromLocalPath:localFilePath skinName:skinName key:key imageName:imageName];
        if (image) {
            completionHandler(YES,@"获取图片成功",skinName,image,NO);
            return image;
        }
        
        completionHandler(NO,@"皮肤图片不存在",skinName,image,NO);
    }
    ///CJSkin.plist记录的皮肤信息包中，该图片是需要在线下载的图片
    else{
        //判断缓存是否存在
        //查找指定url是否存在沙盒缓存，默认一个url对应的缓存路径下只会有一份文件，如果存在多个则认为缓存无效并删除
        NSString *localFilePath = [[CJFileDownloader manager]cacheFilePathWithUrl:[NSURL URLWithString:imageName] customCachePath:SkinCachePath([NSString stringWithFormat:@"%@/%@",CJSkinImageCahcePathName,skinName])];
        if (localFilePath.length > 0) {
            //此处的localFilePath应该是包含具体文件名（含后缀）的缓存路径，因此获取图片imageName=""
            image = [self getImageFromLocalPath:localFilePath skinName:skinName key:key imageName:@""];
            if (image) {
                completionHandler(YES,@"获取图片成功",skinName,image,NO);
                return image;
            }
        }
        //未下载成功的网络图片，开始下载逻辑判断
        else {
            if (needDownload) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    /// TODO: 开始下载
                    NSString *cachePath = SkinCachePath([NSString stringWithFormat:@"%@/%@",CJSkinImageCahcePathName,skinName]);
                    [self downloadImage:imageName cachePath:cachePath result:^(BOOL success, NSString *imagePath, NSError *error) {
                        if (success) {
                            UIImage *resultImage = [self getImageFromLocalPath:imagePath skinName:skinName key:key imageName:@""];
                            if (resultImage) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completionHandler(YES,@"下载图片成功",skinName,resultImage,YES);
                                });
                            }else{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completionHandler(NO,@"下载图片后解析出错",skinName,nil,YES);
                                });
                            }
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completionHandler(NO,error.localizedDescription,skinName,nil,YES);
                            });
                        }
                    }];
                });
            }
            else {
                //只是判断当前皮肤包是否存在指定图片，无需下载，只需返回空图片即可
                image = nil;
                completionHandler(NO,@"皮肤图片未下载",skinName,nil,YES);
            }
        }
    }
    
    //降级读取默认皮肤包资源
    if (readDefaultValue) {
        if (![skinName isEqualToString:CJ_SKIN_DEFAULT_NAME]) {
            image = [self getSkinImageForKey:key skinInfo:CJSkin.manager.defaultSkinInfo skinName:CJSkin.manager.defaultSkinName readDefaultValue:readDefaultValue needDownload:needDownload completionHandler:^(BOOL result, NSString *message, NSString *skinName, UIImage *image, BOOL networkImage) {
            }];
#if defined(DEBUG) && DEBUG
            NSLog(@"ZWTSkin 当前皮肤包：%@，图片资源不存在，降级读取 defaultValue，key= %@",skinName,key);
#endif
        }
        //如果已经是默认皮肤包，返回UIImage.init()
        else{
            image = [self getImageFromColor:[UIColor whiteColor] size:CGSizeMake(0.1, 0.1)];
#if defined(DEBUG) && DEBUG
            NSLog(@"ZWTSkin 当前皮肤包：%@，图片资源不存在，defaultValue取 UIImage.init()，key= %@",skinName,key);
#endif
        }
    }
    
    return image;
}

- (UIImage *)getImageFromLocalPath:(NSString *)imagePath skinName:(NSString *)skinName key:(NSString *)key imageName:(NSString *)imageName {
    NSString* imageFilePath = [self imageExists:imagePath imageName:imageName];
    if (imageFilePath.length == 0) {
        return nil;
    }
    UIImage *image = nil;
    if ([self strContainsIgnoringCase:imageFilePath find:@"@1x.png"] ||
        [self strContainsIgnoringCase:imageFilePath find:@"@2x.png"] ||
        [self strContainsIgnoringCase:imageFilePath find:@"@3x.png"]) {
        imageFilePath = [imageFilePath stringByReplacingOccurrencesOfString:@"@1x" withString:@""];
        imageFilePath = [imageFilePath stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
        imageFilePath = [imageFilePath stringByReplacingOccurrencesOfString:@"@3x" withString:@""];
        image = [[UIImage alloc]initWithContentsOfFile:imageFilePath];
        if (image) {
            //将图片加入内存缓存
            [SkinImageCache() setObject:image forKey:[self imageCacheKey:key skinName:skinName]];
        }
    }
    else{
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:imageFilePath] options:NSDataReadingMappedIfSafe error:nil];
        image = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
        if (image) {
            //将图片加入内存缓存
            [SkinImageCache() setObject:image forKey:[self imageCacheKey:key skinName:skinName]];
        }else{
            //获取沙盒缓存图片失败，删除无效缓存
            [self deleteLocalImageFile:imageFilePath];
        }
    }
    return image;
}
- (NSString *)imageCacheKey:(NSString *)key skinName:(NSString *)skinName {
    return [NSString stringWithFormat:@"%@_%@",skinName,key];
}
- (void)deleteLocalImageFile:(NSString *)imagePath {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *path = [[NSURL alloc]initFileURLWithPath:imagePath];
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imagePath error:nil];
        if (files && files.count == 1) {
            path = [path URLByDeletingLastPathComponent];
        }
        [[NSFileManager defaultManager] removeItemAtURL:path error:nil];
    });
}
- (NSString *)imageExists:(NSString *)path imageName:(NSString *)imageName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        if (isDir) {
            NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:nil];
            NSString *imagePath = @"";
            for (NSString *file in files) {
                if ([self strContainsIgnoringCase:file find:imageName]) {
                    imagePath = [NSString stringWithFormat:@"%@/%@",path,file];
                    break;
                }
            }
            return imagePath;
        }else{
            return path;
        }
    }else{
        return @"";
    }
}
- (BOOL)strContainsIgnoringCase:(NSString *)str find:(NSString *)find {
    NSRange range = [str rangeOfString:find options:NSCaseInsensitiveSearch];
    if (range.location != NSNotFound && range.length != 0) {
        return YES;
    }
    return NO;
}
- (void)downloadImage:(NSString *)imageURLStr cachePath:(NSString *)cachePath result:(void(^)(BOOL success, NSString *imagePath, NSError *error))result {
    NSURL *imageURL = [NSURL URLWithString:imageURLStr];
    [[CJFileDownloader manager]CJFileDownLoadWithUrl:imageURL parameters:nil cookies:nil cachePolicy:NSURLRequestUseProtocolCachePolicy  customCachePath:cachePath taskIdentifier:nil progress:nil success:^(id taskIdentifier, BOOL cache, NSURLResponse *response, NSURL *filePath, NSString *MIMEType) {
        if (result) {
            NSString *filePathStr = filePath.absoluteString;
            if ([filePathStr hasPrefix:@"file://"]) {
                filePathStr = [filePathStr stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            }
            result(YES,filePathStr,nil);
        }
    } failure:^(id taskIdentifier, NSInteger statusCode, NSError *error) {
        if (result) {
            result(NO,nil,error);
        }
    }];
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
        NSDictionary *skinInfo = [CJSkin manager].skinInfo;
        NSString *imageUrl = SkinPackValueForKey(skinInfo,self.key,CJSkinValueTypeImage);
        if (imageUrl.length > 0 && [CJSkinTool imagePathIsUrl:imageUrl]) {
            //查找指定url是否存在沙盒缓存，默认一个url对应的缓存路径下只会有一份文件，如果存在多个则认为缓存无效并删除
            NSString *imageFilePath = [[CJFileDownloader manager]cacheFilePathWithUrl:[NSURL URLWithString:imageUrl] customCachePath:SkinCachePath([NSString stringWithFormat:@"%@/%@",CJSkinImageCahcePathName,[CJSkin manager].skinName])];
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
    [self getSkinImageForKey:self.key skinInfo:CJSkin.manager.skinInfo skinName:CJSkin.manager.skinName readDefaultValue:NO needDownload:YES completionHandler:^(BOOL result, NSString *message, NSString *skinName, UIImage *image, BOOL networkImage) {
        if (resultBlock) {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinImageErrorCode userInfo:@{NSLocalizedDescriptionKey:message}];
            resultBlock(result,error,image);
        }
        if (noticInfo) {
            self.imageAlreadyDownloadedSkin = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:CJSkinImageHaveDownloadedNotification object:noticInfo];
            });
        }
    }];
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
