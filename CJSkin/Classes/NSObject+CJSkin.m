//
//  NSObject+CJSkin.m
//  CJSkin
//
//  Created by lele8446 on 01/16/2019.
//  Copyright (c) 2019 lele8446. All rights reserved.
//

#import "NSObject+CJSkin.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <CommonCrypto/CommonCrypto.h>
#import "CJSkin.h"

/** 包含需要转发的方法信息字典对应的key */
static NSString * const CJSkinInvSelKey                  = @"CJSkinInvSelKey";
/** 需要转发的方法名 */
static NSString * const CJSkinInvSelName                 = @"CJSkinInvSelName";
/** 需要转发的方法的参数信息 */
static NSString * const CJSkinParamInfo                  = @"CJSkinParamInfo";
/** 需要转发的方法的每一个参数的值 */
static NSString * const CJSkinParamValue                 = @"CJSkinParamValue";
/** 需要转发的方法的每一个参数的类型 */
static NSString * const CJSkinParamType                  = @"CJSkinParamType";
/** UI控件设置属性的图片需要下载时，当前系统皮肤包的名字 */
static NSString * const CJSkinImageDownloadInSkinName    = @"CJSkinImageDownloadInSkinName";
/** 使用 -CJSkinInvokeMethodForSelector: withArguments: 转发消息的时候封装SEL参数为NSString的前缀 */
static NSString * const CJSkinSELPrefix                  = @"_CJSkin_";
/** 判断是否为结构体 */
FOUNDATION_EXPORT BOOL SkinIsStructType(const char *encoding);


@interface NSObject ()
///记录实例本身所有需要转发的方法信息的字典，key是方法名+参数信息转化生成的md5字符串，value是对应的方法的参数信息
@property (atomic, strong, readonly) NSMutableDictionary<NSString *, id> *CJSkinExternalDictionary;
@end

@implementation NSObject (CJSkin)

static char SkinDebugBlockKey;
- (void)setSkinDebugBlock:(void (^)(NSString *, NSDictionary *))skinDebugBlock {
    objc_setAssociatedObject(self, &SkinDebugBlockKey, skinDebugBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^)(NSString *, NSDictionary *))skinDebugBlock {
    return objc_getAssociatedObject(self, &SkinDebugBlockKey);
}

static char SkinChangeBlockKey;
- (void)setSkinChangeBlock:(void (^)(id weakSelf))skinChangeBlock {
    objc_setAssociatedObject(self, &SkinChangeBlockKey, skinChangeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self CJSkinInvokeMethodForSelector:@selector(callBackSkinChangeBlock) withArguments:nil];
}
- (void)callBackSkinChangeBlock {
    if (self.skinChangeBlock) {
        __weak typeof(self)wSelf = self;
        self.skinChangeBlock(wSelf);
    }
}
- (void (^)(id weakSelf))skinChangeBlock {
  return objc_getAssociatedObject(self, &SkinChangeBlockKey);
}

