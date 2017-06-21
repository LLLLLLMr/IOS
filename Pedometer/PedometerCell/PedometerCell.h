//
//  PedometerCell.h
//  Pedometer
//
//  Created by mac on 2017/6/21.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PedometerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ranking;
@property (weak, nonatomic) IBOutlet UIImageView *headPortrait;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *stepCount;
@property (weak, nonatomic) IBOutlet UIButton *thumbUpBtn;
@property (weak, nonatomic) IBOutlet UILabel *count;

@end
