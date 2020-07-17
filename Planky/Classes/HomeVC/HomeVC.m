//
//  ViewController.m
//  Planky
//
//  Created by Neelesh Aggarwal on 30/10/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import "Common.h"
#import "HomeVC.h"
#import "PieChatView.h"
#import "Pie.h"
#import "ViewLayerModifier.h"
#import "DropBox.h"
#import "ImageHandler.h"
#import "LoginSelectionVC.h"
#import "RandomImageProvider.h"



#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define WHITE_CIRCLE_TAG            -100

@interface HomeVC () <DropboxDelegate, PieChatDelegate>

@property (strong, nonatomic) IBOutlet CustomImageView*  mBackgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel*            mAnalysingLabel;

@property (nonatomic, weak) IBOutlet UILabel*            mDontWorryLabel;

@property (nonatomic, weak) IBOutlet UILabel*            mBeforeTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel*            mAfterTitleLabel;

@property (nonatomic, weak) IBOutlet PieChatView*        mArcView;
@property (nonatomic, weak) IBOutlet UILabel*            mPhotosLabel;                  // Total Photos count label

@property (nonatomic, weak) IBOutlet UIButton*           mFreeSpaceButton;              // Sign up button

@property (nonatomic, weak) IBOutlet UIView*             mBeforeView;      // Before background view
@property (nonatomic, weak) IBOutlet UIView*             mAfterView;      // Before background view

@property (nonatomic, weak) IBOutlet UILabel             *mBeforeLabel;
@property (nonatomic, weak) IBOutlet UILabel             *mBeforeUnit;
@property (nonatomic, weak) IBOutlet UILabel             *mAfterLabel;
@property (nonatomic, weak) IBOutlet UILabel             *mAfterUnit;

@property (nonatomic, assign) CGFloat                    mOriginalSize, mModifiedSize;
@property (nonatomic, assign) CGFloat                    mArcSliceValue, mWhiteArcAngle;

@property (nonatomic, assign) NSInteger                  mAssetCount, mMomentCount, mTotalCount, mTotalImageCountForArc, mTotalAssetsInFolder;

@property (nonatomic, strong) PHImageManager*           imageManager;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self initFonts];
    
    // Hide sign up button and info label
    self.mFreeSpaceButton.hidden = YES;
    
    self.mDontWorryLabel.hidden = NO;
    self.mAnalysingLabel.hidden = NO;
    
    self.mBeforeView.hidden = YES;
    self.mAfterView.hidden = YES;
    
    [self setPhotosCountLabelCount:0000];
   
    self.mTotalImageCountForArc = self.mTotalImageCountForArc = self.mTotalAssetsInFolder = 0;
    self.mMomentCount = self.mTotalCount = 0;
    
    [self drawBaseArc];
    [self getPhotosFromPhotoLibrary];
}

-(void) initFonts
{
    self.mDontWorryLabel.font = [Common getFontWithFamilyName:BariolLight withFontSize:70.0f];
    self.mAnalysingLabel.font = [Common getFontWithFamilyName:BariolLight withFontSize:48.0f];
    self.mBeforeTitleLabel.font = [Common getFontWithFamilyName:BariolLight withFontSize:45];
    self.mAfterTitleLabel.font = [Common getFontWithFamilyName:BariolLight withFontSize:45];
    self.mFreeSpaceButton.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
    self.mBeforeLabel.font = [Common getFontWithFamilyName:BariolLight withFontSize:75];
    self.mAfterLabel.font = [Common getFontWithFamilyName:BariolLight withFontSize:75];
    self.mBeforeUnit.font = [Common getFontWithFamilyName:BariolLight withFontSize:45.0f];
    self.mAfterUnit.font = [Common getFontWithFamilyName:BariolLight withFontSize:45.0f];

    // set imageview's frame
    CGRect frame = [UIScreen mainScreen].bounds;
    [self.mBackgroundImageView setBlackViewRect:frame withIsBlur:NO];
}

