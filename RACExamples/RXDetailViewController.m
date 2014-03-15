//
//  RXDetailViewController.m
//  RACExamples
//
//  Created by Naoki Tsutsui on 2014/03/15.
//  Copyright (c) 2014年 Naoki Tsutsui. All rights reserved.
//

#import "RXDetailViewController.h"

@interface RXDetailViewController ()
- (void)configureView;
@end

@implementation RXDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
