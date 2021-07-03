//
//  UIKit+CJSkin.h
//  CJSkin
//
//  Created by lele8446 on 01/16/2019.
//  Copyright (c) 2019 lele8446. All rights reserved.
//

#import <UIKit/UIKit.h>

/**********************************************************************
 * UIKit 换肤分类
 * 通过以下分类方法可便捷设置在换肤模式下，各UI控件的颜色、图片、字体等
 * 如果需要进一步定制属性，请调用 NSObject+CJSkin.h 中的 - CJSkinInvokeMethodForSelector:withArguments: 方法
 **********************************************************************/

@interface UIView (CJSkin)
- (void)CJ_skin_setBackgroundColorKey:(NSString *)key;
/**设置背景色，并自定义皮肤颜色切换时候的动画时间 */
- (void)CJ_skin_setBackgroundColorKey:(NSString *)key colorChangeInterval:(NSTimeInterval)colorChangeInterval;
- (void)CJ_skin_setTintColorKey:(NSString *)key;
@end

@interface UILabel (CJSkin)
- (void)CJ_skin_setFontKey:(NSString *)key;
- (void)CJ_skin_setTextColorKey:(NSString *)key;
- (void)CJ_skin_setShadowColorKey:(NSString *)key;
- (void)CJ_skin_setAttributedText:(NSAttributedString *)attributedText;
- (void)CJ_skin_setHighlightedTextColorKey:(NSString *)key;
@end

@interface UIButton (CJSkin)
- (void)CJ_skin_setTitleColoKey:(NSString *)key forState:(UIControlState)state;
- (void)CJ_skin_setTitleShadowColorKey:(NSString *)key forState:(UIControlState)state;
- (void)CJ_skin_setImageKey:(NSString *)key forState:(UIControlState)state;
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key forState:(UIControlState)state;
/**设置不同状态下的按钮背景色 */
- (void)CJ_skin_setBackgroundColorKey:(NSString *)key forState:(UIControlState)state;
@end

@interface UIImageView (CJSkin)
- (void)CJ_skin_setImageKey:(NSString *)key;
/**
 根据皮肤资源设置动画图片
 注意⚠️：这里设置的图片，必须是本地已下载的图片
 */
- (void)CJ_skin_setAnimationImages:(NSArray *)animationImages;
- (void)CJ_skin_setHighlightedImageKey:(NSString *)key;
/**
 根据皮肤资源设置高亮动画图片
 注意⚠️：这里设置的图片，必须是本地已下载的图片
 */
- (void)CJ_skin_setHighlightedAnimationImages:(NSArray *)highlightedAnimationImages;
@end

@interface UITableView (CJSkin)
- (void)CJ_skin_setSectionIndexColorKey:(NSString *)key;
- (void)CJ_skin_setSectionIndexBackgroundColorKey:(NSString *)key;
- (void)CJ_skin_setSectionIndexTrackingBackgroundColorKey:(NSString *)key;
- (void)CJ_skin_setSeparatorColorKey:(NSString *)key;
@end

@interface UIPageControl (CJSkin)
- (void)CJ_skin_setPageIndicatorTintColorKey:(NSString *)key;
- (void)CJ_skin_setCurrentPageIndicatorTintColorKey:(NSString *)key;
@end

@interface UIProgressView (CJSkin)
- (void)CJ_skin_setProgressTintColorKey:(NSString *)key;
- (void)CJ_skin_setTrackTintColorKey:(NSString *)key;
- (void)CJ_skin_setProgressImageKey:(NSString *)key;
- (void)CJ_skin_setTrackImageKey:(NSString *)key;
@end

@interface UITextField (CJSkin)
- (void)CJ_skin_setTextColorKey:(NSString *)key;
- (void)CJ_skin_setFontKey:(NSString *)key;
- (void)CJ_skin_setDefaultTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)defaultTextAttributes;
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key;
- (void)CJ_skin_setDisabledBackgroundImageKey:(NSString *)key;
- (void)CJ_skin_setTypingAttributes:(NSDictionary<NSAttributedStringKey,id> *)typingAttributes;
@end