- (void)rotatePieChartView {
    self.mArcView.transform = CGAffineTransformMakeRotation(M_PI_2);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (void)initializeView
{
    // Localized values
    self.mDontWorryLabel.text = NSLocalizedString(@"HomeDontWorryLabelTitle", nil);
    self.mAnalysingLabel.text = NSLocalizedString(@"HomeAnalyseLabelTitle", nil);
    self.mBeforeTitleLabel.text = NSLocalizedString(@"HomeBeforeLabelTitle", nil);
    self.mAfterTitleLabel.text = NSLocalizedString(@"HomeAfterLabelTitle", nil);
    
    [self.mFreeSpaceButton setTitle:NSLocalizedString(@"HomeFreeSpaceButtonTitle", nil) forState:UIControlStateNormal];
}


#pragma mark - Photos Count Label

- (void)setPhotosCountLabelCount:(NSInteger)count
{
    // Set text for photos label

    int percent = (float)count / (float)self.mTotalImageCountForArc * 100;
    if (self.mTotalImageCountForArc == 0)
        percent = 0;
    
    UIFont *font1 = [Common getFontWithFamilyName:BariolLight withFontSize:120];
    NSDictionary *arialDict = [NSDictionary dictionaryWithObject:font1 forKey:NSFontAttributeName];
    NSString *strPercent = [NSString stringWithFormat:@"%d", percent];
    NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:strPercent attributes: arialDict];
    
    UIFont *font2 = [Common getFontWithFamilyName:BariolLight withFontSize:72];
    NSDictionary *arialDict2 = @{NSFontAttributeName:font2};
    NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:@"%\n" attributes: arialDict2];
    [aAttrString1 appendAttributedString:aAttrString2];
    
    UIFont *font3 = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
    NSDictionary *arialDict3 = @{NSFontAttributeName: font3, NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.3f]};
    NSMutableAttributedString *aAttrString3 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld photos", (long)count] attributes: arialDict3];
    
    [aAttrString1 appendAttributedString:aAttrString3];
    self.mPhotosLabel.attributedText = aAttrString1;
}


#pragma mark - Get Photos

- (void)getPhotosFromPhotoLibrary {
    
    // Initialize arc angles
    self.mArcSliceValue = 0.0;
    self.mWhiteArcAngle = -90.0;
    
    PHFetchResult * moments = [PHAssetCollection fetchMomentsWithOptions:nil];
    
    // Get photos count
    for (PHAssetCollection *asset in moments)
    {
        PHFetchResult *assetsInCollection = [PHAsset fetchAssetsInAssetCollection:asset options:nil];
        for (PHAsset *asset in assetsInCollection)
        {
            if (asset.mediaType == PHAssetMediaTypeImage)
                self.mTotalImageCountForArc++;
        }
    }
    
    
    // Get value for arc slice
    self.mArcSliceValue = 360.0f/self.mTotalImageCountForArc;
    
    if (moments.count > 0)
        [self fetchMomentsForAssetCollection:moments];
    
    NSLog(@"Total Size: %f", self.mOriginalSize);
}

- (void)fetchMomentsForAssetCollection:(PHFetchResult *)moments {
    
    PHFetchResult * assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:[moments objectAtIndex:self.mMomentCount] options:nil];
    
    // Start
    if ([assetsFetchResults count] > 0) {
        self.mAssetCount = 0;
        
        [self fetchAssetForAssetFetchResult:assetsFetchResults andMoments:moments];
    }
    
}


