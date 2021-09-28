//
//  CJSecondViewController.m
//  CJSkin
//
//  Created by lele8446 on 01/16/2019.
//  Copyright (c) 2019 lele8446. All rights reserved.
//

#import "CJSecondViewController.h"
#import "CJSkin.h"
#import "CJSkinConfig.h"

@interface CJSecondViewController ()
@property (nonatomic, weak) IBOutlet UISwitch *switchBtn;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation CJSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view CJ_skin_setBackgroundColorKey:CJSkinViewBgColorKey];
    
    CJSkinTool *skintool = SkinColorTool(CJSkinNavBarColorKey);
    [self.switchBtn CJSkinInvokeMethodForSelector:@selector(setOnTintColor:) withArguments:@[skintool]];
    
    [self.segmentedControl CJ_skin_setTintColorKey:CJSkinNavBarColorKey];
}

- (IBAction)changeSkin:(id)sender {
    
    NSDictionary *skinInfo = [[CJSkin manager] skinPlistInfo];
    int x = arc4random() % skinInfo.allKeys.count;
    [CJSkin changeSkinWithName:skinInfo.allKeys[x] resultBlock:nil];
    
}

- (IBAction)removeSkin:(id)sender {
    NSDictionary *skinInfo = [[CJSkin manager] skinPlistInfo];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除皮肤" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *str in skinInfo.allKeys) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:str style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [CJSkin removeSkinPackWithName:str resultBlock:^(NSError *error) {
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
        }];
        [alert addAction:action];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)revertSkin:(id)sender {
    //只在DEBUG下有效
    [CJSkin loadSkinInfoFromBundle];
}

@end