@interface UITextView (CJSkin)
- (void)CJ_skin_setFontKey:(NSString *)key;
- (void)CJ_skin_setTextColorKey:(NSString *)key;
- (void)CJ_skin_setTypingAttributes:(NSDictionary<NSAttributedStringKey,id> *)typingAttributes;
- (void)CJ_skin_setLinkTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)linkTextAttributes;
@end

@interface UISegmentedControl (CJSkin)
- (void)CJ_skin_insertSegmentWithImageKey:(NSString *)key atIndex:(NSUInteger)segment animated:(BOOL)animated;
- (void)CJ_skin_setImageKey:(NSString *)key forSegmentAtIndex:(NSUInteger)segment;
- (void)CJ_skin_setTintColorKey:(NSString *)key;
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
- (void)CJ_skin_setDividerImageKey:(NSString *)key forLeftSegmentState:(UIControlState)leftState rightSegmentState:(UIControlState)rightState barMetrics:(UIBarMetrics)barMetrics;
- (void)CJ_skin_setTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes forState:(UIControlState)state;
@end

@interface UISwitch (CJSkin)
- (void)CJ_skin_setOnTintColorKey:(NSString *)key;
- (void)CJ_skin_setTintColorKey:(NSString *)key;
- (void)CJ_skin_setThumbTintColorKey:(NSString *)key;
- (void)CJ_skin_setOnImageKey:(NSString *)key;
- (void)CJ_skin_setOffImageKey:(NSString *)key;
@end

@interface UISlider (CJSkin)
- (void)CJ_skin_setMinimumValueImageKey:(NSString *)key;
- (void)CJ_skin_setMaximumValueImageKey:(NSString *)key;
- (void)CJ_skin_setMinimumTrackTintColorKey:(NSString *)key;
- (void)CJ_skin_setMaximumTrackTintColorKey:(NSString *)key;
- (void)CJ_skin_setThumbTintColorKey:(NSString *)key;
- (void)CJ_skin_setThumbImageKey:(NSString *)key forState:(UIControlState)state;
- (void)CJ_skin_setMinimumTrackImageKey:(NSString *)key forState:(UIControlState)state;
- (void)CJ_skin_setMaximumTrackImageKey:(NSString *)key forState:(UIControlState)state;
@end

@interface UISearchBar (CJSkin)
- (void)CJ_skin_setTintColorKey:(NSString *)key;
- (void)CJ_skin_setBarTintColorKey:(NSString *)key;
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key;
- (void)CJ_skin_setBackgroundImageFromColorKey:(NSString *)key;
- (void)CJ_skin_setScopeBarBackgroundImageKey:(NSString *)key;
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics;
- (void)CJ_skin_setSearchFieldBackgroundImageKey:(NSString *)key forState:(UIControlState)state;
- (void)CJ_skin_setImageKey:(NSString *)key forSearchBarIcon:(UISearchBarIcon)icon state:(UIControlState)state;
- (void)CJ_skin_setScopeBarButtonBackgroundImageKey:(NSString *)key forState:(UIControlState)state;
- (void)CJ_skin_setScopeBarButtonDividerImageKey:(NSString *)key forLeftSegmentState:(UIControlState)leftState rightSegmentState:(UIControlState)rightState;
- (void)CJ_skin_setScopeBarButtonTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes forState:(UIControlState)state;
@end

@interface UIToolbar (CJSkin)
- (void)CJ_skin_setTintColorKey:(NSString *)key;
- (void)CJ_skin_setBarTintColorKey:(NSString *)key;
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key forToolbarPosition:(UIBarPosition)topOrBottom barMetrics:(UIBarMetrics)barMetrics;
- (void)CJ_skin_setShadowImageKey:(NSString *)key forToolbarPosition:(UIBarPosition)topOrBottom;
@end

