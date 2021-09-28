//
//  UIKit+CJSkin.m
//  CJSkin
//
//  Created by lele8446 on 01/16/2019.
//  Copyright (c) 2019 lele8446. All rights reserved.
//

#import "UIKit+CJSkin.h"
#import "NSObject+CJSkin.h"
#import "CJSkin.h"

#define CJSkinNilStr(a) ((a)==nil || (a)==NULL || ([(a) isKindOfClass:[NSString class]]&&[(a) length]==0))

@implementation UIView (CJSkin)
- (void)CJ_skin_setBackgroundColorKey:(NSString *)key {
    [self CJ_skin_setBackgroundColorKey:key colorChangeInterval:0];
}
- (void)CJ_skin_setBackgroundColorKey:(NSString *)key colorChangeInterval:(NSTimeInterval)colorChangeInterval {
    if (CJSkinNilStr(key)) {
        [self setBackgroundColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        skintool.skinColorChangeInterval = colorChangeInterval;
        [self CJSkinInvokeMethodForSelector:@selector(setBackgroundColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setBackgroundColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setTintColor:) withArguments:@[skintool]];
    }
}
@end

@implementation UILabel (CJSkin)
- (void)CJ_skin_setFontKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setFont:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinFontTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setFont:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setTextColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setTextColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setTextColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setShadowColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setShadowColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setShadowColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setAttributedText:(NSAttributedString *)attributedText {
    [self CJSkinInvokeMethodForSelector:@selector(setAttributedText:) withArguments:@[attributedText]];
}
- (void)CJ_skin_setHighlightedTextColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setHighlightedTextColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setHighlightedTextColor:) withArguments:@[skintool]];
    }
}
@end

@implementation UIButton (CJSkin)
- (void)CJ_skin_setTitleColoKey:(NSString *)key forState:(UIControlState)state {
    if (CJSkinNilStr(key)) {
        [self setTitleColor:nil forState:state];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setTitleColor:forState:) withArguments:@[skintool,@(state)] withFilterArguments:@[@(state)]];
    }
}
- (void)CJ_skin_setTitleShadowColorKey:(NSString *)key forState:(UIControlState)state {
    if (CJSkinNilStr(key)) {
        [self setTitleShadowColor:nil forState:state];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setTitleShadowColor:forState:) withArguments:@[skintool,@(state)] withFilterArguments:@[@(state)]];
    }
}
- (void)CJ_skin_setImageKey:(NSString *)key forState:(UIControlState)state {
    if (CJSkinNilStr(key)) {
        [self setImage:nil forState:state];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setImage:forState:) withArguments:@[skintool,@(state)] withFilterArguments:@[@(state)]];
    }
}
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key forState:(UIControlState)state {
    if (CJSkinNilStr(key)) {
        [self setBackgroundImage:nil forState:state];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBackgroundImage:forState:) withArguments:@[skintool,@(state)] withFilterArguments:@[@(state)]];
    }
}
- (void)CJ_skin_setBackgroundColorKey:(NSString *)key forState:(UIControlState)state {
    if (CJSkinNilStr(key)) {
        [self setBackgroundImage:nil forState:state];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageFromColorTool(key);
        skintool.imageRenderingMode = UIImageRenderingModeAlwaysOriginal;
        [self CJSkinInvokeMethodForSelector:@selector(setBackgroundImage:forState:) withArguments:@[skintool,@(state)] withFilterArguments:@[@(state)]];
    }
}
@end

@implementation UIImageView (CJSkin)
- (void)CJ_skin_setImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setImage:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setAnimationImages:(NSArray *)animationImages {
    [self CJSkinInvokeMethodForSelector:@selector(setAnimationImages:) withArguments:@[animationImages]];
}
- (void)CJ_skin_setHighlightedImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setHighlightedImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setHighlightedImage:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setHighlightedAnimationImages:(NSArray *)highlightedAnimationImages {
    [self CJSkinInvokeMethodForSelector:@selector(setHighlightedAnimationImages:) withArguments:@[highlightedAnimationImages]];
}
@end

@implementation UITableView (CJSkin)
- (void)CJ_skin_setSectionIndexColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setSectionIndexColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setSectionIndexColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setSectionIndexBackgroundColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setSectionIndexBackgroundColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setSectionIndexBackgroundColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setSectionIndexTrackingBackgroundColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setSectionIndexTrackingBackgroundColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setSectionIndexTrackingBackgroundColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setSeparatorColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setSeparatorColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setSeparatorColor:) withArguments:@[skintool]];
    }
}
@end

