//
//  CJTableViewController.m
//  CJSkin
//
//  Created by lele8446 on 01/16/2019.
//  Copyright (c) 2019 lele8446. All rights reserved.
//

#import "CJTableViewController.h"
#import "CJSkin.h"
#import "CJSkinConfig.h"
#import "CJTableViewCell.h"

static NSString *CJTableViewCellString = @"CJTableViewCell";
@interface CJTableViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation CJTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"列表换肤";
    
    [self.view CJ_skin_setBackgroundColorKey:CJSkinViewBgColorKey];
    
    UIBarButtonItem *leftBarButtonItem = [UIBarButtonItem CJ_skin_itemWithImageKey:@"nav_back" highlightImageKey:nil target:self action:@selector(backClick)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithTitle:@"换肤" style:UIBarButtonItemStyleDone target:self action:@selector(changeSkin)];
    //    [UIBarButtonItem CJ_skin_itemWithImageKey:@"nav_back" highlightImageKey:@"nav_back" target:self action:@selector(changeSkin)];
    [right setSkinChangeBlock:^(UIBarButtonItem *weakSelf) {
        weakSelf.tintColor = SkinColor(@"CJSkinTabBarTextColorKey");
    }];
    self.navigationItem.rightBarButtonItem = right;
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView CJ_skin_setBackgroundColorKey:CJSkinViewBgColorKey];
    [self.tableView CJSkinInvokeMethodForSelector:@selector(reloadData) withArguments:nil];
    [self.view addSubview:self.tableView];
    
    self.tableView.estimatedRowHeight = 10;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self loadData];
    
    [self CJSkinInvokeMethodForSelector:@selector(reloadData) withArguments:nil];
}

- (void)reloadData {
    NSLog(@"自定义加载逻辑");
}

- (void)backClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)changeSkin {
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

- (void)loadData {
    self.dataArray = [NSMutableArray array];
    NSString *str = @"CJSkin 皮肤包信息管理类，可获取当前皮肤包信息、更换皮肤包、删除指定皮肤包、下载并更新皮肤包（下载的json数据结构参照 CJSkin.plist 文件说明）等功能\nCJSkinTool 获取皮肤资源工具类，换肤所需的颜色、图片、字体等只能通过该类转换获取，其中提供了丰富的便捷获取资源方法";
    for (NSInteger i = 0; i < 30; i++) {
        [self.dataArray addObject:str];
    }
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CJTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CJTableViewCellString];
    if (!cell) {
        cell = [CJTableViewCell initCellWithTableView:tableView forCellReuseIdentifier:CJTableViewCellString];
    }
    [cell loadData:self.dataArray[indexPath.row]];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
