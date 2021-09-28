//
//  CJSkin.m
//  CJSkin
//
//  Created by lele8446 on 01/16/2019.
//  Copyright (c) 2019 lele8446. All rights reserved.
//

#import "CJSkin.h"
#import "CJFileDownloader.h"
#import "ZipArchive.h"

static NSString * const CJSkinCurrentSkinName                = @"CJSkinCurrentSkinName";
static NSString * const CJSkinPlistPath                      = @"CJSkinPlistPath";
static NSString * const CJSkinCurrentVersion                 = @"CJSkinCurrentVersion";
NSNotificationName const CJSkinUpdateNotification            = @"CJ.skin.update.notification";

/**
 从所有皮肤包信息中获取当前皮肤信息
 
 @param info  所有皮肤包信息
 @param key   目标字典对应的key
 @return NSDictionary
 */
FOUNDATION_EXPORT NSDictionary *DicFromSkinHistoryInfoWithKey(NSDictionary *info, NSString *key) {
    NSDictionary *dic = [info objectForKey:key];
    if (dic && [dic allKeys].count > 0) {
        return dic;
    }
    return @{};
}

typedef NSDictionary *(^KsetUpDecodeSkinPlistBlock)(NSString *skinPlistPath);
static KsetUpDecodeSkinPlistBlock _decodeSkinPlistBlock = nil;

@interface CJSkin ()
/** 记录所有皮肤配置信息的 Dictionary，该字典内不包含当前皮肤版本号字段 */
@property (nonatomic, strong) NSMutableDictionary *skinPlistInfo;
/** App沙盒内的皮肤包资源 CJSkin.plist 文件路径 */
@property (nonatomic, copy) NSString *skinSandboxPlistPath;
@property (nonatomic, copy) NSString *defaultSkinName;
@property (nonatomic, copy) NSDictionary *defaultSkinInfo;
@property (nonatomic, copy) NSString *skinName;
@property (nonatomic, copy) NSDictionary *skinInfo;
/** 读取CJSkin.plist文件解密内容的block*/
@property (class, copy) KsetUpDecodeSkinPlistBlock decodeSkinPlistBlock;
/** 皮肤资源为网络图片，图片下载成功后对应的图片内存缓存*/
@property (nonatomic, strong) NSCache *imageCache;
@end

@implementation CJSkin
- (NSCache *)imageCache {
    if (!_imageCache) {
        _imageCache = [[NSCache alloc]init];
        _imageCache.countLimit = 50;
    }
    return _imageCache;
}
+ (KsetUpDecodeSkinPlistBlock)decodeSkinPlistBlock {
    return _decodeSkinPlistBlock;
}

+ (void)setDecodeSkinPlistBlock:(KsetUpDecodeSkinPlistBlock)decodeSkinPlistBlock {
    _decodeSkinPlistBlock = decodeSkinPlistBlock;
}

- (NSMutableDictionary *)skinPlistInfo {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithContentsOfFile:self.skinSandboxPlistPath];
    if (!info || info.allKeys.count == 0) {
        NSString *path = [[NSBundle mainBundle] pathForResource:CJ_SKIN_PLIST_NAME ofType:@"plist"];
        
        if (CJSkin.decodeSkinPlistBlock) {
            NSDictionary *dic = CJSkin.decodeSkinPlistBlock(path);
            info = [NSMutableDictionary dictionaryWithDictionary:dic];
        }
        if (!info || info.allKeys.count == 0) {
            info = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        }
        NSAssert((info && info.allKeys.count>0), @"CJSkin.plist皮肤配置读取失败，请检查是否已加密该文件，如果已加密请检查application:didFinishLaunchingWithOptions:或application:willFinishLaunchingWithOptions:中是否已设置[CJSkin setUpDecodeSkinPlistBlock:]换肤解密初始化");
    }
    //返回信息中去除当前版本信息
    [info removeObjectForKey:CJSkinCurrentVersion];
    return info;
}