/** 标记是否进行了换肤通知的监听 */
- (BOOL)CJSkinNotificationMarker {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)CJSkinSetNotificationMarker:(BOOL)marker {
    objc_setAssociatedObject(self, @selector(CJSkinNotificationMarker), @(marker), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)CJSkinDownLoadImageNotificationMarker {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)CJSkinSetDownLoadImageNotificationMarker:(BOOL)marker {
    objc_setAssociatedObject(self, @selector(CJSkinDownLoadImageNotificationMarker), @(marker), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSString *,id> *)CJSkinAddListener:(const void *)key sel:(SEL)aSelector {
    NSMutableDictionary<NSString *, id> *dictionary = objc_getAssociatedObject(self, key);
    if (!dictionary) {
        dictionary = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, key, dictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:aSelector name:CJSkinUpdateNotification object:nil];
        [self CJSkinSetNotificationMarker:YES];
    }
    return dictionary;
}

/** 记录需要进行换肤设置的上下文 */
- (NSMutableDictionary<NSString *,id> *)CJSkinExternalDictionary {
    return [self CJSkinAddListener:_cmd sel:@selector(CJSkinUpdateForExternal:)];
}

#define __STRUCT_SET(inv, value, type, index) do { \
    if (strcmp(type, @encode(CGPoint)) == 0) { \
        CGPoint arg = [value CGPointValue]; \
        [inv setArgument:&arg atIndex:index]; \
    } else if (strcmp(type, @encode(CGSize)) == 0) { \
        CGSize arg = [value CGSizeValue]; \
        [inv setArgument:&arg atIndex:index]; \
    } else if (strcmp(type, @encode(CGRect)) == 0) { \
        CGRect arg = [value CGRectValue]; \
        [inv setArgument:&arg atIndex:index]; \
    } else if (strcmp(type, @encode(CGVector)) == 0) { \
        CGVector arg = [value CGVectorValue]; \
        [inv setArgument:&arg atIndex:index]; \
    } else if (strcmp(type, @encode(CGAffineTransform)) == 0) { \
        CGAffineTransform arg = [value CGAffineTransformValue]; \
        [inv setArgument:&arg atIndex:index]; \
    } else if (strcmp(type, @encode(CATransform3D)) == 0) { \
        CATransform3D arg = [value CATransform3DValue]; \
        [inv setArgument:&arg atIndex:index]; \
    } else if (strcmp(type, @encode(NSRange)) == 0) { \
        NSRange arg = [value rangeValue]; \
        [inv setArgument:&arg atIndex:index]; \
    } else if (strcmp(type, @encode(UIOffset)) == 0) { \
        UIOffset arg = [value UIOffsetValue]; \
        [inv setArgument:&arg atIndex:index]; \
    } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) { \
        UIEdgeInsets arg = [value UIEdgeInsetsValue]; \
        [inv setArgument:&arg atIndex:index]; \
    } else{ \
        NSLog(@"CJSkin 未能识别的结构体参数：%@",value); \
    } \
} while (0);
#pragma mark - 转发消息
- (id)CJSkinInvokeMethodForSelector:(SEL)sel withArguments:(NSArray *)arguments {
    return [self CJSkinInvokeMethodForSelector:sel withArguments:arguments withFilterArguments:nil];
}

