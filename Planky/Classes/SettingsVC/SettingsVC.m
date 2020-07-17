//
//  SettingsVC.m
//  Planky
//
//  Created by CanvasM on 02/11/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import "Common.h"
#import "SettingsVC.h"
#import "AccountInfoVC.h"
#import "TermsPrivacyViewController.h"
#import "HelpVC.h"
#import "EditPasswordVC.h"
#import "SharedWebCaller.h"
#import "CouchbaseEvents.h"
#import "AppDelegate.h"
#import "HomeVC.h"

#define kRowHeight      86
#define kSectionHeight  90

@interface SettingsVC () <UITextFieldDelegate>
{
    BOOL mIsEditing;
}
// IBOutlets
@property (nonatomic, weak) IBOutlet UITableView*           mTableView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint   *mBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint   *mEditingBarHeightConstraint;
@property (strong, nonatomic) IBOutlet UILabel              *mEditingTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton             *mCancelButton;
@property (strong, nonatomic) IBOutlet UIButton             *mSaveButton;

@property (strong, nonatomic) IBOutlet UILabel              *mViewTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton             *mLogoutButton;

// name and email textField
@property (nonatomic, strong) UITextField                   *mNameTextField;
@property (nonatomic, strong) UITextField                   *mEmailTextField;

// Other objects
@property (nonatomic, strong) NSMutableArray*               mSettingsArray;

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mIsEditing = NO;
    self.mEditingBarHeightConstraint.constant = 0.0f;
    
    [self initializeViews];
    [self loadSettingsArray];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // [self addTableFooterView];
}

- (void) initializeViews
{
    self.mViewTitleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
    self.mLogoutButton.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:40];
    
    self.mEditingTitleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
    self.mSaveButton.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:36];
    self.mCancelButton.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:36];
}

- (void)loadSettingsArray
{
    
    self.mSettingsArray = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *sectionDict = [[NSMutableDictionary alloc] init];
    
    // Section 1  ---------------------------------------
    // Section Title
    [sectionDict setObject:@"ACCOUNT" forKey:@"title"];

    // User Name
    NSMutableDictionary *nameDict = [[NSMutableDictionary alloc] init];
    [nameDict setObject:@"Name" forKey:@"title"];
    [nameDict setObject:[NSString stringWithFormat:@"%@ %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"firstName"], [[NSUserDefaults standardUserDefaults] objectForKey:@"lastName"]] forKey:@"valueKey"];
    [nameDict setObject:@"NO" forKey:@"hasDetails"];
    
    // Email
    NSMutableDictionary *emailDict = [[NSMutableDictionary alloc] init];
    [emailDict setObject:@"Email" forKey:@"title"];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"email"])
        [emailDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"] forKey:@"valueKey"];
    [emailDict setObject:@"NO" forKey:@"hasDetails"];
    
    // Password
    NSMutableDictionary *passwordDict = [[NSMutableDictionary alloc] init];
    [passwordDict setObject:@"Password" forKey:@"title"];
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"password"])
//        [passwordDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"] forKey:@"valueKey"];
    [passwordDict setObject:@"YES" forKey:@"hasDetails"];
    
    
    // Cloud Connect
    NSMutableDictionary *cloudDict = [[NSMutableDictionary alloc] init];
    [cloudDict setObject:@"Cloud Connected" forKey:@"title"];
    NSString *strCloudConnected = [[NSUserDefaults standardUserDefaults] objectForKey:@"cloudConnected"];
    if (strCloudConnected == nil) {
        strCloudConnected = @"Dropbox";
    }
    [cloudDict setObject:strCloudConnected forKey:@"valueKey"];
    [cloudDict setObject:@"NO" forKey:@"hasDetails"];
    
    // Photos
    NSMutableDictionary *photosDict = [[NSMutableDictionary alloc] init];
    [photosDict setObject:@"Photos" forKey:@"title"];
    [photosDict setObject:[NSString stringWithFormat:@"%@ / %@GB freed", [[NSUserDefaults standardUserDefaults] objectForKey:@"photos"], [[NSUserDefaults standardUserDefaults] objectForKey:@"memory"]] forKey:@"valueKey"];
    [photosDict setObject:@"NO" forKey:@"hasDetails"];

    // Progress
    NSMutableDictionary *progressDict = [[NSMutableDictionary alloc] init];
    [progressDict setObject:@"Progress" forKey:@"title"];
    [progressDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"progress"] forKey:@"valueKey"];
    [progressDict setObject:@"NO" forKey:@"hasDetails"];
    [progressDict setObject:@"YES" forKey:@"hasSwitch"];
    
    // Plan
