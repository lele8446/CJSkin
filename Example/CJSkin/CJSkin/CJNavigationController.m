//
//  CJNavigationController.m
//  CJSkin
//
//  Created by lele8446 on 01/16/2019.
//  Copyright (c) 2019 lele8446. All rights reserved.
//

#import "CJNavigationController.h"
#import "CJSkin.h"
#import "CJSkinConfig.h"

@interface CJNavigationController ()

@end

@implementation CJNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CJSkinTool *skintool = SkinFontTool(CJSkinTitleKey);
    skintool.fontType = CJSkinFontTypeBold;
    NSDictionary *dic = @{
                          NSFontAttributeName:skintool,
                          NSForegroundColorAttributeName:[UIColor whiteColor],
                          };
    [self.navigationBar CJSkinInvokeMethodForSelector:@selector(setTitleTextAttributes:) withArguments:@[dic]];
    
    
    skintool = SkinColorTool(CJSkinTabBarTextColorKey);
    [self.navigationBar CJSkinInvokeMethodForSelector:@selector(setBarTintColor:) withArguments:@[skintool]];

    skintool = SkinImageFromColorTool(CJSkinNavBarColorKey);
    skintool.skinColorChangeInterval = 0.25;
    [self.navigationBar CJSkinInvokeMethodForSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:) withArguments:@[skintool,@(UIBarPositionAny),@(UIBarMetricsDefault)]];
    self.navigationBar.shadowImage = [UIImage new];
    
}

- (void)setTabBarItemImageName:(NSString *)tabBarItemImageName {
    _tabBarItemImageName = tabBarItemImageName;
    if (tabBarItemImageName.length > 0) {
        [self.tabBarItem CJ_skin_setImageKey:tabBarItemImageName];
        
        CJSkinTool *skintool = SkinColorTool(CJSkinTabBarTextColorKey);
        NSDictionary *textAttributes = @{NSForegroundColorAttributeName:skintool};
        [self.tabBarItem CJ_skin_setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    }
}

- (void)setTabBarItemSelectedImageName:(NSString *)tabBarItemSelectedImageName {
    _tabBarItemSelectedImageName = tabBarItemSelectedImageName;
    if (self.tabBarItemSelectedImageName.length > 0) {
        [self.tabBarItem CJ_skin_setSelectedImageKey:tabBarItemSelectedImageName];
        
        CJSkinTool *skintool = SkinColorTool(CJSkinTabBarTextSelectColorKey);
        NSDictionary *textAttributes = @{NSForegroundColorAttributeName:skintool};
        [self.tabBarItem CJ_skin_setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
    }
}
@end