- (id)CJSkinInvokeMethodForSelector:(SEL)sel withArguments:(NSArray *)arguments withFilterArguments:(NSArray *)filterArguments {
    NSMethodSignature *sig = [self methodSignatureForSelector:sel];
    if (!sig) { [self doesNotRecognizeSelector:sel]; }
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    if (!inv) { [self doesNotRecognizeSelector:sel];}
    NSUInteger count = [sig numberOfArguments];
    NSAssert(((count-2) == arguments.count), @"方法参数不匹配！ SEL = %@ ,\n arguments = %@",NSStringFromSelector(sel),arguments);
    
    //当前转发方法名
    NSString *selName = NSStringFromSelector(sel);
    //保存当前消息转发的上下文信息
    NSMutableDictionary<NSNumber *, NSDictionary<NSString *, id> *> *paramInfo = [NSMutableDictionary dictionary];
    for (int index = 2; index < count; index++) {
        char *type = (char *)[sig getArgumentTypeAtIndex:(index)];
        id arg = arguments[index-2];
        [paramInfo setObject:@{CJSkinParamValue:arg,CJSkinParamType:[NSNumber numberWithChar:*type]} forKey:@(index)];
    }
    
    //标示每一个需要转发的消息的key：方法名 + 参数信息，拼接后的字符串再MD5
    NSString *selKey = [NSString stringWithFormat:@"%@_%@",selName,arguments];
    selKey = [selKey CJSkinMD5Str:selKey];
    NSMutableDictionary *objects = self.CJSkinExternalDictionary;
    
    //如果不需要匹配参数，那么直接覆盖已存储的同名转发方法即可
    if (filterArguments.count == 0) {
        NSMutableDictionary *oldObjects = [NSMutableDictionary dictionaryWithDictionary:objects];
        [oldObjects enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            //遍历 CJSkinExternalDictionary 中存储的所有方法调用上下文信息，如果存在与当前调用方法相同的旧信息，则先移除
            NSString *theSelName = obj[CJSkinInvSelName];
            if ([theSelName isEqualToString:selName]) {
                [objects removeObjectForKey:key];
            }
        }];
    }
    //否则还需匹配参数信息
    else{
        
        //首先得到需要过滤匹配的参数信息
        NSMutableArray *theFilterArgs = [NSMutableArray array];
        for (id filterArg in filterArguments) {
            if ([filterArg isKindOfClass:[CJSkinNull class]]) {
                break;
            }
            else if ([filterArg isKindOfClass:[CJSkinTool class]]) {
                [theFilterArgs addObject:[(CJSkinTool *)filterArg key]];
            }else{
                [theFilterArgs addObject:filterArg];
            }
        }
        
        NSMutableDictionary *oldObjects = [NSMutableDictionary dictionaryWithDictionary:objects];
        [oldObjects enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            //遍历 CJSkinExternalDictionary 中存储的所有方法调用上下文信息，得到方法名和参数信息
            NSString *theSelName = obj[CJSkinInvSelName];
            NSDictionary *paramInfo = obj[CJSkinParamInfo];
            
            if ([theSelName isEqualToString:selName]) {
                
                SEL theSEL = NSSelectorFromString(theSelName);
                NSMethodSignature *sig = [self methodSignatureForSelector:theSEL];
                NSUInteger count = [sig numberOfArguments];
                //获取已经存储的方法的参数信息
                NSMutableArray *theSELArgs = [NSMutableArray array];
                for (int index = 2; index < count; index++) {
                    NSDictionary *info = [paramInfo objectForKey:@(index)];
                    id _format = [info objectForKey:CJSkinParamValue];
                    if ([_format isKindOfClass:[CJSkinNull class]]) {
                        break;
                    }
                    else if ([_format isKindOfClass:[CJSkinTool class]]) {
                        [theSELArgs addObject:[(CJSkinTool *)_format key]];
                    }else{
                        [theSELArgs addObject:_format];
                    }
                }
                
                BOOL needRemove = YES;
                for (id filterArg in theFilterArgs) {
                    if (![theSELArgs containsObject:filterArg]) {
                        needRemove = NO;
                        break;
                    }
                }
                
                if (needRemove) {
                    [objects removeObjectForKey:key];
                }
            }
        }];
    }
    
    
    [objects setObject:@{CJSkinInvSelName:selName,CJSkinParamInfo:paramInfo} forKey:selKey];
    
    return [self CJSkinInvokeSkinMethodWithKey:selKey afterDownloadImage:NO fromInvFinst:YES];
}