@implementation UIPageControl (CJSkin)
- (void)CJ_skin_setPageIndicatorTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setPageIndicatorTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setPageIndicatorTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setCurrentPageIndicatorTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setCurrentPageIndicatorTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setCurrentPageIndicatorTintColor:) withArguments:@[skintool]];
    }
}
@end

@implementation UIProgressView (CJSkin)
- (void)CJ_skin_setProgressTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setProgressTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setProgressTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setTrackTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setTrackTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setTrackTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setProgressImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setProgressImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setProgressImage:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setTrackImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setTrackImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setTrackImage:) withArguments:@[skintool]];
    }
}
@end

@implementation UITextField (CJSkin)
- (void)CJ_skin_setTextColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setTextColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setTextColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setFontKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setFont:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinFontTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setFont:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setDefaultTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)defaultTextAttributes {
    [self CJSkinInvokeMethodForSelector:@selector(setDefaultTextAttributes:) withArguments:@[defaultTextAttributes]];
}
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setBackground:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBackground:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setDisabledBackgroundImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setDisabledBackground:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setDisabledBackground:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setTypingAttributes:(NSDictionary<NSAttributedStringKey,id> *)typingAttributes {
    [self CJSkinInvokeMethodForSelector:@selector(setTypingAttributes:) withArguments:@[typingAttributes]];
}
@end

@implementation UITextView (CJSkin)
- (void)CJ_skin_setFontKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setFont:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinFontTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setFont:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setTextColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setTextColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setTextColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setTypingAttributes:(NSDictionary<NSAttributedStringKey,id> *)typingAttributes {
    [self CJSkinInvokeMethodForSelector:@selector(setTypingAttributes:) withArguments:@[typingAttributes]];
}
- (void)CJ_skin_setLinkTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)linkTextAttributes {
    [self CJSkinInvokeMethodForSelector:@selector(setLinkTextAttributes:) withArguments:@[linkTextAttributes]];
}
@end

@implementation UISegmentedControl (CJSkin)
- (void)CJ_skin_insertSegmentWithImageKey:(NSString *)key atIndex:(NSUInteger)segment animated:(BOOL)animated {
    if (CJSkinNilStr(key)) {
        [self insertSegmentWithImage:nil atIndex:segment animated:animated];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(insertSegmentWithImage:atIndex:animated:) withArguments:@[skintool,@(segment),@(animated)]];
    }
}
- (void)CJ_skin_setImageKey:(NSString *)key forSegmentAtIndex:(NSUInteger)segment {
    if (CJSkinNilStr(key)) {
        [self setImage:nil forSegmentAtIndex:segment];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setImage:forSegmentAtIndex:) withArguments:@[skintool,@(segment)]];
    }
}
- (void)CJ_skin_setTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics {
    if (CJSkinNilStr(key)) {
        [self setBackgroundImage:nil forState:state barMetrics:barMetrics];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBackgroundImage:forState:barMetrics:) withArguments:@[skintool,@(state),@(barMetrics)] withFilterArguments:@[@(state)]];
    }
}
- (void)CJ_skin_setDividerImageKey:(NSString *)key forLeftSegmentState:(UIControlState)leftState rightSegmentState:(UIControlState)rightState barMetrics:(UIBarMetrics)barMetrics {
    if (CJSkinNilStr(key)) {
        [self setDividerImage:nil forLeftSegmentState:leftState rightSegmentState:rightState barMetrics:barMetrics];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setDividerImage:forLeftSegmentState:rightSegmentState:barMetrics:) withArguments:@[skintool,@(leftState),@(rightState),@(barMetrics)] withFilterArguments:@[@(leftState),@(rightState)]];
    }
}
- (void)CJ_skin_setTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes forState:(UIControlState)state {
    [self CJSkinInvokeMethodForSelector:@selector(setTitleTextAttributes:forState:) withArguments:@[attributes,@(state)] withFilterArguments:@[@(state)]];
}
@end

@implementation UISwitch (CJSkin)
- (void)CJ_skin_setOnTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setOnTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setOnTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setThumbTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setThumbTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setThumbTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setOnImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setOnImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setOnImage:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setOffImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setOffImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setOffImage:) withArguments:@[skintool]];
    }
}
@end

