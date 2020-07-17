//
//  LoginSelectionVC.m
//  Planky
//
//  Created by CanvasM on 18/11/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import "Common.h"
#import "LoginSelectionVC.h"
#import "SignUpVC.h"
#import "ShareOptionVC.h"
#import "HomeVC.h"
#import "LoginVC.h"

#define FACEBOOK_KEY        @"547230638777218"

@interface LoginSelectionVC ()

// IBOutlets
@property (nonatomic, weak) IBOutlet CustomImageView*    mBackgroundImageView;
@property (strong, nonatomic) IBOutlet UILabel *lblSignUp;
@property (strong, nonatomic) IBOutlet UILabel *lblFreeSpace;

@property (strong, nonatomic) IBOutlet UIButton *btnSignIn;
@property (strong, nonatomic) IBOutlet UIButton *btnTwitter;
@property (strong, nonatomic) IBOutlet UIButton *btnFacebook;
@property (strong, nonatomic) IBOutlet UIButton *btnEmail;

// Other objects
@property (nonatomic, strong) ACAccountStore*       mAccountStore;
@property (nonatomic, strong) ACAccount*            mFacebookAccount;

@end

@implementation LoginSelectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initializeViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) initializeViews
{
    CGRect frame = [UIScreen mainScreen].bounds;
    frame.size.height = frame.size.height * (1334 - 450) / 1334.0f;
    [self.mBackgroundImageView setBlackViewRect:frame withIsBlur:YES];
    
    self.lblSignUp.font = [Common getFontWithFamilyName:BariolLight withFontSize:70];
    self.lblFreeSpace.font = [Common getFontWithFamilyName:BariolLight withFontSize:48];
    
    self.btnSignIn.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:36];
    self.btnTwitter.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
    self.btnFacebook.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
    self.btnEmail.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
    
    self.lblFreeSpace.text = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"freeText", nil), g_freeSpace, NSLocalizedString(@"nowLabel", nil)];
}

#pragma mark - Facebook Integration

- (IBAction)connectToFacebook:(id)sender {
    [self connectFacebook];
}

- (void)connectFacebook {
    
    // Facebook account store
    self.mAccountStore = [[ACAccountStore alloc] init];
    ACAccountType *FBaccountType= [self.mAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    // Set application id
    NSDictionary *dictFB = [NSDictionary dictionaryWithObjectsAndKeys:FACEBOOK_KEY,ACFacebookAppIdKey,@[@"email"],ACFacebookPermissionsKey, nil];
    
    // Access facebook from phone
    [self.mAccountStore requestAccessToAccountsWithType:FBaccountType options:dictFB completion:^(BOOL granted, NSError *e) {
         if (granted) {  // Connected successfully
             NSArray *accounts = [self.mAccountStore accountsWithAccountType:FBaccountType];
            
             //it will always be the last object with single sign on
             self.mFacebookAccount = [accounts lastObject];
        
             // Get further details
             [self getFacebookDetails];
         }
         else {         // Failed to connect

             if (e.code == 6) {         // Facebook account not configured
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to connect" message:@"Please configure facebook in device settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 });
            }
             else if (e.code == 7) {    // Permission denied
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to connect" message:@"Please allow premissions to fetch your data" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 });
            }
             
             NSLog(@"error getting permission: %@",e);
         }
     }];
}

- (void)getFacebookDetails {
    
    NSURL *requestURL = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:requestURL parameters:nil];
    request.account = self.mFacebookAccount;
    
    [request performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        
        if(!error)
        {
            
            NSDictionary *list =[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            NSLog(@"Dictionary contains: %@", list );
            
            NSLog(@"global mail ID : %@",[NSString stringWithFormat:@"%@",[list objectForKey:@"email"]]);
            NSLog(@"facebook name %@",[NSString stringWithFormat:@"%@",[list objectForKey:@"name"]]);
            
            if([list objectForKey:@"error"]!=nil) {
                [self attemptRenewCredentials];
            }
            dispatch_async(dispatch_get_main_queue(),^{
                ShareOptionVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareOptionVC"];
                [self.navigationController pushViewController:vc animated:YES];
            });
        }
        else {
            NSLog(@"error from get%@",error);
            //attempt to revalidate credentials
        }
    }];
}

- (void)accountChanged:(NSNotification *)notification {
    [self attemptRenewCredentials];
}

- (void)attemptRenewCredentials {
    [self.mAccountStore renewCredentialsForAccount:(ACAccount *)self.mFacebookAccount completion:^(ACAccountCredentialRenewResult renewResult, NSError *error){
        if(!error)
        {
            switch (renewResult) {
                case ACAccountCredentialRenewResultRenewed:
                    NSLog(@"Good to go");
                    [self getFacebookDetails];
                    break;
                case ACAccountCredentialRenewResultRejected:
                    NSLog(@"User declined permission");
                    break;
                case ACAccountCredentialRenewResultFailed:
                    NSLog(@"non-user-initiated cancel, you may attempt to retry");
                    break;
                default:
                    break;
            }
            
        }
        else{
            //handle error gracefully
            NSLog(@"error from renew credentials%@",error);
        }
    }];
}



#pragma mark - Twitter Login

- (IBAction)connectToTwitter:(id)sender
{
    
}


#pragma mark - Sign Up 

- (IBAction)signUpUser:(id)sender {
    SignUpVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpVC"];
    //vc._spaceFreed = self._spaceFreed;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Back 

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
    //HomeVC *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
    //[self.navigationController pushViewController:homeVC animated:NO];
    
}

- (IBAction)onSignIn:(id)sender
{
    
    LoginVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    //vc._spaceFreed = self._spaceFreed;
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