- (id)CJSkinInvokeSkinMethodWithKey:(NSString *)key afterDownloadImage:(BOOL)afterDownloadImage fromInvFinst:(BOOL)fromInvFinst {

    NSDictionary *dic = self.CJSkinExternalDictionary[key];
    NSString *selName = dic[CJSkinInvSelName];
    SEL sel = NSSelectorFromString(selName);
    //方法参数信息
    NSDictionary *paramInfo = dic[CJSkinParamInfo];
    
    //判断参数中是否有需要下载的图片
    NSMutableArray *needDownLoadImageSkin = [self getAllNeedDownloadSkinImageFromArgs:paramInfo.allValues afterDownloadImage:afterDownloadImage];
    //需要下载图片
    if (needDownLoadImageSkin.count > 0) {
        //注册完成图片下载的通知
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CJSkinImageHaveDownloadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveDownloadedSkinImage:) name:CJSkinImageHaveDownloadedNotification object:nil];
        [self CJSkinSetDownLoadImageNotificationMarker:YES];
        for (CJSkinTool *skinTool in needDownLoadImageSkin) {
            NSDictionary *noticInfo = @{CJSkinInvSelKey:key,CJSkinImageDownloadInSkinName:[CJSkin manager].skinName};
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            //开始下载图片
            [skinTool performSelector:@selector(downloadImageWithNoticInfo:) withObject:noticInfo];
#pragma clang diagnostic pop
        }
        return nil;
    }
    //不存在需要下载的图片，直接转发消息
    else{
        @try {
            BOOL animated = NO;
            NSMethodSignature *sig = [self methodSignatureForSelector:sel];
            if (!sig) { [self doesNotRecognizeSelector:sel]; }
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            if (!inv) { [self doesNotRecognizeSelector:sel];}
            [inv setTarget:self];
            [inv setSelector:sel];
            NSUInteger count = [sig numberOfArguments];
            __weak typeof(id) skinArg = nil;
            for (int index = 2; index < count; index++) {
                
                NSDictionary *info = [paramInfo objectForKey:@(index)];
                char _type = [[info objectForKey:CJSkinParamType] charValue];
                id _format = [info objectForKey:CJSkinParamValue];
                switch (_type) { // parameter type  // NSNumber -> base type
                    case 'c':{
                        char arg = [_format charValue];
                        [inv setArgument:&arg atIndex:index];
                    } break;
                    case 'i':{
                        int arg = [_format intValue];
                        [inv setArgument:&arg atIndex:index];
                    } break;
                    case 's':{
                        short arg = [_format shortValue];
                        [inv setArgument:&arg atIndex:index];
                    } break;
                    case 'l':{
                        long arg = [_format longValue];
                        [inv setArgument:&arg atIndex:index];
                    } break;
                    case 'q':{
                        long long arg = [_format longLongValue];
                        [inv setArgument:&arg atIndex:index];
                    } break;
                    case 'C':{
                        unsigned char arg = [_format unsignedCharValue];
                        [inv setArgument:&arg atIndex:index];
                    } break;
                    case 'I':{
                        unsigned int arg = [_format unsignedIntValue];
                        [inv setArgument:&arg atIndex:index];
                    } break;
                    case 'S':{
                        unsigned short arg = [_format unsignedShortValue];
                        [inv setArgument:&arg atIndex:index];
                    } break;
                    case 'L':{
                        unsigned long arg = [_format unsignedLongValue];
                        [inv setArgument:&arg atIndex:index];
                    } break;
                    case 'Q':{
                        unsigned long long arg = [_format unsignedLongLongValue];
                        [inv setArgument:&arg atIndex:index];
                    } break;
                    case 'f':{
                        float arg = [_format floatValue];
                        [inv setArgument:&arg atIndex:index];
                    } break;
                    case 'd': case 'D': {
                        double arg = [_format doubleValue];
                        [inv setArgument:&arg atIndex:index];
                    } break;
                    case 'B':{
                        BOOL arg = [_format boolValue];
                        [inv setArgument:&arg atIndex:index];
                    } break;
                    case '^':{ // ^type A pointer to type
                        void *arg = [_format pointerValue];
                        [inv setArgument:&arg atIndex:index];
                    } break;
                    case '{': { // struct
                        NSValue *value = _format;
                        const char *_objcType = [value objCType];
                        __STRUCT_SET(inv, value, _objcType, index)
                    } break;
                    case '@': {
                        id arg = _format;
                        if ([arg isKindOfClass:[CJSkinNull class]]) {
                            arg = nil;
                            [inv setArgument:&arg atIndex:index];
                        }
                        else if ([arg isKindOfClass:[CJSkinTool class]]) {
                            skinArg = arg;
                            id value = [(CJSkinTool *)arg skinValue];
                            [inv setArgument:&value atIndex:index];
                            //引用计数+1，预防参数被释放
                            [inv retainArguments];
                        }else {
                            arg = [self getObjectArgValue:arg];
                            [inv setArgument:&arg atIndex:index];
                            //引用计数+1，预防参数被释放
                            [inv retainArguments];
                        }
                    } break;
                    case '*':{ // A character string (char *)
                        char *arg;
                        [_format getValue:&arg];
                        [inv setArgument:&arg atIndex:index];
                    } break;
                    case ':':{ // A method selector (SEL)
                        id arg = _format;
                        if ([arg isKindOfClass:[NSString class]]) {
                            NSString *selStr = (NSString *)arg;
                            if ([selStr hasPrefix:CJSkinSELPrefix]) {
                                NSRange range = [selStr rangeOfString:CJSkinSELPrefix];
                                selStr = [selStr substringFromIndex:(range.location + range.length)];
                                SEL sel = NSSelectorFromString(selStr);
                                [inv setArgument:&sel atIndex:index];
                            }else{
                                [inv setArgument:&selStr atIndex:index];
                            }
                            //引用计数+1，预防参数被释放
                            [inv retainArguments];
                        }else{
                            [inv setArgument:&arg atIndex:index];
                        }
                    } break;
                    default: {
                        NSLog(@"参数类型不支持，type : %c", _type);
                    } break;
                }
            }
            
            //声明返回值变量
            id returnValue = nil;
            
            if (fromInvFinst) {
                [inv invoke];
                returnValue = [self getReturnValue:sig inv:inv];
            }else{
                NSTimeInterval timeInterval = 0;
                //当前消息是设置颜色属性的时候，才判断是否需要动画
                if (skinArg && ([(CJSkinTool *)skinArg valueType] == CJSkinValueTypeColor || [(CJSkinTool *)skinArg valueType] == CJSkinValueTypeImageFromColor)) {
                    timeInterval = [(CJSkinTool *)skinArg skinColorChangeInterval];
                    animated = timeInterval > 0;
                }
                if (animated) {
                    const char *returnType = sig.methodReturnType;
                    //如果没有返回值，也就是消息声明为void，这个方法才能有动画， 且returnValue=nil
                    if( !strcmp(returnType, @encode(void)) ){
                        [UIView animateWithDuration:timeInterval animations:^{
                            [inv invoke];
                        }];
                    }else{
                        [inv invoke];
                        returnValue = [self getReturnValue:sig inv:inv];
                    }
                }else{
                    [inv invoke];
                    returnValue = [self getReturnValue:sig inv:inv];
                }
            }
            return returnValue;
        } @catch (NSException *exception) {
            NSLog(@"CJSkin 当前对象 %@ invoke转发方法：%@ 失败！！\n exception：%@",self,NSStringFromSelector(sel),exception);
            return nil;
        }
    }
}

