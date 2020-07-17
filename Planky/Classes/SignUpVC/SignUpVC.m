//
//  SignUpVC.m
//  Planky
//
//  Created by Neelesh Aggarwal on 12/11/15.
//  Copyright © 2015 Neelesh Aggarwal. All rights reserved.
//

#import "Common.h"
#import "SignUpVC.h"
#import "PhotoGalleryVC.h"
#import "ShareOptionVC.h"
#import "LoginSelectionVC.h"
#import "CouchbaseEvents.h"
#import "AppDelegate.h"
#import "ShareOptionVC.h"
#import "LoginVC.h"
#import "SharedWebCaller.h"

#define kSuccessfullTag  -100

@interface SignUpVC () <UITextFieldDelegate, UIAlertViewDelegate>
{
    CGSize screenSize;
    float mRowHeight;
}
// IBOutlets
@property (nonatomic, weak) IBOutlet UILabel*           mViewTitleLabel;            // Sign up title label
@property (nonatomic, weak) IBOutlet UILabel*           mSpaceDetailsLabel;         // Space to be available
@property (nonatomic, weak) IBOutlet UITableView*       mTableView;
@property (nonatomic, weak) IBOutlet UIButton*          mSignUpButton;
@property (strong, nonatomic) IBOutlet UIButton *btnSignUp;
@property (strong, nonatomic) IBOutlet CustomImageView *mCustomImageView;

// Other objects
@property (nonatomic, strong) NSString*                 mname, *mLastName, *mEmail, *mPassword, *mConfirmPassword;

@property (nonatomic, assign) BOOL                      mIsViewUp;

@property (nonatomic, strong) NSMutableDictionary*           mUserInfoDic;

@end

@implementation SignUpVC

@synthesize mUserInfoDic;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeView
{
    CGRect frame = [UIScreen mainScreen].bounds;
    
    screenSize = frame.size;
    mRowHeight = 132 * screenSize.height / 1334.0f;
    
    [self.mCustomImageView setBlackViewRect:frame withIsBlur:YES];
    
    [self setFonts];
    
    // Localized values
    self.mViewTitleLabel.text = NSLocalizedString(@"SignUpViewTitle", nil);
    [self.mSignUpButton setTitle:NSLocalizedString(@"SignUpButtonTitle", nil) forState:UIControlStateNormal];
    
    // Set free space
    self.mSpaceDetailsLabel.text = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"freeText", nil), g_freeSpace, NSLocalizedString(@"nowLabel", nil)];
    
    
    mUserInfoDic = [[NSMutableDictionary alloc] init];

}

-(void)setFonts
{
    self.mViewTitleLabel.font = [Common getFontWithFamilyName:BariolLight withFontSize:70];
    self.mSpaceDetailsLabel.font = [Common getFontWithFamilyName:BariolLight withFontSize:48];
    
    self.btnSignUp.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
}

#pragma mark - UITableView Cell Delegate And Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return mRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    // remove previous view
    for (id view in cell.contentView.subviews)
        [view removeFromSuperview];
    
    // Add textfield
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(50 * screenSize.width / 750.0f, mRowHeight * 60 / 132.0f, screenSize.width * 650 / 750.0f, mRowHeight * 48 /132.0f)];
    textField.delegate = self;
    textField.font = [Common getFontWithFamilyName:BariolLight withFontSize:48];
    textField.backgroundColor = [UIColor clearColor];
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.textColor = [UIColor whiteColor];
    textField.tag = indexPath.row;
    
    switch (indexPath.row) {
        case 0: {                               // First Name
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SignUpFirstName", @"Name Placeholder string") attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"firstName"])
                textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstName"];
                
            break;
        }
        case 1: {                               // Last Name
             textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SignUpLastName", @"Name Placeholder string") attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lastName"])
                textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastName"];
            break;
        }
        case 2: {                               // Email
              textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SignUpEmail", nil) attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"email"])
                textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
            
            break;
        }
        case 3: {                               // Password
              textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SignUpPassword", nil) attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
            
            textField.secureTextEntry = YES;
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"password"])
                textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
            
            break;
        }
        case 4: {                               // Confirm Password
              textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SignUpRepeatPassword", nil) attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
            
            textField.secureTextEntry = YES;
            
            break;
        }
        default:
            break;
    }
    
    
    [cell.contentView addSubview:textField];
    
    
    // Add Border
    
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(50 * screenSize.width / 750.0f, mRowHeight-1, screenSize.width * 650 / 750.0f, 2 * screenSize.height / 1334.0f)];
    borderView.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:borderView];
    
    
    return cell;
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (!self.mIsViewUp)
        [self moveViewUp];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self setTextFieldValue:textField];
    
    // Move current view down
    [self moveViewDown];
    
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    [self setTextFieldValue:textField];
    
    return YES;
}

