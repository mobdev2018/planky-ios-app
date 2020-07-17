//
//  LoginVC.m
//  Planky
//
//  Created by CanvasM on 26/11/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import "Common.h"
#import "LoginVC.h"
#import "CouchbaseEvents.h"
#import "AppDelegate.h"
#import "ShareOptionVC.h"
#import "SharedWebCaller.h"

#define kSuccessfullTag  -100

@interface LoginVC () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet CustomImageView *mBackgroundImageView;
@property (nonatomic, weak) IBOutlet UITextField*       mEmailTextField;
@property (nonatomic, weak) IBOutlet UITextField*       mPasswordTextField;
@property (nonatomic, weak) IBOutlet UILabel*           mLoginTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel*           mFreeLabel;
@property (nonatomic, weak) IBOutlet UIButton*          mLoginButton;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initializeView {
    
    CGRect frame = [UIScreen mainScreen].bounds;
    [self.mBackgroundImageView setBlackViewRect:frame withIsBlur:YES];
    
    // Set fonts.
    self.mLoginTitleLabel.font = [Common getFontWithFamilyName:BariolLight withFontSize:70];
    self.mFreeLabel.font = [Common getFontWithFamilyName:BariolLight withFontSize:48];
    self.mLoginButton.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
    self.mEmailTextField.font = [Common getFontWithFamilyName:BariolLight withFontSize:48];
    self.mPasswordTextField.font = [Common getFontWithFamilyName:BariolLight withFontSize:48];
    self.mLoginButton.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
    // Localized values
    self.mLoginTitleLabel.text = NSLocalizedString(@"LoginViewTitle", nil);
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"email"])
    {
        self.mEmailTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"password"])
        {
            self.mPasswordTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
        }
    }
    
    
    
    [self.mLoginButton setTitle: NSLocalizedString(@"LoginButtonTitle", nil) forState:UIControlStateNormal];
    
    self.mFreeLabel.text = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"freeText", nil), g_freeSpace, NSLocalizedString(@"nowLabel", nil)];
}

#pragma mark - UITextField Delegate Method

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Slide Left Button

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - User Login

- (IBAction)logIn:(id)sender {
    
    if ([self isInputValidated]) {      // Input validated
    
        // Show loading indicator
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showProgressViewOnView:self.view];
        
        [self performSelector:@selector(logInUserToServer) withObject:nil afterDelay:0.1];
    }
}

- (void)logInUserToServer {
    
    [[SharedWebCaller sharedManager] makeloginWebCallWithEmail:self.mEmailTextField.text andPassword:self.mPasswordTextField.text withCompletionHandler:^(NSMutableDictionary *responseDict, NSError *error) {

        // Create user with received details
        CouchbaseEvents *event = [[CouchbaseEvents alloc] init];
        [event saveUserResponseDetails:responseDict];
        
        [[NSUserDefaults standardUserDefaults] setObject:[responseDict valueForKey:@"f_name"] forKey:@"firstName"];
        [[NSUserDefaults standardUserDefaults] setObject:[responseDict valueForKey:@"l_name"] forKey:@"lastName"];
        [[NSUserDefaults standardUserDefaults] setObject:self.mEmailTextField.text forKey:@"email"];
        [[NSUserDefaults standardUserDefaults] setObject:self.mPasswordTextField.text forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Hide loading indicator
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate hideProgressViewFromView:self.view];
        
        // Sign up complete alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Successful" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = kSuccessfullTag;
        [alert show];

     } withFailureHandler:^(NSMutableDictionary *failureDict, NSError *error) {
         // Hide loading indicator
         AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
         [appDelegate hideProgressViewFromView:self.view];
         
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to login" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alert show];
     }];
}


#pragma mark - UIAlertView Delegate Method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == kSuccessfullTag) {     // Move user to dropbox login screen
        ShareOptionVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareOptionVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - Private Methods

- (BOOL)isInputValidated {
    
    if (self.mEmailTextField.text == nil || [[self.mEmailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Please input email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    else if (self.mPasswordTextField.text == nil || [[self.mPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Please input password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }

    // Email verification
    NSString *emailRegex = @"[A-Z0-9a-z]+([._%+-]{1}[A-Z0-9a-z]+)*@[A-Z0-9a-z]+([.-]{1}[A-Z0-9a-z]+)*(\\.[A-Za-z]{2,4}){0,1}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if (![emailTest evaluateWithObject:self.mEmailTextField.text]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Invalid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }

    return YES;
}

@end
