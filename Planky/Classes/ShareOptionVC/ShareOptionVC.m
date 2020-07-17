//
//  ShareOptionVC.m
//  Planky
//
//  Created by CanvasM on 02/11/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import "Common.h"
#import "ShareOptionVC.h"
#import <DropboxSDK/DropboxSDK.h>
#import "DropBox.h"
#import "PhotoGalleryVC.h"

@interface ShareOptionVC () <DropboxDelegate>

@property (strong, nonatomic) IBOutlet CustomImageView *mBackgroundImageView;

@property (strong, nonatomic) IBOutlet UILabel *mLabelTitle;
@property (strong, nonatomic) IBOutlet UILabel *mLabelDescription;

@property (strong, nonatomic) IBOutlet UIButton *btnDropbox;
@property (strong, nonatomic) IBOutlet UIButton *btnGoogle;
@property (strong, nonatomic) IBOutlet UIButton *btnBox;

@end

@implementation ShareOptionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) initializeViews
{
    CGRect frame = [UIScreen mainScreen].bounds;
    [self.mBackgroundImageView setBlackViewRect:frame withIsBlur:YES];
    
    self.mLabelTitle.font = [Common getFontWithFamilyName:BariolLight withFontSize:70];
    self.mLabelDescription.font = [Common getFontWithFamilyName:BariolLight withFontSize:48];
    
    self.btnDropbox.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
    self.btnGoogle.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
    self.btnBox.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];

}


#pragma mark - button events

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)connectToDropbox:(id)sender
{
    
    // Set current controller as listner to dropbox connect
    [[DropBox sharedInstance] setDropboxDelegate:self];
    
    if ([[DBSession sharedSession] isLinked]) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"OPEN_DROPBOX_VIEW" object:[NSNumber numberWithBool:[[DBSession sharedSession] isLinked]]]];
    }
    else {
        [[DBSession sharedSession] linkFromController:self];
    }
}
- (IBAction)onGoogleDrive:(id)sender
{
    
}

- (IBAction)boxComingSoon:(id)sender {
    
}


#pragma mark - Dropbox Delegate Methods

// Dropbox Connection Succedded
- (void)dropboxConnectionComplete
{
    [[NSUserDefaults standardUserDefaults] setObject:@"Dropbox" forKey:@"cloudConnected"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self._isModallyPresented) {
        [self performSelector:@selector(dismissCurrentController) withObject:nil afterDelay:0.2];
    }
    else {
        PhotoGalleryVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoGalleryVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)dismissCurrentController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Failed to Connect to Dropbox
- (void)failedToConnectToDropbox {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to connect to dropbox" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