- (void)setTextFieldValue:(UITextField *)textField {
    switch (textField.tag) {
        case 0: {                       // First Name
            [mUserInfoDic setValue:textField.text forKey:@"firstName"];
            break;
        }
        case 1: {                       // Last Name
            [mUserInfoDic setValue:textField.text forKey:@"lastName"];
            break;
        }
        case 2: {                       // Email
            [mUserInfoDic setValue:textField.text forKey:@"email"];
            break;
        }
        case 3: {                       // Password
            [mUserInfoDic setValue:textField.text forKey:@"password"];
            break;
        }
        case 4: {                       // Confirm Password
            [mUserInfoDic setValue:textField.text forKey:@"confirmPassword"];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - save the user info
- (void) saveUserInfo
{
    [[NSUserDefaults standardUserDefaults] setObject:[mUserInfoDic valueForKey:@"firstName"]  forKey:@"firstName"];
    [[NSUserDefaults standardUserDefaults] setObject:[mUserInfoDic valueForKey:@"lastName"]  forKey:@"lastName"];
    [[NSUserDefaults standardUserDefaults] setObject:[mUserInfoDic valueForKey:@"email"]  forKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setObject:[mUserInfoDic valueForKey:@"password"]  forKey:@"password"];
    
}

#pragma mark - Sign Up

- (IBAction)signUp:(id)sender {

    // End editing
    [self.view endEditing:YES];
    
    if ([self isInputValidated]) {
    
        // Show loading indicator
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showProgressViewOnView:self.view];
        
        [self performSelector:@selector(signUpUserToServer) withObject:nil afterDelay:0.1];
    }
}

- (void)signUpUserToServer {
    
//    CouchbaseEvents *event = [[CouchbaseEvents alloc] init];

    // API call to server
//    [event registerUserWithFirstName:[mUserInfoDic valueForKey:@"firstName"] lastName:[mUserInfoDic valueForKey:@"lastName"] email:[mUserInfoDic valueForKey:@"email"] andPassword:[mUserInfoDic valueForKey:@"password"]];

    [[SharedWebCaller sharedManager] createUserWithFirstName:[mUserInfoDic valueForKey:@"firstName"] lastName:[mUserInfoDic valueForKey:@"lastName"] email:[mUserInfoDic valueForKey:@"email"] andPassword:[mUserInfoDic valueForKey:@"password"] withCompletionHandler:^(NSMutableDictionary *responseDict, NSError *error) {
        
        // Create user with received details
        CouchbaseEvents *event = [[CouchbaseEvents alloc] init];
        [event saveUserResponseDetails:responseDict];

        // Hide loading indicator
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate hideProgressViewFromView:self.view];
        
        [self saveUserInfo];
        
        // Sign up complete alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Successful" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = kSuccessfullTag;
        [alert show];

    }withFailureHandler:^(NSMutableDictionary *failureDict, NSError *error) {
        
        // Hide loading indicator
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate hideProgressViewFromView:self.view];
        
        // alert 
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to sign up" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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


#pragma mark - Slide Left Button

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Private Methods

- (void)moveViewUp {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    
    CGRect frame = self.view.frame;
    frame.origin.y -= 120;
    self.view.frame = frame;
    
    [UIView commitAnimations];
    
    self.mIsViewUp = YES;
}

- (void)moveViewDown {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    self.view.frame = frame;
    
    [UIView commitAnimations];
    
    self.mIsViewUp = NO;
}

- (BOOL)isInputValidated {
    
    // Validate all input values
    
    // First Name
    if ([mUserInfoDic valueForKey:@"firstName"]== nil || [[[mUserInfoDic valueForKey:@"firstName"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Failed" message:@"Please input first name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    // Last Name
    else if ([mUserInfoDic valueForKey:@"lastName"]== nil || [[[mUserInfoDic valueForKey:@"lastName"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Failed" message:@"Please input last name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    // Email
    else if ([mUserInfoDic valueForKey:@"email"]== nil || [[[mUserInfoDic valueForKey:@"email"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Failed" message:@"Please input email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    // Password
    else if ([mUserInfoDic valueForKey:@"password"]== nil || [[[mUserInfoDic valueForKey:@"password"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Failed" message:@"Please input password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }

    // Repeat Password
    else if (![[mUserInfoDic valueForKey:@"password"] isEqualToString:[mUserInfoDic valueForKey:@"confirmPassword"]]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Failed" message:@"Password does not match" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    // Email verification
    NSString *emailRegex = @"[A-Z0-9a-z]+([._%+-]{1}[A-Z0-9a-z]+)*@[A-Z0-9a-z]+([.-]{1}[A-Z0-9a-z]+)*(\\.[A-Za-z]{2,4}){0,1}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if (![emailTest evaluateWithObject:[mUserInfoDic valueForKey:@"email"]])
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Failed" message:@"Invalid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    return YES;
}

@end