- (void)readSkinInfo {
    self.defaultSkinName = CJ_SKIN_DEFAULT_NAME;
    self.defaultSkinInfo = DicFromSkinHistoryInfoWithKey(self.skinPlistInfo, self.defaultSkinName);
    NSString *skinName = [[NSUserDefaults standardUserDefaults] objectForKey:CJSkinCurrentSkinName];
    if (skinName.length == 0) {
        skinName = self.defaultSkinName;
    }
    self.skinName = skinName;
    self.skinInfo = DicFromSkinHistoryInfoWithKey(self.skinPlistInfo, self.skinName);
}

#pragma mark - Public Method
+ (instancetype)manager {
    static CJSkin *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[CJSkin alloc] init];
    });
    return share;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self reloadPlistInfoFromBundleWithSkinVersion];
        [self readSkinInfo];
    }
    return self;
}

- (void)reloadPlistInfoFromBundleWithSkinVersion {
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (appVersion.length == 0) {
        appVersion = @"1.0.0";
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = SkinCachePath(nil);
    self.skinSandboxPlistPath = [NSString stringWithFormat:@"%@/CJSKinInfoHistory.plist",path];
    //沙盒中还不存在 CJSkin.plist 文件，则创建
    if (![fileManager fileExistsAtPath:self.skinSandboxPlistPath]) {
        [self setSkinSandboxPlistInfo:appVersion oldSkinHistoryInfo:nil];
    }
    else{
        NSMutableDictionary *oldSkinHistoryInfo = [NSMutableDictionary dictionaryWithContentsOfFile:self.skinSandboxPlistPath];
        NSString *currentVersion = oldSkinHistoryInfo[CJSkinCurrentVersion];
        //如果app version号大于沙盒内记录的version号，那么更新mainBundle内的皮肤资源
        if ([appVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
            [self setSkinSandboxPlistInfo:appVersion oldSkinHistoryInfo:oldSkinHistoryInfo];
        }
    }
}

/**
 更新当前版本皮肤资源信息（由沙盒文件CJSKinInfoHistory.plist记录）

 @param appVersion 当前皮肤版本号
 @param oldSkinHistoryInfo 旧版本的皮肤资源信息
 */
- (void)setSkinSandboxPlistInfo:(NSString *)appVersion oldSkinHistoryInfo:(NSDictionary *)oldSkinHistoryInfo {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    if (oldSkinHistoryInfo) {
        //先读取保存旧的皮肤资源信息
        [info addEntriesFromDictionary:oldSkinHistoryInfo];
    }
    //从mainBundle获取最新的皮肤资源信息
    NSString *path = [[NSBundle mainBundle] pathForResource:CJ_SKIN_PLIST_NAME ofType:@"plist"];
    
    NSMutableDictionary *bundleInfo = nil;
    if (CJSkin.decodeSkinPlistBlock) {
        NSDictionary *dic = CJSkin.decodeSkinPlistBlock(path);
        bundleInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
    }
    if (!bundleInfo || bundleInfo.allKeys.count == 0) {
        bundleInfo = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    }
    NSAssert((bundleInfo && bundleInfo.allKeys.count>0), @"CJSkin.plist皮肤配置读取失败，请检查是否已加密该文件，如果已加密请检查application:didFinishLaunchingWithOptions:或application:willFinishLaunchingWithOptions:中是否已设置[CJSkin setUpDecodeSkinPlistBlock:]换肤解密初始化");
    
    [bundleInfo setObject:appVersion forKey:CJSkinCurrentVersion];
    //合并资源，如果mainBundle内信息有更新，则会替换更新
    [info addEntriesFromDictionary:bundleInfo];
    //将dictionary中的数据写入沙盒内的 CJSkin.plist 文件中
    [info writeToFile:self.skinSandboxPlistPath atomically:YES];
}

+ (void)loadSkinInfoFromBundle {
#if (DEBUG)
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (appVersion.length == 0) {
        appVersion = @"1.0.0";
    }
    NSMutableDictionary *oldSkinHistoryInfo = [NSMutableDictionary dictionaryWithContentsOfFile:[CJSkin manager].skinSandboxPlistPath];
    [[CJSkin manager] setSkinSandboxPlistInfo:appVersion oldSkinHistoryInfo:oldSkinHistoryInfo];
    [[CJSkin manager] readSkinInfo];
#endif
}

+ (NSString *)skinName {
    return [CJSkin manager].skinName;
}

+ (void)setUpDecodeSkinPlistBlock:(NSDictionary *(^)(NSString *CJSkinPlistPath))setUpBlock {
    [CJSkin setDecodeSkinPlistBlock:setUpBlock];
}

+ (BOOL)changeSkinWithName:(NSString *)skinName resultBlock:(void(^)(NSError *error))resultBlock {
    BOOL result = YES;
    NSError *error = nil;
    
    if (skinName.length == 0) {
        NSString *errorStr = [NSString stringWithFormat:@"皮肤包名不能为空"];
        error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinErrorCode userInfo:@{NSLocalizedDescriptionKey:errorStr}];
        result = NO;
    }
//    else if ([[CJSkin manager].skinName isEqualToString:skinName]) {
//        NSString *errorStr = [NSString stringWithFormat:@"不能重复设置相同的皮肤包：%@",skinName];
//        error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinErrorCode userInfo:@{NSLocalizedDescriptionKey:errorStr}];
//        result = NO;
//    }
    else{
        NSDictionary *skinInfo = DicFromSkinHistoryInfoWithKey([CJSkin manager].skinPlistInfo, skinName);
        if (skinInfo.allKeys.count > 0) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:skinName forKey:CJSkinCurrentSkinName];
            [[CJSkin manager] setSkinName:skinName];
            [[CJSkin manager] setSkinInfo:skinInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:CJSkinUpdateAndImageDownloadAgainNotification object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:CJSkinUpdateNotification object:nil];
        }else{
            NSString *errorStr = [NSString stringWithFormat:@"不存在皮肤包信息：%@",skinName];
            error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinErrorCode userInfo:@{NSLocalizedDescriptionKey:errorStr}];
            result = NO;
        }
    }
    
    if (resultBlock) {
        resultBlock(error);
    }
    return result;
}

