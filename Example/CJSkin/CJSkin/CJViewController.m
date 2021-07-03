//
//  CJViewController.m
//  CJSkin
//
//  Created by lele8446 on 01/16/2019.
//  Copyright (c) 2019 lele8446. All rights reserved.
//

#import "CJViewController.h"
#import "CJSkin.h"
#import "CJSkinConfig.h"
#import "CJFileDownloader.h"
#import "CJNextViewController.h"
#import "CJTableViewController.h"

@interface CJViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic, weak) IBOutlet UIButton *downloadButton;

@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
@end

@implementation CJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *right = [UIBarButtonItem CJ_skin_itemWithImageKey:@"clear" highlightImageKey:@"clear" target:self action:@selector(clearCache)];
    self.navigationItem.rightBarButtonItem = right;
    
    [self.view CJ_skin_setBackgroundColorKey:CJSkinViewBgColorKey colorChangeInterval:0.25];
    
    //设置图片
    [self.imageView CJ_skin_setImageKey:CJSkinHeadImageKey];
    
    self.button.layer.cornerRadius = 5.0;
    self.button.layer.masksToBounds = YES;
    
    //设置按钮背景色
    [self.button CJ_skin_setBackgroundColorKey:CJSkinNavBarColorKey forState:UIControlStateNormal];
    //设置按钮点击高亮背景色
    [self.button CJ_skin_setBackgroundColorKey:CJSkinTabBarTextColorKey forState:UIControlStateHighlighted];
    
    if (@available(iOS 13.0, *)) {
        self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    } else {
        self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.frame = CGRectMake(0, 0, 100, 100);
    self.activityIndicator.color = [UIColor whiteColor];
    self.activityIndicator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.activityIndicator.layer.cornerRadius = 5.0;
    self.activityIndicator.layer.masksToBounds = YES;
    self.activityIndicator.hidesWhenStopped = NO;
    self.activityIndicator.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y-100);
}

- (void)clearCache {
    BOOL result = [[CJFileDownloader manager]clearCacheAtCustomCachePath:nil resultBlock:^(NSError *error, NSString *msg) {
        if (error) {
            NSString *errorStr = error.localizedDescription;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"网络换肤资源缓存清除失败" message:errorStr preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    if (result) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"网络换肤资源缓存清除完成" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)uploadSkin2:(id)sender {
    NSString *url = @"https://lele8446infoq.oss-cn-shenzhen.aliyuncs.com/cjskin/CJSkinOnlineZip.zip";
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
    [CJSkin downloadSkinZipResourceWithUrl:url parameters:nil cookies:nil progress:^(NSProgress *downloadProgress) {
        NSInteger fractionCompleted = downloadProgress.fractionCompleted * 100;
        NSString *str = [NSString stringWithFormat:@"下载%@%%",@(fractionCompleted)];
        [self.downloadButton setTitle:str forState:UIControlStateNormal];
    } resultBlock:^(BOOL success, NSError *error) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        if (error) {
            NSLog(@"%@",error);
            NSString *errorStr = error.localizedDescription;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"更新换肤资源失败" message:errorStr preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"皮肤包下载成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        [self.downloadButton setTitle:@"下载皮肤包" forState:UIControlStateNormal];
    }];
}

- (IBAction)changeSkin:(id)sender {
    NSDictionary *skinInfo = [[CJSkin manager] skinPlistInfo];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"换肤" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *str in skinInfo.allKeys) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:str style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [CJSkin changeSkinWithName:action.title resultBlock:^(NSError *error) {
                if (error) {
                    NSLog(@"%@",error);
                    NSString *errorStr = error.localizedDescription;
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"换肤失败" message:errorStr preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
        }];
        [alert addAction:action];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)nextPage:(id)sender {
    CJNextViewController *nextPage = [[CJNextViewController alloc]initWithNibName:@"CJNextViewController" bundle:nil];
    nextPage.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextPage animated:YES];
}

- (IBAction)tabviewTest:(id)sender {
    CJTableViewController *ctr = [[CJTableViewController alloc]initWithNibName:nil bundle:nil];
    ctr.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ctr animated:YES];
}

@end