- (void)fetchAssetForAssetFetchResult:(PHFetchResult *)assetFetchResult andMoments:(PHFetchResult *)moments {
    
    // Start Next moment load if images are fetched
    if (!assetFetchResult)
    {
        if (moments.count-1 > self.mMomentCount) {
            self.mMomentCount++;
            [self fetchMomentsForAssetCollection:moments];
            
        }
        else {
            [self updateDetailsOnUI];
            [self imageAnalysisEnded];
            return;
        }
    }
    
    
    self.mTotalAssetsInFolder = assetFetchResult.count;
    
    // Update UI according to moment load
    [self updateDetailsOnUI];
    
    [[PHImageManager defaultManager] requestImageDataForAsset:[assetFetchResult objectAtIndex:self.mAssetCount] options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {

        PHAsset *asset = [assetFetchResult objectAtIndex:self.mAssetCount];

        if (asset.mediaType == PHAssetMediaTypeImage) {
            
            // Incrase size only if image is located
            self.mTotalCount += 1;     // Update total images count
            
            float imageSize = imageData.length;
            
            //convert to Megabytes
            imageSize = imageSize/(1024*1024);
            self.mOriginalSize += imageSize;
            
            // Get modified image
            UIImage *modifiedImage = [self imageWithImage:[UIImage imageWithData:imageData] scaledToWidth:1000];
            NSData *modifiedData = UIImageJPEGRepresentation(modifiedImage, 0.25);
            float modifiedLength = modifiedData.length;
            self.mModifiedSize += modifiedLength/(1024*1024);
            
            // Update white arc angle
            if (self.mWhiteArcAngle < 360)
                self.mWhiteArcAngle += self.mArcSliceValue;
            
            [ImageHandler saveImage:modifiedImage withId:[asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""] inFolder:@"Image"];

        }
        
        if (self.mAssetCount < assetFetchResult.count - 1) {      // Start recusrsion to call collect other images
            
            self.mAssetCount++;
            [self performSelector:@selector(fetchAssetForAssetFetchResult:andMoments:) withObject:assetFetchResult withObject:moments];
        }
        else {
            [self performSelector:@selector(fetchAssetForAssetFetchResult:andMoments:) withObject:nil withObject:moments];
        }
    }];
}


- (void)updateDetailsOnUI
{
    [self setPhotosCountLabelCount:self.mTotalCount];

    // Original Size
    if (self.mOriginalSize > 1000) {        //  GB
        self.mBeforeLabel.text = [NSString stringWithFormat:@"%.2f", self.mOriginalSize/1024.0];
        self.mBeforeUnit.text = @"GB";
    }
    else {              // MB
        self.mBeforeLabel.text = [NSString stringWithFormat:@"%.3f", self.mOriginalSize / 1024.0f];
        self.mBeforeUnit.text = @"GB";
    }
    
    // Modified Size
    if (self.mModifiedSize > 1000) {        //  GB
        self.mAfterLabel.text = [NSString stringWithFormat:@"%.2f", self.mModifiedSize/1024.0];
        self.mAfterUnit.text = @"GB";
    }
    else {              // MB
        self.mAfterLabel.text = [NSString stringWithFormat:@"%.3f", self.mModifiedSize / 1024.0f];
        self.mAfterUnit.text = @"GB";
    }
    
    if (self.mWhiteArcAngle <= 360.0)
        [self drawArcTillAngel:self.mWhiteArcAngle];
    else
        [self drawArcTillAngel:360.0];
}


#pragma mark - Image Analysis ended

- (void)imageAnalysisEnded {
    
    // Unhide sign up button and info label
    self.mFreeSpaceButton.hidden = NO;
    self.mDontWorryLabel.hidden = YES;
    self.mAnalysingLabel.hidden = YES;
    
    // Hide analysis label
    self.mBeforeView.hidden = NO;
    self.mAfterView.hidden = NO;
    
    [self.mBackgroundImageView setBlur:YES];
    
    [self showFreeSpace];
    
    // save original/
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%.3f", self.mOriginalSize/1024.0f] forKey:@"memory"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%.3f", self.mModifiedSize/1024.0f] forKey:@"photos"];
    
    // Reload images array
    [[RandomImageProvider sharedManager] reloadImagesArray];
}