+ (void)updateSkinResourceWithPath:(NSString *)skinResourcePath resultBlock:(void(^)(BOOL success, NSError *error))resultBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //压缩包文件夹下的所有文件名（包含文件夹）
        NSArray *tempArray = [fileManager contentsOfDirectoryAtPath:skinResourcePath error:nil];
        __block NSError *error = nil;
        if (!tempArray || tempArray.count == 0) {
            NSString *errorStr = [NSString stringWithFormat:@"皮肤压缩包资源为空，压缩包名称：%@",skinResourcePath.lastPathComponent];
            error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinErrorCode userInfo:@{NSLocalizedDescriptionKey:errorStr}];
            if (resultBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(NO,error);
                });
            }
            return;
        }
        
        NSMutableDictionary *skinPlistInfo = nil;
        for (NSString *fileName in tempArray) {
            //CJSkin.plist 文件存在
            if ([fileName rangeOfString:@"CJSkin.plist"].location != NSNotFound) {
                NSString *skinPlist = [skinResourcePath stringByAppendingPathComponent:fileName];
                skinPlistInfo = [NSMutableDictionary dictionaryWithContentsOfFile:skinPlist];
                break;
            }
        }
        if (!skinPlistInfo) {
            if (resultBlock) {
                NSString *errorStr = [NSString stringWithFormat:@"皮肤资源更新失败！！皮肤压缩包资源内不存在配置描述文件 CJSkin.plist！！"];
                error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinErrorCode userInfo:@{NSLocalizedDescriptionKey:errorStr}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(NO,error);
                });
            }
            return;
        }
        
        //换肤资源路径
        NSString *toCJSkinPath = SkinCachePath(nil);
        //已有的皮肤包资源文件夹
        NSArray *oldSkinArray = [fileManager contentsOfDirectoryAtPath:toCJSkinPath error:nil];
        
        //将压缩包下载后的资源，移动到 NSDocumentDirectory / CJSkin/ 路径下
        for (NSString *skinName in skinPlistInfo.allKeys) {
            //如果新下载的皮肤包文件夹在 CJSkin.plist 配置文件内
            if ([tempArray containsObject:skinName]) {
                //获取到当前皮肤资源文件夹路径
                NSString *atSkinFilePath = [skinResourcePath stringByAppendingPathComponent:skinName];
                BOOL isDir = NO;
                BOOL isDirExist = [fileManager fileExistsAtPath:atSkinFilePath isDirectory:&isDir];
                //是有效的皮肤包文件夹
                if (isDirExist && isDir) {
                    //如果已存在同名的皮肤包资源文件夹，执行覆盖资源
                    if ([oldSkinArray containsObject:skinName]) {
                        error = [self coverSkinResourceAtPath:atSkinFilePath toPath:[toCJSkinPath stringByAppendingPathComponent:skinName] fileManager:fileManager];
                        if (error) {
                            break;
                        }
                    }
                    //否则直接添加到换肤资源下
                    else{
                        [fileManager moveItemAtPath:atSkinFilePath toPath:[toCJSkinPath stringByAppendingPathComponent:skinName] error:&error];
                        if (error) {
                            break;
                        }
                    }
                }
            }
        }
        if (error) {
            if (resultBlock) {
                NSString *errorStr = [NSString stringWithFormat:@"皮肤资源更新失败！！皮肤压缩包资源读取失败!"];
                error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinErrorCode userInfo:@{NSLocalizedDescriptionKey:errorStr}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(NO,error);
                });
            }
            return;
        }
        
        //资源移动完成，将新的CJSkin.plist 内容更新到沙盒文件内
        [self updateSkinPlistInfo:skinPlistInfo resultBlock:^(BOOL success, NSError *error) {
            if (resultBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(success,error);
                });
                if (success) {
                    [fileManager removeItemAtPath:skinResourcePath error:&error];
                }
            }
        }];
    });
}