- (id)getReturnValue:(NSMethodSignature *)sig inv:(NSInvocation *)inv {
    //声明返回值变量
    id returnValue = nil;
    //获得返回值类型
    const char *returnType = sig.methodReturnType;
    //如果没有返回值，也就是消息声明为void，那么returnValue=nil
    if( !strcmp(returnType, @encode(void)) ){
        returnValue =  nil;
    } else if( !strcmp(returnType, @encode(id)) ){
        //如果返回值为对象，那么为变量赋值
        void *tempResultSet;
        [inv getReturnValue:&tempResultSet];
        returnValue = (__bridge id)tempResultSet;
    } else{
        //如果返回值为普通类型NSInteger  BOOL
        //返回值长度
        NSUInteger length = [sig methodReturnLength];
        //根据长度申请内存
        void *buffer = (void *)malloc(length);
        //为变量赋值
        [inv getReturnValue:buffer];
        if (SkinIsStructType(returnType)) {
            //TODO: 结构体处理
        }else{
            if (!strcmp(returnType, @encode(char))) {
                returnValue = [NSNumber numberWithChar:*((char*)buffer)];
            }else if( !strcmp(returnType, @encode(int)) ){
                returnValue = [NSNumber numberWithInt:*((int*)buffer)];
            }else if( !strcmp(returnType, @encode(BOOL)) ) {
                returnValue = [NSNumber numberWithBool:*((BOOL*)buffer)];
            }else if( !strcmp(returnType, @encode(NSInteger))){
                returnValue = [NSNumber numberWithInteger:*((NSInteger*)buffer)];
            }else if( !strcmp(returnType, @encode(NSUInteger)) ){
                returnValue = [NSNumber numberWithUnsignedInteger:*((NSUInteger*)buffer)];
            }else if( !strcmp(returnType, @encode(short)) ){
                returnValue = [NSNumber numberWithShort:*((short*)buffer)];
            }else if( !strcmp(returnType, @encode(long)) ){
                returnValue = [NSNumber numberWithLong:*((long*)buffer)];
            }else if( !strcmp(returnType, @encode(long long)) ){
                returnValue = [NSNumber numberWithLongLong:*((long long*)buffer)];
            }else if( !strcmp(returnType, @encode(unsigned char)) ){
                returnValue = [NSNumber numberWithUnsignedChar:*((unsigned char*)buffer)];
            }else if( !strcmp(returnType, @encode(unsigned int)) ){
                returnValue = [NSNumber numberWithUnsignedInt:*((unsigned int*)buffer)];
            }else if( !strcmp(returnType, @encode(unsigned short)) ){
                returnValue = [NSNumber numberWithUnsignedShort:*((unsigned short*)buffer)];
            }else if( !strcmp(returnType, @encode(unsigned long)) ){
                returnValue = [NSNumber numberWithUnsignedLong:*((unsigned long*)buffer)];
            }else if( !strcmp(returnType, @encode(unsigned long long)) ){
                returnValue = [NSNumber numberWithUnsignedLongLong:*((unsigned long long*)buffer)];
            }else if( !strcmp(returnType, @encode(float)) ){
                returnValue = [NSNumber numberWithFloat:*((float*)buffer)];
            }else if( !strcmp(returnType, @encode(double)) ){
                returnValue = [NSNumber numberWithDouble:*((double*)buffer)];
            }
        }
    }
    return returnValue;
}
#pragma mark - 图片下载完毕后接收到通知
- (void)haveDownloadedSkinImage:(NSNotification *)notification {
    NSDictionary *noticInfo = notification.object;
    NSString *skinName = noticInfo[CJSkinImageDownloadInSkinName];
    NSString *invSelKey = noticInfo[CJSkinInvSelKey];
    //完成下载的图片所在皮肤包与当前皮肤包相同，并且在当前控件记录的换肤方法内，则执行换肤方法
    NSArray *allKeys = self.CJSkinExternalDictionary.allKeys;
    if ([skinName isEqualToString:[CJSkin manager].skinName] && [allKeys containsObject:invSelKey]) {
        [self CJSkinInvokeSkinMethodWithKey:invSelKey afterDownloadImage:YES fromInvFinst:NO];
    }
}
#pragma mark - 换肤通知
- (void)CJSkinUpdateForExternal:(NSNotification *)notification {
    NSMutableDictionary *CJSkinExternalDictionary = self.CJSkinExternalDictionary;
    [CJSkinExternalDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull dict, BOOL * _Nonnull stop) {
#ifdef DEBUG
        if (self.skinDebugBlock) {
            NSString *selName = dict[CJSkinInvSelName];
            NSDictionary *paramInfo = dict[CJSkinParamInfo];
            self.skinDebugBlock(selName, paramInfo);
        }
#else

#endif
        [self CJSkinInvokeSkinMethodWithKey:key afterDownloadImage:NO fromInvFinst:NO];
    }];
}
//获取参数数组里的所有需要下载图片的CJSkinTool对象（注意每一个参数都是链式结构的，参数中可能也包含有CJSkinTool对象）
- (NSMutableArray *)getAllNeedDownloadSkinImageFromArgs:(NSArray *)arguments afterDownloadImage:(BOOL)afterDownloadImage {
    NSMutableArray *skinTools = [NSMutableArray array];
    for (id arg in arguments) {
        skinTools = [self getSkinTool:arg skinTools:skinTools afterDownloadImage:afterDownloadImage];
    }
    return skinTools;
}
- (NSMutableArray *)getSkinTool:(id)arg skinTools:(NSMutableArray *)skinTools afterDownloadImage:(BOOL)afterDownloadImage {
    if ([arg isKindOfClass:[NSSet class]]) {
        for (id value in [(NSSet *)arg allObjects]) {
            [self getSkinTool:value skinTools:skinTools afterDownloadImage:afterDownloadImage];
        }
    }
    else if ([arg isKindOfClass:[NSArray class]]) {
        for (id value in (NSArray *)arg) {
            [self getSkinTool:value skinTools:skinTools afterDownloadImage:afterDownloadImage];
        }
    }
    else if ([arg isKindOfClass:[NSDictionary class]]) {
        NSArray *allValues = [(NSDictionary *)arg allValues];
        for (id value in allValues) {
            [self getSkinTool:value skinTools:skinTools afterDownloadImage:afterDownloadImage];
        }
    }
    else if ([arg isKindOfClass:[CJSkinTool class]]) {
        //重设重新下载图片状态
        if (!afterDownloadImage) {
            [(CJSkinTool *)arg setValue:@(NO) forKey:@"imageAlreadyDownloadedSkin"];
        }
        if ([(CJSkinTool *)arg needDownloadImage]) {
            [skinTools addObject:arg];
        }
    }
    return skinTools;
}

