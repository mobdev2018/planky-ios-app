//
//  StartAnalysisVC.m
//  
//
//  Created by Neelesh Aggarwal on 30/10/15.
//
//

#import "StartAnalysisVC.h"
#import "PieChatView.h"
#import "Pie.h"
#import "ViewLayerModifier.h"
#import "HomeVC.h"
#import "Common.h"

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

@interface StartAnalysisVC ()

// IBOutlets
@property (nonatomic, weak) IBOutlet CustomImageView*    mBackgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel*            mHelloLabel, *mStartScanLabel;
@property (nonatomic, weak) IBOutlet UILabel*            mPhotosLabel;
@property (nonatomic, weak) IBOutlet PieChatView*        mArcView;
@property (nonatomic, weak) IBOutlet UIButton*           mStartScanButton;

@end

@implementation StartAnalysisVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Hide navigation bar
    self.navigationController.navigationBarHidden = YES;
    
    // Initialize view outlets
    [self initializeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self drawArc];
}

- (void)initializeView {
    
    
    // Set some initial values
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"memory"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"memory"];
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"photos"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"photos"];
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"progress"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"progress"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize]; 
    
    // Localized values
    CGRect frame = [UIScreen mainScreen].bounds;
    [self.mBackgroundImageView setBlackViewRect:frame withIsBlur:NO];
    
    self.mHelloLabel.font = [Common getFontWithFamilyName:BariolLight withFontSize:70.0f];
    self.mHelloLabel.text = NSLocalizedString(@"StartAnalysisHelloLabel", nil);
    
    self.mStartScanLabel.font = [Common getFontWithFamilyName:BariolLight withFontSize:48.0f];
    self.mStartScanLabel.text = NSLocalizedString(@"StartAnalysisStartScanLabel", nil);
    
    self.mStartScanButton.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48.0f];
    [self.mStartScanButton setTitle:NSLocalizedString(@"StartAnalysisScanButtonTitle", nil) forState:UIControlStateNormal];
    
    // Set text for photos label
    UIFont *font1 = [Common getFontWithFamilyName:BariolLight withFontSize:120.0f];
    NSDictionary *arialDict = [NSDictionary dictionaryWithObject:font1 forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:@"0" attributes: arialDict];
    
    UIFont *font2 = [Common getFontWithFamilyName:BariolLight withFontSize:72.0f];
    NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:@"%\n" attributes: arialDict2];
    [aAttrString1 appendAttributedString:aAttrString2];
    
    UIFont *font3 = [Common getFontWithFamilyName:BariolRegular withFontSize:48.0f];
    NSDictionary *arialDict3 = @{NSFontAttributeName: font3, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0f alpha:0.3f]};
    NSMutableAttributedString *aAttrString3 = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"StartAnalysis0Photos", nil) attributes: arialDict3];
    
    [aAttrString1 appendAttributedString:aAttrString3];
    self.mPhotosLabel.attributedText = aAttrString1;
    
}



#pragma mark - Draw Arc

- (void)drawArc {
    
    // Main Arc
    Pie *pie = [[Pie alloc] init];
    pie.startAngle = 0;
    pie.endAngle = 360;
    pie.arcWidth = 8.0;
    pie.radius = self.mArcView.frame.size.width > self.mArcView.frame.size.height ? self.mArcView.frame.size.height/2.0-pie.arcWidth:self.mArcView.frame.size.width/2.0-pie.arcWidth;
    pie.strokeColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3f];
    pie.isClockWise = YES;
    
//    // White small circle
//    CGFloat circleHeight = 14;
//    UIView *whiteCircle = [[UIView alloc] initWithFrame:CGRectMake(self.mArcView.frame.size.width/2.0 - circleHeight/2.0, self.mArcView.frame.size.height/2.0 - pie.radius - circleHeight/2.0, circleHeight, circleHeight)];
//    whiteCircle.backgroundColor = [UIColor whiteColor];
//    [ViewLayerModifier addBorderToView:whiteCircle width:2.0 color:[UIColor whiteColor] andCornerRadius:circleHeight/2.0];
//    [self.mArcView addSubview:whiteCircle];

    self.mArcView.pieCharts = [NSMutableArray arrayWithArray:@[pie]];
    self.mArcView.delegate = self;
    [self.mArcView setNeedsDisplay];
}


#pragma mark - Start Analysis

- (IBAction)GetPermissionForImageGallery:(id)sender {
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized: {
                [UserDefaultHandler setValue:PhotoAccessAllowed ForKey:PhotoAccessPermission];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Move user to analysis screen
                    HomeVC *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
                    
                    [self.navigationController pushViewController:homeVC animated:YES];
                });
                
                break;
            }
            case PHAuthorizationStatusRestricted: {
                [UserDefaultHandler setValue:PhotoAccessDenied ForKey:PhotoAccessPermission];
                break;
            }
            case PHAuthorizationStatusDenied: {
                [UserDefaultHandler setValue:PhotoAccessDenied ForKey:PhotoAccessPermission];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't access user photos" message:@"Please go to phone settings and switch on gallery access to move forward" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
                
                break;
            }
            default:
                break;
        }
    }];
}

@end