+ (NSError *)coverSkinResourceAtPath:(NSString *)atPath toPath:(NSString *)toPath fileManager:(NSFileManager *)fileManager {
    //需要替换的皮肤包资源内容
    NSArray *currentSkinFileArray = [fileManager contentsOfDirectoryAtPath:atPath error:nil];
    //旧的皮肤包资源内容
    NSArray *oldSkinFileArray = [fileManager contentsOfDirectoryAtPath:toPath error:nil];
    NSError *error = nil;
    for (NSString *fileName in currentSkinFileArray) {
        //旧的皮肤包内存在同名文件，先删除旧的同名文件
        if ([oldSkinFileArray containsObject:fileName]) {
            [fileManager removeItemAtPath:[toPath stringByAppendingPathComponent:fileName] error:&error];
        }
        if (error) {
            break;
        }
        [fileManager moveItemAtPath:[atPath stringByAppendingPathComponent:fileName] toPath:[toPath stringByAppendingPathComponent:fileName] error:&error];
        if (error) {
            break;
        }
    }
    return error;
}

+ (void)downloadSkinZipResourceWithUrl:(NSString *)skinZipResourceUrl
                            parameters:(id)parameters
                               cookies:(NSDictionary <NSString*, NSString*>*)cookies
                              progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                           resultBlock:(void(^)(BOOL success, NSError *error))resultBlock
{
    NSURL *URL = [NSURL URLWithString:skinZipResourceUrl];
    [[CJFileDownloader manager]CJFileDownLoadWithUrl:URL parameters:parameters cookies:cookies cachePolicy:NSURLRequestUseProtocolCachePolicy customCachePath:SkinCachePath(@"CJSkinZip") taskIdentifier:nil progress:^(id taskIdentifier, NSProgress *downloadProgress) {
        if (downloadProgressBlock) {
            downloadProgressBlock(downloadProgress);
        }
    } success:^(id taskIdentifier, BOOL cache, NSURLResponse *response, NSURL *filePath, NSString *MIMEType) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *zipPath = filePath.path;
            //本次皮肤压缩包解压路径
            NSString *unZipPath = SkinCachePath(nil);
            unZipPath = [NSString stringWithFormat:@"%@/CJSkinUnZip_%@",unZipPath,[[NSUUID UUID] UUIDString]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            [fileManager createDirectoryAtPath:unZipPath withIntermediateDirectories:YES attributes:nil error:&error];
            //创建解压路径失败
            if (error) {
                if (resultBlock) {
                    NSString *errorStr = [NSString stringWithFormat:@"皮肤压缩包下载后解压失败，错误：\n%@",error.localizedDescription];
                    error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinErrorCode userInfo:@{NSLocalizedDescriptionKey:errorStr}];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        resultBlock(NO,error);
                    });
                }
                [[CJFileDownloader manager]clearCacheAtCustomCachePath:SkinCachePath(@"CJSkinZip") resultBlock:nil];
                [fileManager removeItemAtPath:unZipPath error:nil];
            }else{
                BOOL zip = [SSZipArchive unzipFileAtPath:zipPath toDestination:unZipPath overwrite:YES password:nil error:&error];
                if (!zip) {
                    if (resultBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(NO,error);
                        });
                    }
                    [[CJFileDownloader manager]clearCacheAtCustomCachePath:SkinCachePath(@"CJSkinZip") resultBlock:nil];
                    [fileManager removeItemAtPath:unZipPath error:nil];
                }
                //解压成功
                else{
                    NSArray *tempArray = [fileManager contentsOfDirectoryAtPath:unZipPath error:nil];
                    //这个是压缩包解压后 CJSkin.plist 文件所在的路径
                    NSString *skinPlist = [unZipPath stringByAppendingPathComponent:tempArray[0]];
                    [CJSkin updateSkinResourceWithPath:skinPlist resultBlock:^(BOOL success, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (resultBlock) {
                                resultBlock(success,error);
                            }
                        });
                        //更新完成，将临时的解压文件删除
                        [fileManager removeItemAtPath:unZipPath error:nil];
                        [[CJFileDownloader manager]clearCacheAtCustomCachePath:SkinCachePath(@"CJSkinZip") resultBlock:nil];
                    }];
                }
            }
        });
    } failure:^(id taskIdentifier, NSInteger statusCode, NSError *error) {
        if (resultBlock) {
            resultBlock(NO,error);
        }
        [[CJFileDownloader manager]clearCacheAtCustomCachePath:SkinCachePath(@"CJSkinZip") resultBlock:nil];
    }];
}

