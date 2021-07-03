//
//  NSObject+CJSkin.h
//  CJSkin
//
//  Created by lele8446 on 01/16/2019.
//  Copyright (c) 2019 lele8446. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 生成id参数时候的安全方法（预防传nil）
 
 @param obj 需要设置的参数
 @return 安全参数
 */
FOUNDATION_EXPORT id SkinSafeObject(id obj);
/**
 使用 -CJSkinInvokeMethodForSelector: withArguments: 转发消息的时候封装SEL参数
 
 @param sel 需要设置的传递的方法参数
 @return 封装后可添加至NSArray的参数
 */
FOUNDATION_EXPORT id SkinSELArg(SEL sel);

@interface NSObject (CJSkin)

/// 收到换肤通知时的debugBlock
@property (nonatomic, copy) void(^skinDebugBlock)(NSString *selName, NSDictionary *paramInfo);

/// 收到换肤通知时的Block（可以在该回调方法中重新设置皮肤属性）
/// 使用示例：
/// self.skinChangeBlock = ^(id weakSelf) {
///     SMNavigationController *wSelf = (SMNavigationController *)weakSelf;
///     wSelf.navigationBar.shadowImage = [UIImage imageWithColor:CJColorSeparator_E8];
///     for (UIViewController *ctr in wSelf.viewControllers) {
///         [wSelf sm_skinChange:ctr];
///     }
/// };
@property (nonatomic, copy) void(^skinChangeBlock)(id weakSelf);

/**
 NSObject实例设置属性时的专用方法
 (使用此方法可以定制设置各类属性)
 
 @param sel 设置属性的原方法
 @param arguments sel方法参数数组
 
 
 注意⚠️： 1、所有的参数必须为id类型，若是基础数据类型则需要要封装成NSNumber传入；结构体和其他类型则需要封装成NSValue传入
         2、颜色、字体、图片参数封装成 CJSkinTool 实例传入
         3、arguments 数组内的参数 请使用 SkinSafeObject(obj); 方法转换后再传入（预防参数为nil）
 
 示例：
 
 //参数为基础数字类型
 [self.button CJSkinInvokeMethodForSelector:@selector(setAlpha:) withArguments:@[@(1)]];
 //参数为BOOL类型
 [self.button CJSkinInvokeMethodForSelector:@selector(setHidden:) withArguments:@[@(NO)]];
 //参数为结构体
 UIEdgeInsets insets = {10,10,10,10};
 NSValue *value = [NSValue valueWithUIEdgeInsets:insets];
 [self.button CJSkinInvokeMethodForSelector:@selector(setImageEdgeInsets:) withArguments:@[value]];
 
 //参数为图片通过 CJSkinTool 实例获取
 CJSkinTool *skintool = SkinImage(@"HeadImage");
 [self.button CJSkinInvokeMethodForSelector:@selector(setImage:forState:) withArguments:@[skintool,@(UIControlStateNormal)]];
 
 //id类型的参数，使用 SkinSafeObject(obj) 方法转换为安全参数
 UIImage *highlightedImage = [UIImage imageNamed:@"back"];
 highlightedImage = SkinSafeObject(highlightedImage);
 [self.button CJSkinInvokeMethodForSelector:@selector(setImage:forState:) withArguments:@[highlightedImage,@(UIControlStateHighlighted)]];
 
 //参数为颜色通过 CJSkinTool 实例获取
 skintool = SkinColor(CJSkinNavBarColorKey);
 [self.button CJSkinInvokeMethodForSelector:@selector(setTitleColor:forState:) withArguments:@[skintool,@(UIControlStateNormal)]];
 
 //id类型的参数，使用 SkinSafeObject(obj) 方法转换为安全参数
 NSString *title = @"按钮";
 [self.button CJSkinInvokeMethodForSelector:@selector(setTitle:forState:) withArguments:@[SkinSafeObject(title),@(UIControlStateNormal)]];
 //参数为字体通过 CJSkinTool 实例获取
 skintool = SkinFontWithFontType(@"Title", CJSkinFontTypeBold);
 [self.button.titleLabel CJSkinInvokeMethodForSelector:@selector(setFont:) withArguments:@[skintool]];
 
 */
- (id)CJSkinInvokeMethodForSelector:(SEL)sel withArguments:(NSArray *)arguments;

/// 实现换肤任意方法转发，并且需要匹配参数信息
///
/// 例如：[button setTitleColor:color forState:state];
/// 当 state = UIControlStateNormal，state = UIControlStateHighlighted 等不同值时，其实对应的是不同状态下的皮肤样式，
/// 此时虽然对应的方法名相同，但是每一个不同状态下的样式设置方法都应该保存转发！！！
- (id)CJSkinInvokeMethodForSelector:(SEL)sel withArguments:(NSArray *)arguments withFilterArguments:(NSArray *)filterArguments;
@end