@implementation UISlider (CJSkin)
- (void)CJ_skin_setMinimumValueImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setMinimumValueImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setMinimumValueImage:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setMaximumValueImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setMaximumValueImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setMaximumValueImage:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setMinimumTrackTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setMinimumTrackTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setMinimumTrackTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setMaximumTrackTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setMaximumTrackTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setMaximumTrackTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setThumbTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setThumbTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setThumbTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setThumbImageKey:(NSString *)key forState:(UIControlState)state {
    if (CJSkinNilStr(key)) {
        [self setThumbImage:nil forState:state];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setThumbImage:forState:) withArguments:@[skintool,@(state)] withFilterArguments:@[@(state)]];
    }
}
- (void)CJ_skin_setMinimumTrackImageKey:(NSString *)key forState:(UIControlState)state {
    if (CJSkinNilStr(key)) {
        [self setMinimumTrackImage:nil forState:state];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setMinimumTrackImage:forState:) withArguments:@[skintool,@(state)] withFilterArguments:@[@(state)]];
    }
}
- (void)CJ_skin_setMaximumTrackImageKey:(NSString *)key forState:(UIControlState)state {
    if (CJSkinNilStr(key)) {
        [self setMaximumTrackImage:nil forState:state];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setMaximumTrackImage:forState:) withArguments:@[skintool,@(state)] withFilterArguments:@[@(state)]];
    }
}
@end

@implementation UISearchBar (CJSkin)
- (void)CJ_skin_setTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setBarTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setBarTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBarTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setBackgroundImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBackgroundImage:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setBackgroundImageFromColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setBackgroundImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageFromColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBackgroundImage:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setScopeBarBackgroundImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setScopeBarBackgroundImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setScopeBarBackgroundImage:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    if (CJSkinNilStr(key)) {
        [self setBackgroundImage:nil forBarPosition:barPosition barMetrics:barMetrics];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:) withArguments:@[skintool,@(barPosition),@(barMetrics)]];
    }
}
- (void)CJ_skin_setSearchFieldBackgroundImageKey:(NSString *)key forState:(UIControlState)state {
    if (CJSkinNilStr(key)) {
        [self setSearchFieldBackgroundImage:nil forState:state];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setSearchFieldBackgroundImage:forState:) withArguments:@[skintool,@(state)] withFilterArguments:@[@(state)]];
    }
}
- (void)CJ_skin_setImageKey:(NSString *)key forSearchBarIcon:(UISearchBarIcon)icon state:(UIControlState)state {
    if (CJSkinNilStr(key)) {
        [self setImage:nil forSearchBarIcon:icon state:state];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setImage:forSearchBarIcon:state:) withArguments:@[skintool,@(icon),@(state)] withFilterArguments:@[@(state)]];
    }
}
- (void)CJ_skin_setScopeBarButtonBackgroundImageKey:(NSString *)key forState:(UIControlState)state {
    if (CJSkinNilStr(key)) {
        [self setScopeBarButtonBackgroundImage:nil forState:state];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setScopeBarButtonBackgroundImage:forState:) withArguments:@[skintool,@(state)] withFilterArguments:@[@(state)]];
    }
}
- (void)CJ_skin_setScopeBarButtonDividerImageKey:(NSString *)key forLeftSegmentState:(UIControlState)leftState rightSegmentState:(UIControlState)rightState {
    if (CJSkinNilStr(key)) {
        [self setScopeBarButtonDividerImage:nil forLeftSegmentState:leftState rightSegmentState:rightState];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setScopeBarButtonDividerImage:forLeftSegmentState:rightSegmentState:) withArguments:@[skintool,@(leftState),@(rightState)] withFilterArguments:@[@(leftState),@(rightState)]];
    }
}
- (void)CJ_skin_setScopeBarButtonTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes forState:(UIControlState)state {
    [self CJSkinInvokeMethodForSelector:@selector(setScopeBarButtonTitleTextAttributes:forState:) withArguments:@[attributes,@(state)] withFilterArguments:@[@(state)]];
}
@end