+ (void)updateSkinPlistInfo:(NSDictionary *)skinPlistInfo resultBlock:(void(^)(BOOL success, NSError *error))resultBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        if ([skinPlistInfo isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            NSMutableDictionary *oldSkinHistoryInfo = [NSMutableDictionary dictionaryWithContentsOfFile:[CJSkin manager].skinSandboxPlistPath];
            [dic addEntriesFromDictionary:oldSkinHistoryInfo];
            [dic addEntriesFromDictionary:skinPlistInfo];
            
            BOOL result = [dic writeToFile:[CJSkin manager].skinSandboxPlistPath atomically:YES];
            if (!result) {
                NSString *errorStr = [NSString stringWithFormat:@"更新皮肤包数据到本地沙盒失败：\n%@",skinPlistInfo];
                error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinErrorCode userInfo:@{NSLocalizedDescriptionKey:errorStr}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (resultBlock) {
                        resultBlock(NO,error);
                    }
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (resultBlock) {
                        resultBlock(YES,error);
                    }
                });
            }
        }else{
            NSString *errorStr = [NSString stringWithFormat:@"更新的皮肤包数据格式错误：\n%@",skinPlistInfo];
            error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinErrorCode userInfo:@{NSLocalizedDescriptionKey:errorStr}];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (resultBlock) {
                    resultBlock(NO,error);
                }
            });
        }
    });
}

