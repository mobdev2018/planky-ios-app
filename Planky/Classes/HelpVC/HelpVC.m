//
//  HelpVC.m
//  Planky
//
//  Created by beauty on 1/4/16.
//  Copyright © 2016 Neelesh Aggarwal. All rights reserved.
//

#import "Common.h"
#import "HelpVC.h"

@interface HelpVC ()

@property (strong, nonatomic) IBOutlet UILabel *mViewTitleLabel;

@end

@implementation HelpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializeViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initializeViews
{
    self.mViewTitleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
}

#pragma mark - back button

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