@implementation UIToolbar (CJSkin)
- (void)CJ_skin_setTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setBarTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setBarTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBarTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key forToolbarPosition:(UIBarPosition)topOrBottom barMetrics:(UIBarMetrics)barMetrics {
    if (CJSkinNilStr(key)) {
        [self setBackgroundImage:nil forToolbarPosition:topOrBottom barMetrics:barMetrics];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:) withArguments:@[skintool,@(topOrBottom),@(barMetrics)]];
    }
}
- (void)CJ_skin_setShadowImageKey:(NSString *)key forToolbarPosition:(UIBarPosition)topOrBottom {
    if (CJSkinNilStr(key)) {
        [self setShadowImage:nil forToolbarPosition:topOrBottom];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setShadowImage:forToolbarPosition:) withArguments:@[skintool,@(topOrBottom)]];
    }
}
@end

@implementation UITabBar (CJSkin)
- (void)CJ_skin_setTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setBarTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setBarTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBarTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setUnselectedItemTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setUnselectedItemTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setUnselectedItemTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setSelectedImageTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setSelectedImageTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setSelectedImageTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setBackgroundImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBackgroundImage:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setSelectionIndicatorImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setSelectionIndicatorImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setSelectionIndicatorImage:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setShadowImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setShadowImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setShadowImage:) withArguments:@[skintool]];
    }
}
@end

@implementation UIBarItem (CJSkin)
- (void)CJ_skin_setImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        skintool.imageRenderingMode = UIImageRenderingModeAlwaysOriginal;
        [self CJSkinInvokeMethodForSelector:@selector(setImage:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setLandscapeImagePhoneKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setLandscapeImagePhone:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setLandscapeImagePhone:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setLargeContentSizeImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setLargeContentSizeImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setLargeContentSizeImage:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes forState:(UIControlState)state {
    [self CJSkinInvokeMethodForSelector:@selector(setTitleTextAttributes:forState:) withArguments:@[attributes,@(state)] withFilterArguments:@[@(state)]];
}
@end

@implementation UIBarButtonItem (CJSkin)
+ (UIBarButtonItem *)CJ_skin_itemWithImageKey:(NSString *)imageKey highlightImageKey:(NSString *)highlightImageKey target:(id)target action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 40);
    [btn CJ_skin_setImageKey:imageKey forState:UIControlStateNormal];
    [btn CJ_skin_setImageKey:highlightImageKey forState:UIControlStateHighlighted];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics {
    if (CJSkinNilStr(key)) {
        [self setBackgroundImage:nil forState:state barMetrics:barMetrics];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBackgroundImage:forState:barMetrics:) withArguments:@[skintool,@(state),@(barMetrics)] withFilterArguments:@[@(state)]];
    }
}
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key forState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics {
    if (CJSkinNilStr(key)) {
        [self setBackgroundImage:nil forState:state style:style barMetrics:barMetrics];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBackgroundImage:forState:style:barMetrics:) withArguments:@[skintool,@(state),@(style),@(barMetrics)] withFilterArguments:@[@(state)]];
    }
}
- (void)CJ_skin_setTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setBackButtonBackgroundImageKey:(NSString *)key forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics {
    if (CJSkinNilStr(key)) {
        [self setBackButtonBackgroundImage:nil forState:state barMetrics:barMetrics];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBackButtonBackgroundImage:forState:barMetrics:) withArguments:@[skintool,@(state),@(barMetrics)] withFilterArguments:@[@(state)]];
    }
}
@end