+ (BOOL)removeSkinPackWithName:(NSString *)skinName resultBlock:(void(^)(NSError *error))resultBlock {
    BOOL result = YES;
    NSError *error = nil;
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithContentsOfFile:[CJSkin manager].skinSandboxPlistPath];
    if (skinName.length>0 && [info objectForKey:skinName]) {
        if ([skinName isEqualToString:CJ_SKIN_DEFAULT_NAME]) {
            error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinErrorCode userInfo:@{NSLocalizedDescriptionKey:@"默认皮肤包不能删除"}];
            result = NO;
        }else{
            [info removeObjectForKey:skinName];
            result = [info writeToFile:[CJSkin manager].skinSandboxPlistPath atomically:YES];
            //皮肤包信息本地写入失败，不处理，保持删除前状态
            if (!result) {
                NSString *errorStr = [NSString stringWithFormat:@"删除皮肤包失败：%@",skinName];
                error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinErrorCode userInfo:@{NSLocalizedDescriptionKey:errorStr}];
            }else{
                if ([skinName isEqualToString:[CJSkin manager].skinName]) {
                    //删除成功，如果删除的刚好是当前皮肤包，则将APP皮肤更换为默认模式
                    [CJSkin changeSkinWithName:CJ_SKIN_DEFAULT_NAME resultBlock:nil];
                }
                //删除该皮肤包对应的网络图片
                //删除以皮肤压缩包zip方式整体下载的对应皮肤图片：Library/Caches/CJSkin/skinName 目录下的图片
                [self clearImageCachePath:SkinCachePath(skinName) completion:nil];
                //删除指定url方式下载的在线图片： Library/Caches/CJSkin/CJSkinImage/skinName 目录下的图片
                [self clearImageCachePath:SkinCachePath([NSString stringWithFormat:@"CJSkinImage/%@",skinName]) completion:nil];
            }
        }
    }else{
        NSString *errorStr = @"";
        if (skinName.length == 0) {
            errorStr = [NSString stringWithFormat:@"皮肤包名不能为空"];
        }else{
            errorStr = [NSString stringWithFormat:@"不存在皮肤包信息：%@",skinName];
        }
        error = [NSError errorWithDomain:NSURLErrorDomain code:CJSkinErrorCode userInfo:@{NSLocalizedDescriptionKey:errorStr}];
        result = NO;
    }
    
    if (resultBlock) {
        resultBlock(error);
    }
    return result;
}

+ (void)clearCachePath:(NSString *)path completion:(void(^)(BOOL result, NSString *str))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        if ([[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
            if (completion) {
                NSString *msg = [NSString stringWithFormat:@"清除缓存成功"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(YES,msg);
                });
            }
        }else{
            if (completion) {
                NSString *msg = [NSString stringWithFormat:@"清除缓存出错：%@",error.localizedDescription];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO,msg);
                });
            }
        }
    });
}

+ (void)clearImageCachePath:(NSString *)path completion:(void(^)(BOOL result, NSString *str))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSError *error;
            NSString *parentPath = [path stringByDeletingLastPathComponent];
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:parentPath error:&error];
            if (error) {
                [self clearCachePath:path completion:completion];
            }else{
                if (files.count == 1) {
                    [self clearCachePath:parentPath completion:completion];
                }else{
                    [self clearCachePath:path completion:completion];
                }
            }
        }else{
            if (completion) {
                completion(YES,@"在线皮肤图片缓存为空");
            }
        }
    });
}

+ (void)clearAllSkinImageCache:(void(^)(BOOL result, NSString *str))completion {
    // CJSkinImageCahcePathName = "CJSkinImage"
    NSString *path = SkinCachePath(@"CJSkinImage");
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [self clearCachePath:path completion:completion];
    }else{
        if (completion) {
            completion(YES,@"在线皮肤图片缓存为空");
        }
    }
}
@end
