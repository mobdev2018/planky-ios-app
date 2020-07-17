//
//  TermsPrivacyViewController.m
//  Planky
//
//  Created by beauty on 1/4/16.
//  Copyright © 2016 Neelesh Aggarwal. All rights reserved.
//

#import "Common.h"
#import "TermsPrivacyViewController.h"

@interface TermsPrivacyViewController ()

@property (strong, nonatomic) IBOutlet UILabel *mTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *mContentTitleLabel;
@property (strong, nonatomic) IBOutlet UITextView *mContentTextView;

@end

@implementation TermsPrivacyViewController

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
    self.mTitleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
    self.mContentTitleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:42];
    
    NSString *strLegalPath = [[NSBundle mainBundle] pathForResource:@"TermsAndPrivacy" ofType:@"plist"];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithContentsOfFile:strLegalPath];
    NSString *strText = [dic objectForKey:@"english"];
    self.mContentTextView.text = strText;
    
    self.mContentTextView.font = [Common getFontWithFamilyName:BariolRegular withFontSize:36];
}

#pragma mark - back button

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