//获取所有参数的真实值（从 CJSkinTool 中获取图片、色值或者字体）
- (id)getObjectArgValue:(id)arg {
    if ([arg isKindOfClass:[NSSet class]]) {
        NSMutableSet *set = [NSMutableSet set];
        for (id value in [(NSSet *)arg allObjects]) {
            [set addObject:[self getObjectArgValue:value]];
        }
        arg = set;
    }
    else if ([arg isKindOfClass:[NSArray class]]) {
        NSMutableArray *ary = [NSMutableArray array];
        for (id value in (NSArray *)arg) {
            [ary addObject:[self getObjectArgValue:value]];
        }
        arg = ary;
    }
    else if ([arg isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSArray *allKeys = [(NSDictionary *)arg allKeys];
        for (NSInteger i = 0; i < allKeys.count; i++) {
            [dic setObject:[self getObjectArgValue:[(NSDictionary *)arg valueForKey:allKeys[i]]] forKey:allKeys[i]];
        }
        arg = dic;
    }
    else if ([arg isKindOfClass:[CJSkinTool class]]) {
        arg = [(CJSkinTool *)arg skinValue];
    }
    return arg;
}

- (NSMutableString *)CJSkinMD5Str:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)str.length, digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    return result;
}

@end

@implementation NSObject (CJSkinSwizzling)

