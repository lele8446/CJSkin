//
//  CJTableViewCell.h
//  CJSkin
//
//  Created by lele8446 on 01/16/2019.
//  Copyright (c) 2019 lele8446. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *label;
+ (instancetype)initCellWithTableView:(UITableView *)tableView forCellReuseIdentifier:(NSString *)identifier;
- (void)loadData:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