//    NSMutableDictionary *planDict = [[NSMutableDictionary alloc] init];
//    [planDict setObject:@"Plan" forKey:@"title"];
//    [planDict setObject:@"Free" forKey:@"valueKey"];
//    [planDict setObject:@"NO" forKey:@"hasDetails"];
    
    [sectionDict setObject:@[nameDict, emailDict, passwordDict, cloudDict, photosDict, progressDict] forKey:@"itemsArray"];
    [self.mSettingsArray addObject:sectionDict];
    
    // Section 2  --------------------------------------
    sectionDict = [[NSMutableDictionary alloc] init];
    [sectionDict setObject:@"EXTRAS" forKey:@"title"];

    // Help
    NSMutableDictionary *helpDict = [[NSMutableDictionary alloc] init];
    [helpDict setObject:@"Help" forKey:@"title"];
    [helpDict setObject:@"YES" forKey:@"hasDetails"];

    // Terms & Privacy
    NSMutableDictionary *termsDict = [[NSMutableDictionary alloc] init];
    [termsDict setObject:@"Terms & Privacy" forKey:@"title"];
    [termsDict setObject:@"YES" forKey:@"hasDetails"];
    
    // App Version
    NSMutableDictionary *versionDict = [[NSMutableDictionary alloc] init];
    [versionDict setObject:@"App Version" forKey:@"title"];
    [versionDict setObject:@"1.0" forKey:@"valueKey"];

    [sectionDict setObject:@[helpDict, termsDict, versionDict] forKey:@"itemsArray"];
    [self.mSettingsArray addObject:sectionDict];

}


#pragma mark - Slide Left Button

- (IBAction)slideLeftButtonClicked:(id)sender {
    //[[SlideNavigationController sharedInstance] bounceMenu:MenuLeft withCompletion:nil];
    [[SlideNavigationController sharedInstance] openMenu:MenuLeft withCompletion:nil];
}


#pragma mark - SlideNavigationController Methods

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}


#pragma mark - UITableView Cell Delegate And Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.mSettingsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return kSectionHeight * screenSize.height / 1334.0f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kSectionHeight * screenSize.height / 1334.0f)];
    sectionHeader.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:241/255.0 alpha:1.0];
    
    // Header label
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(30 * screenSize.width / 750.0f, 50 * screenSize.height / 1334.0f, sectionHeader.frame.size.width, (kSectionHeight-54)*screenSize.height / 1334.0f)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:128/255.0f green:129/255.0f blue:132/255.0f alpha:1.0f];
    headerLabel.text = [[self.mSettingsArray objectAtIndex:section] objectForKey:@"title"];
    headerLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:36.0f];
    [sectionHeader addSubview:headerLabel];
    
    return sectionHeader;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.mSettingsArray objectAtIndex:section] objectForKey:@"itemsArray"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return kRowHeight * screenSize.height / 1334.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // remove previous view
    for (id view in cell.contentView.subviews)
        [view removeFromSuperview];
    
    NSDictionary *dict = [[[self.mSettingsArray objectAtIndex:indexPath.section] objectForKey:@"itemsArray"] objectAtIndex:indexPath.row];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    float offsetX = 30 * screenSize.width / 750.0f;
    float offsetY = 0;
    float width = 300 * screenSize.width / 750.0f;
    float height = kRowHeight * screenSize.height / 1334.0f;
    
    // Cell title label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, offsetY, width, height)];
    titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:36.0f];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = [dict objectForKey:@"title"];
    [cell.contentView addSubview:titleLabel];
    
    // Disclosure indicator
    if ([[dict objectForKey:@"hasDetails"] boolValue]) {        // Show details disclosure
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if ([dict objectForKey:@"hasSwitch"]) {
        UISwitch *tSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 70, 6 * screenSize.height / 1334.0f, 116 * screenSize.width / 750.0f, 64 * screenSize.height / 1334.0f)];
        CGRect switchRect = tSwitch.bounds;
        switchRect.origin.x = screenSize.width - switchRect.size.width - 30 * screenSize.width / 750.0f;
        switchRect.origin.y = (kRowHeight * screenSize.height / 1334.0f - switchRect.size.height) / 2.0f;
        tSwitch.frame = switchRect;
        tSwitch.on = YES;
        [cell.contentView addSubview:tSwitch];
    }
    else {
        // Details value label
        if ([dict objectForKey:@"valueKey"])
        {
            offsetX = 250 * screenSize.width / 750.0f;
            offsetY = 0;
            width = 470 * screenSize.width /750.0f;
            height = kRowHeight * screenSize.height / 1334.0f;
            
            if (indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1))
            {
                UITextField *detailsText = [[UITextField alloc] initWithFrame:CGRectMake(offsetX, offsetY, width, height)];
                detailsText.font = [Common getFontWithFamilyName:BariolRegular withFontSize:36.0f];
                detailsText.backgroundColor = [UIColor clearColor];
                detailsText.textAlignment = NSTextAlignmentRight;
                detailsText.textColor = [UIColor colorWithRed:41/255.0f green:148/255.0f blue:188/255.0f alpha:1.0f];
                detailsText.text = [dict objectForKey:@"valueKey"];
                detailsText.delegate = self;
               
                if (indexPath.row == 0)
                {
                    self.mNameTextField = detailsText;
                }
                else if (indexPath.row == 1)
                {
                    self.mEmailTextField = detailsText;
                }
                [cell.contentView addSubview:detailsText];
            }
            else
            {
                UILabel *detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, offsetY, width, height)];
                detailsLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:36.0f];
                detailsLabel.backgroundColor = [UIColor clearColor];
                detailsLabel.textAlignment = NSTextAlignmentRight;
                detailsLabel.textColor = [UIColor colorWithRed:41/255.0f green:148/255.0f blue:188/255.0f alpha:1.0f];
                detailsLabel.text = [dict objectForKey:@"valueKey"];
                [cell.contentView addSubview:detailsLabel];
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (mIsEditing) {
        return;
    }
    
    if (indexPath.section == 0)
    {
        // Edit password
        if (indexPath.row == 2)
        {
            EditPasswordVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPasswordVC"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    if (indexPath.section == 1)
    {
        switch (indexPath.row)
        {
            case 0:
                // help
                {
                    HelpVC *helpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpVC"];
                    [self.navigationController pushViewController:helpVC animated:YES];
                }
                break;
            case 1:
                // terms and privacy
                {
                    TermsPrivacyViewController *termsPrivacyController = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsPrivacyController"];
                    [self.navigationController pushViewController:termsPrivacyController animated:YES];
                }
                break;
            default:
                break;
        }
    }

}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{

    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    mIsEditing = YES;
    
    [UIView animateWithDuration:2.0f animations:^{
        self.mEditingBarHeightConstraint.constant = 130 * screenSize.height / 1334.0f;
    }];
    
    if ([textField isEqual:self.mNameTextField])
    {
        self.mEditingTitleLabel.text = @"Edit Name";
    }else if ([textField isEqual:self.mEmailTextField])
        self.mEditingTitleLabel.text = @"Edit Email";
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    //[self setEditStatus:YES];
    
    [textField resignFirstResponder];
    
    [UIView animateWithDuration:0.5f animations:^{
        self.mBottomConstraint.constant = 0;
    }];
    return YES;
}

-(void)keyboardDidShow:(NSNotification*)aNotification
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.5f animations:^{
        self.mBottomConstraint.constant = keyboardSize.height - 150 * screenSize.height / 1334.0f;
    }];
    
}