- (void)showFreeSpace
{
    float angle = self.mModifiedSize / self.mOriginalSize * 360 - 90;
    [self drawArcTillAngel:angle];
    
    Pie *pie = (Pie *)self.mArcView.pieCharts[0];
    pie.strokeColor = [UIColor colorWithRed:36/255.0f green:158/255.0f blue:74/255.0f alpha:1.0f];
    
    Pie *greyArc = (Pie*)self.mArcView.pieCharts[1];
    //greyArc.strokeColor = [UIColor colorWithRed:36/255.0f green:158/255.0f blue:74/255.0f alpha:1.0f];
    greyArc.strokeColor = [UIColor colorWithRed:244/255.0f green:0 blue:81/255.0f alpha:1.0f];
    
    // green small circle...
    CGFloat circleHeight = 14;
    UIView *firstCircle = [self.mArcView viewWithTag:WHITE_CIRCLE_TAG];
    firstCircle.backgroundColor = [UIColor colorWithRed:36/255.0f green:158/255.0f blue:74/255.0f alpha:1.0f];
    [ViewLayerModifier addBorderToView:firstCircle width:2.0 color:[UIColor colorWithRed:36/255.0f green:158/255.0f blue:74/255.0f alpha:1.0f] andCornerRadius:circleHeight/2.0];
    [self.mArcView setNeedsDisplay];
    
    // red small circle...
    UIView *greenCircle = [[UIView alloc] initWithFrame:CGRectMake(self.mArcView.frame.size.width/2.0 - circleHeight/2.0, self.mArcView.frame.size.height/2.0 - greyArc.radius - circleHeight/2.0, circleHeight, circleHeight)];
    greenCircle.backgroundColor = [UIColor colorWithRed:244/255.0f green:0 blue:81/255.0f alpha:1.0f];
    [ViewLayerModifier addBorderToView:greenCircle width:2.0 color:[UIColor colorWithRed:244/255.0f green:0 blue:81/255.0f alpha:1.0f] andCornerRadius:circleHeight/2.0];
    [self.mArcView addSubview:greenCircle];

    
    // Set text for photos label
    NSMutableAttributedString *aAttrString;
    
    float freeSpace = self.mOriginalSize - self.mModifiedSize;
    if (freeSpace > 1000)
    {
        UIFont *font1 = [Common getFontWithFamilyName:BariolLight withFontSize:120];
        NSDictionary *arialDict = [NSDictionary dictionaryWithObject:font1 forKey:NSFontAttributeName];
        NSString *strFreeSpace = [NSString stringWithFormat:@"%.2f", freeSpace / 1024.0f];
        aAttrString = [[NSMutableAttributedString alloc] initWithString:strFreeSpace attributes: arialDict];
        
        UIFont *font2 = [Common getFontWithFamilyName:BariolLight withFontSize:72];
        NSDictionary *arialDict2 = @{NSFontAttributeName:font2};
        NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:@"GB\n" attributes: arialDict2];
        [aAttrString appendAttributedString:aAttrString2];
        
    }
    else
    {
        UIFont *font1 = [Common getFontWithFamilyName:BariolLight withFontSize:120];
        NSDictionary *arialDict = [NSDictionary dictionaryWithObject:font1 forKey:NSFontAttributeName];
        NSString *strFreeSpace = [NSString stringWithFormat:@"%.3f", freeSpace/1024.0f];
        aAttrString = [[NSMutableAttributedString alloc] initWithString:strFreeSpace attributes: arialDict];
        
        UIFont *font2 = [Common getFontWithFamilyName:BariolLight withFontSize:72];
        NSDictionary *arialDict2 = @{NSFontAttributeName:font2};
        NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:@"GB\n" attributes: arialDict2];
        [aAttrString appendAttributedString:aAttrString2];
    }
    
    UIFont *font3 = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
    NSDictionary *arialDict3 = @{NSFontAttributeName: font3, NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.3f]};
    NSMutableAttributedString *aAttrString3 = [[NSMutableAttributedString alloc] initWithString:@"Ready to be freed" attributes: arialDict3];
    
    [aAttrString appendAttributedString:aAttrString3];
    self.mPhotosLabel.attributedText = aAttrString;
    
    
}

#pragma mark - Draw Arc