@interface UITabBar (CJSkin)
- (void)CJ_skin_setTintColorKey:(NSString *)key;
- (void)CJ_skin_setBarTintColorKey:(NSString *)key;
- (void)CJ_skin_setUnselectedItemTintColorKey:(NSString *)key NS_AVAILABLE_IOS(10_0) UI_APPEARANCE_SELECTOR;
- (void)CJ_skin_setSelectedImageTintColorKey:(NSString *)key NS_DEPRECATED_IOS(5_0,8_0,"Use tintColor") UI_APPEARANCE_SELECTOR __TVOS_PROHIBITED;
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key;
- (void)CJ_skin_setSelectionIndicatorImageKey:(NSString *)key;
- (void)CJ_skin_setShadowImageKey:(NSString *)key;
@end

@interface UIBarItem (CJSkin)
- (void)CJ_skin_setImageKey:(NSString *)key;
- (void)CJ_skin_setLandscapeImagePhoneKey:(NSString *)key;
- (void)CJ_skin_setLargeContentSizeImageKey:(NSString *)key API_AVAILABLE(ios(11.0));
- (void)CJ_skin_setTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes forState:(UIControlState)state;
@end

@interface UIBarButtonItem (CJSkin)
/**
 初始化 UIBarButtonItem

 @param imageKey 正常状态下图片
 @param highlightImageKey 点击高亮图片
 @param target 点击事件响应者
 @param action 响应事件
 @return UIBarButtonItem
 */
+ (UIBarButtonItem *)CJ_skin_itemWithImageKey:(NSString *)imageKey highlightImageKey:(NSString *)highlightImageKey target:(id)target action:(SEL)action;
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key forState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics;
- (void)CJ_skin_setTintColorKey:(NSString *)key;
- (void)CJ_skin_setBackButtonBackgroundImageKey:(NSString *)key forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
@end

@interface UITabBarItem (CJSkin)
- (instancetype)CJ_skin_initWithTitle:(NSString *)title imageKey:(NSString *)imageKey tag:(NSInteger)tag;
- (instancetype)CJ_skin_initWithTitle:(NSString *)title imageKey:(NSString *)imageKey selectedImageKey:(NSString *)selectedImageKey;
- (void)CJ_skin_setSelectedImageKey:(NSString *)key;
- (void)CJ_skin_setFinishedSelectedImageKey:(NSString *)selectedImageKey withFinishedUnselectedImageKey:(NSString *)unselectedImageKey NS_DEPRECATED_IOS(5_0,7_0,"Use initWithTitle:image:selectedImage: or the image and selectedImage properties along with UIImageRenderingModeAlwaysOriginal") __TVOS_PROHIBITED;
- (void)CJ_skin_setBadgeColorKey:(NSString *)key NS_AVAILABLE_IOS(10_0) UI_APPEARANCE_SELECTOR;
- (void)CJ_skin_setBadgeTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)textAttributes forState:(UIControlState)state;
@end

@interface UINavigationBar (CJSkin)
- (void)CJ_skin_setTintColorKey:(NSString *)key;
- (void)CJ_skin_setBarTintColorKey:(NSString *)key;
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics;
- (void)CJ_skin_setBackgroundImageKey:(NSString *)key forBarMetrics:(UIBarMetrics)barMetrics;
- (void)CJ_skin_setShadowImageKey:(NSString *)key;
- (void)CJ_skin_setTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)titleTextAttributes;
- (void)CJ_skin_setLargeTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)largeTitleTextAttributes;
- (void)CJ_skin_setBackIndicatorImageKey:(NSString *)key;
- (void)CJ_skin_setBackIndicatorTransitionMaskImageKey:(NSString *)key;
@end

@interface UIApplication (CJSkin)
- (void)CJ_skin_setNewsstandIconImageKey:(NSString *)key;
@end
