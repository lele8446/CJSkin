//
//  CJTableViewCell.m
//  CJSkin
//
//  Created by lele8446 on 01/16/2019.
//  Copyright (c) 2019 lele8446. All rights reserved.
//

#import "CJTableViewCell.h"
#import "CJSkin.h"
#import "CJSkinConfig.h"

@interface CJTableViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *bottomImageView;

@end

@implementation CJTableViewCell

+ (instancetype)initCellWithTableView:(UITableView *)tableView forCellReuseIdentifier:(NSString *)identifier {
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] forCellReuseIdentifier:identifier];
    return [[NSBundle mainBundle]loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil][0];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView CJ_skin_setBackgroundColorKey:CJSkinTabBarBgColorKey colorChangeInterval:0.25];
    self.label.numberOfLines = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)loadData:(NSString *)title {
    //设置图片
    [self.bottomImageView CJ_skin_setImageKey:CJSkinHeadImageKey];
    [self.label CJ_skin_setFontKey:@"详情"];
    self.label.text = title;
}

@end