-(void)keyboardDidHide:(NSNotification*)aNotification
{
    [UIView animateWithDuration:0.5f animations:^{
        self.mBottomConstraint.constant = 0.0f;
    }];
}

#pragma mark - cancel and save button

- (IBAction)onCancel:(id)sender
{
    [UIView animateWithDuration:0.5f animations:^{
        self.mEditingBarHeightConstraint.constant = 0.0f;
        self.mBottomConstraint.constant = 0.0f;
    }];
    
    if (self.mNameTextField)
        [self.mNameTextField resignFirstResponder];
    
    if (self.mEmailTextField)
        [self.mEmailTextField resignFirstResponder];
    
    NSDictionary *dict = [[[self.mSettingsArray objectAtIndex:0] objectForKey:@"itemsArray"] objectAtIndex:0];
    self.mNameTextField.text = [dict objectForKey:@"valueKey"];
    dict = [[[self.mSettingsArray objectAtIndex:0] objectForKey:@"itemsArray"] objectAtIndex:1];
    self.mEmailTextField.text = [dict objectForKey:@"valueKey"];
    
    mIsEditing = NO;
}

- (IBAction)onSave:(id)sender
{
    [UIView animateWithDuration:0.5f animations:^{
        self.mEditingBarHeightConstraint.constant = 0.0f;
        self.mBottomConstraint.constant = 0.0f;
    }];
    
    if (self.mNameTextField)
        [self.mNameTextField resignFirstResponder];
    
    if (self.mEmailTextField)
        [self.mEmailTextField resignFirstResponder];
    
    mIsEditing = NO;
}

- (IBAction)onSignOut:(id)sender
{
    if (mIsEditing)
        return;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showProgressViewOnView:self.view];
    
    // sign out
    [[SharedWebCaller sharedManager] logoutWithCompletionHandler:^(NSMutableDictionary *responseDic, NSError *error)
    {
        CouchbaseEvents *event = [[CouchbaseEvents alloc] init];
        [event logout];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"firstName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"email"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate hideProgressViewFromView:self.view];
        
        [self.navigationController popViewControllerAnimated:YES];
        HomeVC *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
        [self.navigationController pushViewController:homeVC animated:NO];
        
    } withFailureHandler:^(NSMutableDictionary *failureDict, NSError *error)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate hideProgressViewFromView:self.view];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to login" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}


@end