- (void)drawBaseArc {
    Pie *pie = [[Pie alloc] init];
    pie.startAngle = 0;
    pie.endAngle = 360;
    pie.arcWidth = 8.0;
    pie.radius = self.mArcView.frame.size.width > self.mArcView.frame.size.height ? self.mArcView.frame.size.height/2.0 - pie.arcWidth : self.mArcView.frame.size.width/2.0 - pie.arcWidth;
    pie.strokeColor = [UIColor darkGrayColor];
    pie.isClockWise = YES;
    
    
    // White small circle
    CGFloat circleHeight = 14;
    UIView *whiteCircle = [[UIView alloc] initWithFrame:CGRectMake(self.mArcView.frame.size.width/2.0 - circleHeight/2.0, self.mArcView.frame.size.height/2.0 - pie.radius - circleHeight/2.0, circleHeight, circleHeight)];
    whiteCircle.tag = WHITE_CIRCLE_TAG;
    whiteCircle.backgroundColor = [UIColor colorWithRed:244/255.0f green:0 blue:81/255.0f alpha:1.0f];
    [ViewLayerModifier addBorderToView:whiteCircle width:2.0 color:[UIColor colorWithRed:244/255.0f green:0 blue:81/255.0f alpha:1.0f] andCornerRadius:circleHeight/2.0];
    [self.mArcView addSubview:whiteCircle];

    self.mArcView.pieCharts = [NSMutableArray arrayWithArray:@[pie]];
    self.mArcView.delegate = self;
    [self.mArcView setNeedsDisplay];
}

- (void)drawArcTillAngel:(CGFloat)angle {
    // White Arc
    Pie *pie = [[Pie alloc] init];
    pie.startAngle = -90;
    pie.endAngle = angle;
    pie.arcWidth = 8.0;
    pie.radius = self.mArcView.frame.size.width > self.mArcView.frame.size.height ? self.mArcView.frame.size.height/2.0-pie.arcWidth : self.mArcView.frame.size.width/2.0-pie.arcWidth;
    pie.strokeColor = [UIColor colorWithRed:244/255.0f green:0 blue:81/255.0f alpha:1.0f];
    pie.isClockWise = YES;
    
    // Grey Arc
    Pie *greyArc = [[Pie alloc] init];
    greyArc.startAngle = angle;
    greyArc.endAngle = 360-90;
    greyArc.arcWidth = 8.0;
    greyArc.radius = self.mArcView.frame.size.width > self.mArcView.frame.size.height ? self.mArcView.frame.size.height/2.0-pie.arcWidth : self.mArcView.frame.size.width/2.0-pie.arcWidth;
    greyArc.strokeColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
    greyArc.isClockWise = YES;

    
    self.mArcView.pieCharts = [NSMutableArray arrayWithArray:@[pie, greyArc]];
    self.mArcView.delegate = self;
    [self.mArcView setNeedsDisplay];
}


#pragma mark - Pie Chart Delegate Method

- (void)arcDrawFinishedAtPoint:(CGPoint)point {
    
    UIView *circleView = [self.view viewWithTag:WHITE_CIRCLE_TAG];

    circleView.center = point;
 }


#pragma mark - Sign Up And Boost

- (IBAction)signUpAndBoost:(id)sender {
    LoginSelectionVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginSelectionVC"];
    float freeSpace = self.mOriginalSize - self.mModifiedSize;
    if (freeSpace > 1000)
    {
        g_freeSpace = [NSString stringWithFormat:@"%.2f GB", freeSpace / 1024.0f];
       // vc._spaceFreed = [NSString stringWithFormat:@"%.2f GB", freeSpace / 1024.0f];
    }
    else
    {
        g_freeSpace = [NSString stringWithFormat:@"%.3f GB", freeSpace / 1024.0f];
//        vc._spaceFreed = [NSString stringWithFormat:@"%.2f MB", freeSpace];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:g_freeSpace forKey:@"freespace"];
    
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Private Methods

- (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToWidth: (float) i_width {
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
