//
//  CJNextViewController.m
//  CJSkin
//
//  Created by lele8446 on 01/16/2019.
//  Copyright (c) 2019 lele8446. All rights reserved.
//

#import "CJNextViewController.h"
#import "CJSkin.h"
#import "CJSkinConfig.h"

@interface CJNextViewController ()
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UIButton *button;
@end

@implementation CJNextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"下一页";
    
    UIBarButtonItem *leftBarButtonItem = [UIBarButtonItem CJ_skin_itemWithImageKey:@"nav_back" highlightImageKey:nil target:self action:@selector(backClick)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
//    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc]init];
//    leftBarButtonItem.target = self;
//    leftBarButtonItem.action = @selector(backClick);
//    [leftBarButtonItem CJ_skin_setImageKey:@"nav_back"];
//    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    /*
     *UIKit 分类方法便捷设置属性
     */
    //设置背景色
//    [self.view CJ_skin_setBackgroundColorKey:CJSkinViewBgColorKey colorChangeInterval:0.25];
//    
//    
//    [self.searchBar CJ_skin_setBackgroundImageFromColorKey:CJSkinNavBarColorKey];
//    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
//    [searchField CJ_skin_setBackgroundColorKey:CJSkinViewBgColorKey];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)backClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clearSkin:(id)sender {
    [CJSkin removeSkinPackWithName:@"skin2" resultBlock:^(NSError *error) {
        NSLog(@"%@",error);
        NSString *title = @"删除皮肤包失败";
        NSString *errorStr = error.localizedDescription;
        if (errorStr.length == 0) {
            title = @"删除成功";
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:errorStr preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (IBAction)updateSkin:(id)sender {
    NSDictionary *skinInfo = @{@"skin2": @{
                                       @"Color": @{
                                               @"导航背景色": @"0x454545",
                                               @"tab背景色": @"0xF2F2F2",
                                               @"tab颜色": @"0x67708C",
                                               @"tab点击高亮色": @"0x454545",
                                               @"view背景色": @"0xC0C0C0"
                                               },
                                       @"Image": @{
                                               @"顶部图片": @"https://ss1.baidu.com/9vo3dSag_xI4khGko9WTAnF6hhy/image/h%3D300/sign=a8d02e1ccecec3fd943ea175e68ad4b6/1f178a82b9014a90e7c1956da4773912b21bee67.jpg"
                                               },
                                       @"Font": @{
                                               @"文字一": @{
                                                       @"Name": @"Kefa",
                                                       @"Size": @"20"
                                                       }
                                               }
                                       }};
    [CJSkin updateSkinPlistInfo:skinInfo resultBlock:^(BOOL result, NSError *error) {
        NSString *title = @"更新失败";
        if (result) {
            title = @"更新成功";
        }
        NSLog(@"%@",error);
        NSString *errorStr = error.localizedDescription;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:errorStr preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (IBAction)test1:(id)sender {
    //参数为基础数字类型
    [self.button CJSkinInvokeMethodForSelector:@selector(setAlpha:) withArguments:@[@(0.8)]];
    //参数为BOOL类型
    [self.button CJSkinInvokeMethodForSelector:@selector(setHidden:) withArguments:@[@(NO)]];
    //参数为结构体
    UIEdgeInsets insets = {10,10,10,10};
    NSValue *value = [NSValue valueWithUIEdgeInsets:insets];
    [self.button CJSkinInvokeMethodForSelector:@selector(setImageEdgeInsets:) withArguments:@[value]];

    //参数为图片通过 CJSkinTool 实例获取
    CJSkinTool *skintool = SkinImageTool(CJSkinHeadImageKey);
    [self.button CJSkinInvokeMethodForSelector:@selector(setImage:forState:) withArguments:@[skintool,@(UIControlStateNormal)]];
    [self.button CJ_skin_setBackgroundColorKey:CJSkinNavBarColorKey forState:UIControlStateNormal];

    //id类型的参数，使用 SkinSafeObject(obj) 方法转换为安全参数
    UIImage *highlightedImage = [UIImage imageNamed:@"nav_back"];
    highlightedImage = SkinSafeObject(highlightedImage);
    [self.button CJSkinInvokeMethodForSelector:@selector(setImage:forState:) withArguments:@[highlightedImage,@(UIControlStateHighlighted)]];
    [self.button CJ_skin_setBackgroundColorKey:CJSkinViewBgColorKey forState:UIControlStateHighlighted];

    //参数为颜色通过 CJSkinTool 实例获取
    skintool = SkinColorTool(CJSkinTabBarTextSelectColorKey);
    [self.button CJSkinInvokeMethodForSelector:@selector(setTitleColor:forState:) withArguments:@[skintool,@(UIControlStateNormal)]];

    //id类型的参数，使用 SkinSafeObject(obj) 方法转换为安全参数
    NSString *title = @"按钮";
    [self.button CJSkinInvokeMethodForSelector:@selector(setTitle:forState:) withArguments:@[SkinSafeObject(title),@(UIControlStateNormal)]];
    //参数为字体通过 CJSkinTool 实例获取
    skintool = SkinFontTool(CJSkinTitleKey);
    skintool.fontType = CJSkinFontTypeBold;
    [self.button.titleLabel CJSkinInvokeMethodForSelector:@selector(setFont:) withArguments:@[skintool]];
}

- (IBAction)test2:(id)sender {
    CJSkinTool *skinColor = SkinColorTool(CJSkinNavBarColorKey);
    CJSkinTool *skinImage = SkinImageTool(CJSkinHeadImageKey);
    CJSkinTool *skinFont = SkinFontTool(CJSkinTitleKey);
    CJSkinTool *skinImageFromColor = SkinImageFromColorTool(CJSkinNavBarColorKey);
    char arg3 = 'a';
    char *arg4 = &arg3;
    NSValue *valueArg4 = [NSValue value:&arg4 withObjCType:@encode(char *)];
    NSIndexPath *arg7 = [[NSIndexPath alloc]initWithIndex:5];
    CGRect arg16 = {{5,5},{10,20}};
    NSValue *arg8 = [NSValue valueWithCGRect:arg16];
    
    NSArray *arg14 = @[@"11",skinImageFromColor,skinColor,@[skinFont,@(123),@(0.12)],@{@"ziti":skinFont}];
    NSSet *arg10 = [[NSSet alloc]initWithArray:arg14];
    NSNumber *arg12 = [NSNumber numberWithChar:arg3];
    UILabel *arg13 = [[UILabel alloc]init];
    NSDictionary *arg15 = @{@"args":@(arg3),@"image":skinImage,@"array":arg14,@"string":@"this is a string"};
    SEL arg17 = @selector(testArg17:);
    id arg18 = self;
    
    NSValue *valueArg18 = [NSValue value:&arg18 withObjCType:@encode(void *)];
//    [self testLog:YES
//             arg2:1
//             arg3:arg3
//             arg4:arg4
//             arg5:5555
//             arg6:10
//             arg7:arg7
//             arg8:arg8
//             arg9:@"ceshi9"
//            arg10:arg10
//            arg11:11.11
//            arg12:arg12
//            arg13:arg13
//            arg14:arg14
//            arg15:arg15
//            arg16:arg16
//            arg17:arg17
//            arg18:arg18];
    
    [self CJSkinInvokeMethodForSelector:@selector(testLog:arg2:arg3:arg4:arg5:arg6:arg7:arg8:arg9:arg10:arg11:arg12:arg13:arg14:arg15:arg16:arg17:arg18:)
                           withArguments:@[@(YES),
                                           @(1),
                                           @(arg3),
                                           valueArg4,
                                           @(5555),
                                           @(10),
                                           arg7,
                                           arg8,
                                           @"ceshi9",
                                           arg10,
                                           @(11.11),
                                           arg12,
                                           arg13,
                                           arg14,
                                           arg15,
                                           @(arg16),
                                           SkinSELArg(arg17),
                                           valueArg18
                                           ]];
    
}

- (void)testLog:(BOOL)arg1 arg2:(int)arg2 arg3:(char)arg3 arg4:(char *)arg4 arg5:(long)arg5 arg6:(NSInteger)arg6 arg7:(NSIndexPath *)arg7 arg8:(NSValue *)arg8 arg9:(NSString *)arg9 arg10:(NSSet *)arg10 arg11:(CGFloat)arg11 arg12:(NSNumber *)arg12 arg13:(UILabel *)arg13 arg14:(NSArray *)arg14 arg15:(NSDictionary *)arg15 arg16:(CGRect)arg16 arg17:(SEL)arg17 arg18:(void *)arg18 {
    NSString *arg1Str = [NSString stringWithFormat:@"arg1 BOOL = %@",@(arg1)];
    NSString *arg2Str = [NSString stringWithFormat:@"arg2 int = %@",@(arg2)];
    NSString *arg3Str = [NSString stringWithFormat:@"arg3 char = %c",arg3];
    NSString *arg4Str = [NSString stringWithFormat:@"arg4 char * = %s",arg4];
    NSString *arg5Str = [NSString stringWithFormat:@"arg5 long = %@",@(arg5)];
    NSString *arg6Str = [NSString stringWithFormat:@"arg6 NSInteger = %@",@(arg6)];
    NSString *arg7Str = [NSString stringWithFormat:@"arg7 NSIndexPath = %@",arg7];
    NSString *arg8Str = [NSString stringWithFormat:@"arg8 NSValue = %@",arg8];
    NSString *arg9Str = [NSString stringWithFormat:@"arg9 NSString = %@",arg9];
    NSString *arg10Str = [NSString stringWithFormat:@"arg10 NSSet = %@",arg10];
    NSString *arg11Str = [NSString stringWithFormat:@"arg11 CGFloat = %@",@(arg11)];
    NSString *arg12Str = [NSString stringWithFormat:@"arg12 NSNumber = %@",arg12];
    NSString *arg13Str = [NSString stringWithFormat:@"arg13 UILabel = %@",arg13];
    NSString *arg14Str = [NSString stringWithFormat:@"arg14 NSArray = %@",arg14];
    NSString *arg15Str = [NSString stringWithFormat:@"arg15 NSDictionary = %@",arg15];
    NSString *arg16Str = [NSString stringWithFormat:@"arg16 CGRect = %@",NSStringFromCGRect(arg16)];
    NSString *arg17Str = [NSString stringWithFormat:@"arg17 SEL = %@",NSStringFromSelector(arg17)];
    NSString *arg18Str = [NSString stringWithFormat:@"arg18 void * = %@",arg18];
    
    NSString *str = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@",arg1Str,arg2Str,arg3Str,arg4Str,arg5Str,arg6Str,arg7Str,arg8Str,arg9Str,arg10Str,arg11Str,arg12Str,arg13Str,arg14Str,arg15Str,arg16Str,arg17Str,arg18Str];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"测试" message:str preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}


- (CGRect)testArg17:(id)arg {
    CGRect rect = CGRectZero;
    return rect;
}
@end