@implementation UITabBarItem (CJSkin)
- (instancetype)CJ_skin_initWithTitle:(NSString *)title imageKey:(NSString *)imageKey tag:(NSInteger)tag {
    if (CJSkinNilStr(imageKey)) {
        return [[UITabBarItem alloc]initWithTitle:title image:nil tag:tag];
    }else{
        NSAssert([imageKey isKindOfClass:[NSString class]], @"参数错误：%@",imageKey);
        UITabBarItem *tabBarItem = [[UITabBarItem alloc]initWithTitle:title image:nil tag:tag];
        [tabBarItem CJ_skin_setImageKey:imageKey];
        return tabBarItem;
    }
}
- (instancetype)CJ_skin_initWithTitle:(NSString *)title imageKey:(NSString *)imageKey selectedImageKey:(NSString *)selectedImageKey {
    if (CJSkinNilStr(imageKey) && CJSkinNilStr(selectedImageKey)) {
        return [[UITabBarItem alloc]initWithTitle:title image:nil selectedImage:nil];
    }else{
        UITabBarItem *tabBarItem = [[UITabBarItem alloc]initWithTitle:title image:nil selectedImage:nil];
        [tabBarItem CJ_skin_setImageKey:imageKey];
        [tabBarItem CJ_skin_setSelectedImageKey:selectedImageKey];
        return tabBarItem;
    }
}
- (void)CJ_skin_setSelectedImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setSelectedImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        skintool.imageRenderingMode = UIImageRenderingModeAlwaysOriginal;
        [self CJSkinInvokeMethodForSelector:@selector(setSelectedImage:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setFinishedSelectedImageKey:(NSString *)selectedImageKey withFinishedUnselectedImageKey:(NSString *)unselectedImageKey {
    if (CJSkinNilStr(selectedImageKey) && CJSkinNilStr(unselectedImageKey)) {
        [self setFinishedSelectedImage:nil withFinishedUnselectedImage:nil];
    }else{
        id selectedSkintool = SkinSafeObject(selectedImageKey);
        if (!CJSkinNilStr(selectedImageKey)) {
            NSAssert([selectedImageKey isKindOfClass:[NSString class]], @"参数错误：%@",selectedImageKey);
            selectedSkintool = SkinImageTool(selectedImageKey);
            [(CJSkinTool *)selectedSkintool setImageRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        id unselectedSkintool = SkinSafeObject(unselectedImageKey);
        if (!CJSkinNilStr(unselectedImageKey)) {
            NSAssert([unselectedImageKey isKindOfClass:[NSString class]], @"参数错误：%@",unselectedImageKey);
            unselectedSkintool = SkinImageTool(unselectedImageKey);
            [(CJSkinTool *)unselectedSkintool setImageRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        [self CJSkinInvokeMethodForSelector:@selector(setFinishedSelectedImage:withFinishedUnselectedImage:) withArguments:@[selectedSkintool,unselectedSkintool]];
    }
}
- (void)CJ_skin_setBadgeColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setBadgeColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBadgeColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setBadgeTextAttributes:(nullable NSDictionary<NSAttributedStringKey,id> *)textAttributes forState:(UIControlState)state {
    [self CJSkinInvokeMethodForSelector:@selector(setBadgeTextAttributes:forState:) withArguments:@[textAttributes,@(state)] withFilterArguments:@[@(state)]];
}
@end

@implementation UINavigationBar (CJSkin)
- (void)CJ_skin_setTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setBarTintColorKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setBarTintColor:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinColorTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBarTintColor:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    if (CJSkinNilStr(key)) {
        [self setBackgroundImage:nil forBarPosition:barPosition barMetrics:barMetrics];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:) withArguments:@[skintool,@(barPosition),@(barMetrics)]];
    }
}
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key forBarMetrics:(UIBarMetrics)barMetrics {
    if (CJSkinNilStr(key)) {
        [self setBackgroundImage:nil forBarMetrics:barMetrics];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBackgroundImage:forBarMetrics:) withArguments:@[skintool,@(barMetrics)]];
    }
}
- (void)CJ_skin_setShadowImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setShadowImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setShadowImage:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)titleTextAttributes {
    [self CJSkinInvokeMethodForSelector:@selector(setTitleTextAttributes:) withArguments:@[titleTextAttributes]];
}
- (void)CJ_skin_setLargeTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)largeTitleTextAttributes {
    [self CJSkinInvokeMethodForSelector:@selector(setLargeTitleTextAttributes:) withArguments:@[largeTitleTextAttributes]];
}
- (void)CJ_skin_setBackIndicatorImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setBackIndicatorImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBackIndicatorImage:) withArguments:@[skintool]];
    }
}
- (void)CJ_skin_setBackIndicatorTransitionMaskImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setBackIndicatorTransitionMaskImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setBackIndicatorTransitionMaskImage:) withArguments:@[skintool]];
    }
}
@end

@implementation UIApplication (CJSkin)
- (void)CJ_skin_setNewsstandIconImageKey:(NSString *)key {
    if (CJSkinNilStr(key)) {
        [self setNewsstandIconImage:nil];
    }else{
        NSAssert([key isKindOfClass:[NSString class]], @"参数错误：%@",key);
        CJSkinTool *skintool = SkinImageTool(key);
        [self CJSkinInvokeMethodForSelector:@selector(setNewsstandIconImage:) withArguments:@[skintool]];
    }
}
@end


