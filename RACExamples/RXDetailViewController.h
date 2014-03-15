//
//  RXDetailViewController.h
//  RACExamples
//
//  Created by Naoki Tsutsui on 2014/03/15.
//  Copyright (c) 2014年 Naoki Tsutsui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RXDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