+ (void)load {
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_x_Max) {
        Class class = [self class];
        SEL originalSelector = NSSelectorFromString(@"dealloc");
        SEL swizzledSelector = @selector(CJSkinDealloc);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)CJSkinDealloc {
    if ([self CJSkinNotificationMarker]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CJSkinUpdateNotification object:nil];
    }
    if ([self CJSkinDownLoadImageNotificationMarker]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CJSkinImageHaveDownloadedNotification object:nil];
    }
    [self CJSkinDealloc];
}

@end

FOUNDATION_EXPORT id SkinSafeObject(id obj) {
    if (!obj || obj==nil || obj==NULL || (NSNull *)(obj)==[NSNull null]) {
        return [CJSkinNull new];
    }else{
        return obj;
    }
}

FOUNDATION_EXPORT id SkinSELArg(SEL sel) {
    NSString *selStr = NSStringFromSelector(sel);
    if (sel && selStr.length > 0) {
        selStr = [NSString stringWithFormat:@"%@%@",CJSkinSELPrefix,selStr];
        return selStr;
    }else{
        return [CJSkinNull new];
    }
}
//判断是否为结构体
FOUNDATION_EXPORT BOOL SkinIsStructType(const char *encoding) {
    return encoding[0] == _C_STRUCT_B;
}
