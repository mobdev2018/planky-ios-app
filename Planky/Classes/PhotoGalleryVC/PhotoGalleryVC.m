//
//  PhotoGalleryVC.m
//  Planky
//
//  Created by Neelesh Aggarwal on 12/11/15.
//  Copyright © 2015 Neelesh Aggarwal. All rights reserved.
//

#import "Common.h"
#import "PhotoGalleryVC.h"
#import "PieChatView.h"
#import "Pie.h"
#import "ViewLayerModifier.h"
#import "DropBox.h"
#import "ImageHandler.h"
#import "CollectionSectionHeaderView.h"
#import "ShareOptionVC.h"
#import "IndexedImageView.h"
#import "JGProgressView.h"
#import "LocalImageHandler.h"
#import "SharedWebCaller.h"
#import "CouchbaseEvents.h"
#import "AppDelegate.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define cellIdentifier      @"CollectionViewCell"

@interface PhotoGalleryVC () <DropboxDelegate, UISearchBarDelegate>

// IBOutlets
    // Top view outlets
@property (nonatomic, weak) IBOutlet UILabel*            mViewTitleLabel;
@property (nonatomic, weak) IBOutlet UIButton*           mCancelButton;

//@property (nonatomic, weak) IBOutlet UISearchBar*        mSearchBar;

    // Middle view outlets
@property (nonatomic, weak) IBOutlet UICollectionView*   mPhotoCollectionView;

    // Bottom view outlets
@property (nonatomic, weak) IBOutlet UIButton*           mShareButton;
@property (nonatomic, weak) IBOutlet UIButton*           mDownloadButton;
//@property (nonatomic, weak) IBOutlet UIButton*           mTrashButton;
@property (nonatomic, weak) IBOutlet UIProgressView*     mProgressView;
@property (nonatomic, weak) IBOutlet UILabel*            mCountLabel;
@property (nonatomic, weak) IBOutlet UILabel*            mUploadingLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint*          mBottomConstraint;

@property (nonatomic, weak) IBOutlet JGProgressView*     mDownloadProgressView;

// Other objects
@property (nonatomic, assign) CGFloat                    mModifiedSize;
@property (nonatomic, assign) CGFloat                    mArcSliceValue, mWhiteArcAngle;
@property (nonatomic, assign) CGFloat                    mCurrentImageSize, mCurrentImagePixelHeight, mCurrentImagePixelWidth;

@property (nonatomic, assign) NSInteger                  mAssetCount, mMomentCount, mTotalCount, mTotalImageCountForArc, mTotalAssetsInFolder;

@property (nonatomic, strong) NSMutableArray*            mPhotosArray;
@property (nonatomic, strong) NSMutableArray*            mSelectedImageArray;

@property (nonatomic, assign) BOOL                       mIsSelectionOn, isUploadInProgress;

@property (nonatomic, strong) NSMutableArray*            mServerPhotosList;
@property (nonatomic, strong) NSDictionary*              mServerMatchedDict;

// Asset objects
@property (nonatomic, strong) PHImageManager*            imageManager;
@property (nonatomic, strong) PHFetchResult*             mCurrentMoment, *mCurrentFetchResult;
@property (nonatomic, strong) PHAsset*                   mCurrentAsset;

@end

@implementation PhotoGalleryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initializeFonts];
    
    self.mProgressView.progress = 0;
    
    // hide bottom bar
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.mBottomConstraint.constant = -124 * screenSize.height / 1334.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.mPhotosArray = [[NSMutableArray alloc] init];
    
    self.mPhotoCollectionView.backgroundColor = [UIColor clearColor];
    
    [[DropBox sharedInstance] setDropboxDelegate:self];
    if ([[DBSession sharedSession] isLinked]) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"OPEN_DROPBOX_VIEW" object:[NSNumber numberWithBool:[[DBSession sharedSession] isLinked]]]];
    }
    else {
        [[DBSession sharedSession] linkFromController:self];
        //AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        //[[DBSession sharedSession] linkFromController:(UINavigationController *)[[appDelegate window] rootViewController]];
    }
    
    [self performSelector:@selector(getImagesListFromServer) withObject:nil afterDelay:1.0];
}


- (void) initializeFonts
{
    // menu bar
    self.mViewTitleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
    self.mCancelButton.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:36];
    
    // status bar
    self.mUploadingLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:28];
    self.mCountLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:28];
    
    
}

- (void)initializeView {
    
    // Configure collection view
    [self configureCollectionView];
    
}


#pragma mark - Check Dropbox Linking - Step 2

- (void)checkFileUploadLinking {
    if (![[DBSession sharedSession] isLinked]) {
    
        ShareOptionVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareOptionVC"];
        vc._isModallyPresented = YES;
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }
    else {
        [self getPhotosFromPhotoLibrary];
        [self initializeView];
    }
}


#pragma mark - Slide Left Button

- (IBAction)slideLeftButtonClicked:(id)sender {
//    [[SlideNavigationController sharedInstance] bounceMenu:MenuLeft withCompletion:nil];
    [[SlideNavigationController sharedInstance] openMenu:MenuLeft withCompletion:nil];
}


#pragma mark - SlideNavigationController Methods

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}


#pragma mark - Get Images List From Server - Step 1

- (void)getImagesListFromServer {
    
    [[SharedWebCaller sharedManager] getImageDetailsForImageId:nil withCompletionHandler:^(NSMutableDictionary * responseDict, NSError * error) {
        // Serer returned the web service list
        if ([responseDict objectForKey:@"rows"]) {
            self.mServerPhotosList = [responseDict objectForKey:@"rows"];
            
        }
        
        // Start image fetch and upload process
        [self checkFileUploadLinking];
        
    } withFailureHandler:^(NSMutableDictionary * responseDict, NSError * error) {
        
        // Unable to get images from server
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to upload images to server" message:@"Server connection failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        // Show locally saved photos
    }];
    
}


#pragma mark - Get Photos - Step 3

- (void)getPhotosFromPhotoLibrary {
    
    // Initialize arc angles
    self.mArcSliceValue = 0.0;
    self.mWhiteArcAngle = 0.0;
    
    self.isUploadInProgress = YES;
    
    PHFetchResult * moments = [PHAssetCollection fetchMomentsWithOptions:nil];
    
    // Get photos count
    for (PHAssetCollection *asset in moments) {
        
        PHFetchResult *assetsInCollection = [PHAsset fetchAssetsInAssetCollection:asset options:nil];
        for (PHAsset *asset in assetsInCollection) {
            if (asset.mediaType == PHAssetMediaTypeImage)
                self.mTotalImageCountForArc++;
        }
    }
    
    // Get value for arc slice
    self.mArcSliceValue = 360.0/self.mTotalImageCountForArc;
    
    if (moments.count > 0)
        [self fetchMomentsForAssetCollection:moments];
}


#pragma mark - Step 3.1

- (void)fetchMomentsForAssetCollection:(PHFetchResult *)moments {
    
    if (moments.count > self.mMomentCount) {
        PHFetchResult * assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:[moments objectAtIndex:self.mMomentCount] options:nil];
        
        // Start
        if ([assetsFetchResults count] > 0) {
            self.mAssetCount = 0;
            [self fetchAssetForAssetFetchResult:assetsFetchResults andMoments:moments];
            
        }
        
        self.mMomentCount++;
        
    }
    else {
        [self imageAnalysisEnded];
        return;
    }
}


#pragma mark - Step 3.2

- (void)fetchAssetForAssetFetchResult:(PHFetchResult *)assetFetchResult andMoments:(PHFetchResult *)moments {
    
    // Start Next moment load if images are fetched
    if (!assetFetchResult) {
        if (moments.count-1 > self.mMomentCount) {
            self.mMomentCount++;
            [self fetchMomentsForAssetCollection:moments];
        }
        else {
            [self imageAnalysisEnded];
        }
    }
    
    self.mCurrentFetchResult = assetFetchResult;
    self.mCurrentMoment = moments;
    
    self.mTotalAssetsInFolder = assetFetchResult.count;
    
    // Update UI according to moment load
    
    [[PHImageManager defaultManager] requestImageDataForAsset:[assetFetchResult objectAtIndex:self.mAssetCount] options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        
        
        PHAsset *asset = [assetFetchResult objectAtIndex:self.mAssetCount];
        NSLog(@"%@", asset.localIdentifier);
        
        if (asset.mediaType == PHAssetMediaTypeImage) {
            
            // Incrase size only if image is located
            self.mTotalCount++;     // Update total images count
            
            [self uploadImage:imageData forAsset:asset andDictionary:info];
        }
        else {
            if (self.mAssetCount < self.mTotalAssetsInFolder-1) {      // Start recusrsion to call collect other images
                
                self.mAssetCount++;
                [self performSelector:@selector(fetchAssetForAssetFetchResult:andMoments:) withObject:self.mCurrentFetchResult withObject:self.mCurrentMoment];
                
            }
            else {
                [self performSelector:@selector(fetchMomentsForAssetCollection:) withObject:self.mCurrentMoment];
            }
        }
    }];
}


#pragma mark - Step 3.3

- (void)uploadImage:(NSData *)imageData forAsset:(PHAsset *)asset andDictionary:(NSDictionary *)infoDict
{
    
    self.mCurrentAsset = asset;
    
    // Check if the images exists on server
    
    // If not - Upload image
    
    // Reset progress details
    
    self.mCountLabel.text = [NSString stringWithFormat:@"%d Photos left", (unsigned)(self.mTotalImageCountForArc - self.mTotalCount)];
    self.mProgressView.progress = (float)self.mTotalCount / (float)self.mTotalImageCountForArc;
    
    UIImage *originalImage = [UIImage imageWithData:imageData];
    self.mCurrentImageSize = imageData.length;
    self.mCurrentImagePixelWidth = originalImage.size.width;
    self.mCurrentImagePixelHeight = originalImage.size.height;
    
    UIImage *modifiedImage = [self imageWithImage:originalImage scaledToWidth:300];
    
    // Save image details to image details
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    // Search array for dictionary
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date=%@", [dateFormatter stringFromDate:asset.modificationDate]];
    NSArray *filteredArray = [self.mPhotosArray filteredArrayUsingPredicate:predicate];
    NSMutableDictionary *dict;
    if (filteredArray.count > 0)
        dict = [filteredArray objectAtIndex:0];
    else {
        dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[dateFormatter stringFromDate:asset.modificationDate] forKey:@"date"];
        [self.mPhotosArray addObject:dict];
    }
    
    NSMutableArray *photosArray = [dict objectForKey:@"photos"];
    if (!photosArray)
        photosArray = [[NSMutableArray alloc] init];
    
    if (![photosArray containsObject:[asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""]])
        [photosArray addObject:[asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""]];
    
    [dict setObject:photosArray forKey:@"photos"];
    
    // Check if image Id exists on server or not
    self.mServerMatchedDict = [self getServerMatchedDictForImageId:[asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""]];
    
    // Start image procession
    if ([ImageHandler getImageForId:[asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""] fromFolder:@"Image"])
    {
        // Update UI
        [self refreshCollectionView];
        
        // Fetch next asset
        if (self.mAssetCount < self.mTotalAssetsInFolder-1) {      // Start recusrsion to call collect other images
            
            self.mAssetCount++;
            [self performSelector:@selector(fetchAssetForAssetFetchResult:andMoments:) withObject:self.mCurrentFetchResult withObject:self.mCurrentMoment];
        }
        else {
            [self performSelector:@selector(fetchMomentsForAssetCollection:) withObject:self.mCurrentMoment];
        }
        //return;
    }
   
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
//        
//        // Save image to document directory
//        [ImageHandler saveImage:modifiedImage withId:[asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""] inFolder:@"Image"];
//        [ImageHandler saveImage:[UIImage imageWithData:imageData] withId:@"Dropbox"];
//        
//        //[[DropBox sharedInstance] setDropboxDelegate:self];
//        [self performSelector:@selector(uploadWithAssets:) withObject:asset afterDelay:0.1f];
//    });
    
    @autoreleasepool
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
        
        // Save image to document directory
        [ImageHandler saveImage:modifiedImage withId:[asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""] inFolder:@"Image"];
        [ImageHandler saveImage:[UIImage imageWithData:imageData] withId:@"Dropbox"];
        
        //[[DropBox sharedInstance] setDropboxDelegate:self];
        [self performSelector:@selector(uploadWithAssets:) withObject:asset afterDelay:0.1f];
        
    }
    
}

-(void)uploadWithAssets:(PHAsset *)asset
{
    [[DropBox sharedInstance] uploadImageName:[asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""] fromImagePath:[ImageHandler getImagePathForReferenceId:@"Dropbox"] toPath:@"/Planky/"];
}


#pragma mark - Image Analysis ended

- (void)imageAnalysisEnded {
    
    self.mUploadingLabel.text = NSLocalizedString(@"Upload Complete", nil);
    
    self.isUploadInProgress = NO;
    
    [self deleteAllAssetsFromPhotoGallery];
}


#pragma mark - Dropbox Upload Delegate Methods - Step 4


// Dropbox Connection Succedded
- (void)dropboxConnectionComplete
{
    NSLog(@"Dropbox connection succedded.");
}

// Failed to Connect to Dropbox
- (void)failedToConnectToDropbox
{
    NSLog(@"Dropbox connetion faild");
}


// File upload complete
- (void)fileUploadCompleteWithId:(NSString *)fileId {
    NSLog(@"File upload complete");
    
    // Save image details locally
    NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] init];
    
    [imageDict setObject:[self.mCurrentAsset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""] forKey:@"imageId"];
    [imageDict setObject:self.mCurrentAsset.creationDate forKey:@"creDate"];
    [imageDict setObject:self.mCurrentAsset.modificationDate forKey:@"modDate"];
    [imageDict setObject:[NSString stringWithFormat:@"%f", self.mCurrentAsset.location.coordinate.latitude] forKey:@"latitude"];
    [imageDict setObject:[NSString stringWithFormat:@"%f", self.mCurrentAsset.location.coordinate.longitude] forKey:@"longitude"];
    
    [LocalImageHandler addImageDetailsToFile:imageDict isDeleted:NO];
    
    // Update UI
    [self refreshCollectionView];
    
    // upload image details to server
    if (!self.mServerMatchedDict)           // Check if image is
        [self uploadImageDetailsToCouchbaseServer];
    else {
        // Fetch next asset
        if (self.mAssetCount < self.mTotalAssetsInFolder-1) {      // Start recusrsion to call collect other images
            
            self.mAssetCount++;
            [self performSelector:@selector(fetchAssetForAssetFetchResult:andMoments:) withObject:self.mCurrentFetchResult withObject:self.mCurrentMoment];
        }
        else {
            [self performSelector:@selector(fetchAssetForAssetFetchResult:andMoments:) withObject:nil withObject:self.mCurrentMoment];
        }
    }
}

- (void)updateImageToPhotoGallery:(UIImage *)image {
    
    if ([self.mCurrentAsset canPerformEditOperation:PHAssetEditOperationContent]) {
        [self.mCurrentAsset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
            
            PHContentEditingOutput *contentEditingOutput = [[PHContentEditingOutput alloc] initWithContentEditingInput:contentEditingInput];
            NSData *outputData = UIImageJPEGRepresentation(image, 1.0);
            PHAdjustmentData *adjustmentData = [[PHAdjustmentData alloc] initWithFormatIdentifier:@"AdjustementDataIdentifier" formatVersion:@"1.0" data:nil];
            contentEditingOutput.adjustmentData = adjustmentData;
            NSError *error = nil;
        
            BOOL wrote = [outputData writeToURL:contentEditingOutput.renderedContentURL options:NSDataWritingAtomic error:&error];
            
            if (wrote)
            {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:self.mCurrentAsset];
                    request.contentEditingOutput = contentEditingOutput;
                    
                } completionHandler:^(BOOL success, NSError *error) {
                    // console output : 1
                    NSLog(@"success : %@", @(success));
                    // console output : nil
                    NSLog(@"error : %@", error);
                }];
            }
        }];
    }
}

// File upload failed
- (void)fileUploadFailedWithId:(NSString *)fileId andError:(NSDictionary *)error {
    NSLog(@"Failed to upload");
}

// File upload progress
- (void)fileUploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath {
    self.mProgressView.progress = progress;
}


#pragma mark - Delete All Assets

- (void)deleteAllAssetsFromPhotoGallery {
    
    PHFetchResult * moments = [PHAssetCollection fetchMomentsWithOptions:nil];
    
    NSMutableArray *assetToDelete = [[NSMutableArray alloc] init];              // Array to record images to be deleted
    NSArray *localDeleteList = [LocalImageHandler getAllImageIdsToDelete];
    
    // Get photos count
    for (PHAssetCollection *asset in moments) {
        
        PHFetchResult *assetsInCollection = [PHAsset fetchAssetsInAssetCollection:asset options:nil];
        for (PHAsset *asset in assetsInCollection) {
        
            // Check if image id exists in deleted list
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imageId=%@", [asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""]];
            NSArray *filteredArray = [localDeleteList filteredArrayUsingPredicate:predicate];
            
            if ([filteredArray count] > 0) {
                
                [assetToDelete addObject:asset];
                
                // Create copies of all small size assets
                [PhotoGalleryVC saveImageToCameraRoll:[ImageHandler getImageForId:[asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""] fromFolder:@"Image"] location:asset.location creDate:asset.creationDate forId:[asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""]];
            }
        }
    }
    
    // Delete all assets
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:assetToDelete];
    } completionHandler:^(BOOL success, NSError *error) {
        
        if (success) {          // Set is deleted ON for all deleted items
            [LocalImageHandler addMultipleImageIdsToFile:localDeleteList isDeleted:YES];
            
        }
        else {
            NSLog(@"Failed to delete images");
        }
    }];
    
}


#pragma mark -  Download Images

- (IBAction)downloadSelectedPhotos:(id)sender {
    
    // Check if upload is in progress
    
    if ([self initialCheckClearedBeforeDownloading]) {
        // Set hightlight image for button
        [self.mDownloadButton setImage:[UIImage imageNamed:@"download_active"] forState:UIControlStateNormal];
        self.mDownloadButton.tag = 1;
        
        // Show download started message
        self.mUploadingLabel.text = @"Downloading...";
        
        // Start download
        [self continueDownload];
    }
}

- (BOOL)initialCheckClearedBeforeDownloading {
    if (self.isUploadInProgress) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't process this request" message:@"Upload is in progress" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    // Check if user has selected any option
    if ([self.mSelectedImageArray count] == 0 || !self.mSelectedImageArray)
        return NO;
    
    // Same button clicked
    if (self.mDownloadButton.tag == 1)
        return NO;
    
    [self unselectPreviousButton];
    
    return  YES;
}

- (void)continueDownload {
    
    // Set images count to be downloaded
    self.mCountLabel.text = [NSString stringWithFormat:@"%d", (int)[self.mSelectedImageArray count]];
    
    [[DropBox sharedInstance] setDropboxDelegate:self];
    [[DropBox sharedInstance] downloadFileWithId:[self.mSelectedImageArray objectAtIndex:0] toPath:[[ImageHandler getPathForFolder:DownloadImageFolderName] stringByAppendingPathComponent:[self.mSelectedImageArray objectAtIndex:0]]];
    
    [self showDownloadProgressView];
}


#pragma mark - Dropbox Download Delegate Methods

// File download successful
- (void)fileDownloadCompleteWithId:(NSString *)fileId {
    
    // Step1 - Access image from document directory
    UIImage *image = [ImageHandler getImageForId:fileId fromFolder:DownloadImageFolderName];
    
    // Step2 - Change image in photo gallery
    [self updateImageToPhotoGallery:image];
    
    // Step3 - Delete image reference id from array
    [self.mSelectedImageArray removeObjectAtIndex:0];
    
    // Step4 - Reload collection view to remove check mark from downloaded image
    [self.mPhotoCollectionView reloadData];
    
    // Step5 - Check if more images were selected then download next image
    if ([self.mSelectedImageArray count] > 0) {
        [self continueDownload];
    }
    else {      // Image download complete
        
        // Hide download indictor
        self.mDownloadProgressView.hidden = YES;
        
        // Set message of download complete to label
        self.mUploadingLabel.text = @"Images download complete";
        self.mCountLabel.text = nil;
    }
}

- (void)uploadImageDetailsToCouchbaseServer {
    
    // Create details dictionary
    NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] init];
    
    [imageDict setObject:[self.mCurrentAsset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""] forKey:@"imageId"];
    [imageDict setObject:self.mCurrentAsset.creationDate forKey:@"creDate"];
    [imageDict setObject:self.mCurrentAsset.modificationDate forKey:@"modDate"];
    [imageDict setObject:[NSString stringWithFormat:@"%f", self.mCurrentAsset.location.coordinate.latitude] forKey:@"latitude"];
    [imageDict setObject:[NSString stringWithFormat:@"%f", self.mCurrentAsset.location.coordinate.longitude] forKey:@"longitude"];
    [imageDict setObject:[NSString stringWithFormat:@"%f", self.mCurrentImageSize] forKey:@"size"];
    [imageDict setObject:[NSString stringWithFormat:@"%f", self.mCurrentImagePixelHeight] forKey:@"pixelHeight"];
    [imageDict setObject:[NSString stringWithFormat:@"%f", self.mCurrentImagePixelWidth] forKey:@"pixelWidth"];
    
    [[SharedWebCaller sharedManager] makeSavePhotoCallWithDetails:imageDict withCompletionHandler:^(NSMutableDictionary * dict, NSError * error) {
        NSLog(@"Uploaded");
        
        // Fetch next asset
        if (self.mAssetCount < self.mTotalAssetsInFolder-1) {      // Start recusrsion to call collect other images
            
            self.mAssetCount++;
            [self performSelector:@selector(fetchAssetForAssetFetchResult:andMoments:) withObject:self.mCurrentFetchResult withObject:self.mCurrentMoment];
        }
        else {
            [self performSelector:@selector(fetchAssetForAssetFetchResult:andMoments:) withObject:nil withObject:self.mCurrentMoment];
        }
        
    } withFailureHandler:^(NSMutableDictionary * dict, NSError * error) {
        NSLog(@"Couchbase upload Failed");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to continue upload" message:@"Server connection failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show]; 
    }];

}

// File download failed
- (void)fileDownloadFailedWithId:(NSString *)file andError:(NSError *)error {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Downloading failed" message:@"Please try again latter" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    // Hide download indictor
    self.mDownloadProgressView.hidden = YES;
    
    // Set message of download complete to label
    self.mUploadingLabel.text = @"Images download failed";
    self.mCountLabel.text = nil;
}

- (void)showDownloadProgressView {
    
    // hide upload progress view
    self.mProgressView.hidden = YES;
    
    // Show download progress view
    [JGProgressView beginUpdatingSharedProgressViews];
    self.mDownloadProgressView.hidden = NO;

    [JGProgressView setSharedProgressViewStyle:UIProgressViewStyleDefault];
    [JGProgressView setSharedProgressViewAnimationSpeed:2.0];

    [JGProgressView endUpdatingSharedProgressViews];
    
    [self.mDownloadProgressView setAnimationImage:[UIImage imageNamed:@"Alternative.png"]];
    self.mDownloadProgressView.animationSpeed = 0.6;
    [self.mDownloadProgressView setIndeterminate:YES];
}


#pragma mark- collection view delegates datsources

- (void)refreshCollectionView {
    [self.mPhotoCollectionView reloadData];
}

- (void)configureCollectionView {
    
    CGFloat iconSize = self.view.frame.size.width/4.0 - 3;
    
    // Register class for cell
    [self.mPhotoCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:1.0f];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [flowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width, 50)];
    [self.mPhotoCollectionView setPagingEnabled:YES];
    
    [flowLayout setItemSize:CGSizeMake(iconSize, iconSize)];
    
    [self.mPhotoCollectionView setCollectionViewLayout:flowLayout];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.mPhotosArray count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
       
        CollectionSectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        headerView.dateLabel.font = [Common getFontWithFamilyName:BariolLight withFontSize:30];
        headerView.dateLabel.text = [[self.mPhotosArray objectAtIndex:indexPath.section] objectForKey:@"date"];
        
        return headerView;
    }
    else {
        return nil;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[self.mPhotosArray objectAtIndex:section] objectForKey:@"photos"] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Remove previuous image
    for (id view in cell.contentView.subviews)
        [view removeFromSuperview];
        
    NSDictionary *dict = [self.mPhotosArray objectAtIndex:indexPath.section];
    
    // Add Image view
    IndexedImageView *imageView = [[IndexedImageView alloc] initWithFrame:cell.contentView.frame];
    imageView.indexPath = indexPath;
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.image = [ImageHandler getImageForId:[[dict objectForKey:@"photos"] objectAtIndex:indexPath.row]fromFolder:@"Image"];
    [cell.contentView addSubview:imageView];
    
    // Add Check
    if ([self.mSelectedImageArray containsObject:[[dict objectForKey:@"photos"] objectAtIndex:indexPath.row]]) {
        
        // Add check box image
        UIImageView *checkImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        checkImage.image = [UIImage imageNamed:@"Check"];
        checkImage.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:checkImage];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat iconSize = self.view.frame.size.width/4.0 - 3;
    return CGSizeMake(iconSize, iconSize);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.mIsSelectionOn) {      // Start Selection
        
        if (!self.mSelectedImageArray)
            self.mSelectedImageArray = [[NSMutableArray alloc] init];
        
        NSString *imageIdentifier = [[[self.mPhotosArray objectAtIndex:indexPath.section] objectForKey:@"photos"] objectAtIndex:indexPath.row];
        if ([self.mSelectedImageArray containsObject:imageIdentifier])
            [self.mSelectedImageArray removeObject:imageIdentifier];
        else
            [self.mSelectedImageArray addObject:imageIdentifier];
        
        // Reload view at index path
        [collectionView reloadData];
    }
    
}


#pragma mark - Base View Action Methods

- (IBAction)shareSelectedPhotos:(id)sender {
    
    // Check if user has selected any option
    if ([self.mSelectedImageArray count] == 0 || !self.mSelectedImageArray)
        return;
    
    // Same button clicked
    if (self.mShareButton.tag == 1)
        return;
    
    [self unselectPreviousButton];

    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for (NSString *imageId in self.mSelectedImageArray) {
        [imageArray addObject:[ImageHandler getImageForId:imageId fromFolder:@"Image"]];
    }
    
    // Show activity sheet with options
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:imageArray applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
    
    // Set hightlight image for button
    [self.mShareButton setImage:[UIImage imageNamed:@"share_active"] forState:UIControlStateNormal];
    self.mShareButton.tag = 1;
}



- (void)unselectPreviousButton {

    if (self.mDownloadButton.tag == 1) {
        [self.mDownloadButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
        self.mDownloadButton.tag = 0;
    }

    if (self.mShareButton.tag == 1) {
        [self.mShareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        self.mShareButton.tag = 0;
    }
}


#pragma mark - Bottom View Action Methods

- (IBAction)cancelButtonClicked:(id)sender {
    
    self.mIsSelectionOn = NO;
    
    // Move view down
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.mBottomConstraint.constant = -124 * screenSize.height / 1334.0f;

    
    [self.mCancelButton setTitle:@"Select" forState:UIControlStateNormal];
    [self.mCancelButton addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)selectButtonClicked:(id)sender {
    
    self.mIsSelectionOn = YES;
    
    // Move view up
    self.mBottomConstraint.constant = 0;
    
    [self.mCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.mCancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - UISearchbar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}


#pragma mark - Private Methods

- (UIImage*)imageWithImage:(UIImage*) sourceImage scaledToWidth: (float) i_width {
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

+ (void)saveImageToCameraRoll:(UIImage*)image location:(CLLocation*)location creDate:(NSDate *)creDate forId:(NSString *)imageId {
    
    __block PHObjectPlaceholder *placeholderAsset = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        if (location)
            newAssetRequest.location = location;
        
        if (creDate)
            newAssetRequest.creationDate = creDate;
        
        placeholderAsset = newAssetRequest.placeholderForCreatedAsset;
    } completionHandler:^(BOOL success, NSError *error) {
        if(success){
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:imageId forKey:@"imageId"];
            [dict setObject:[placeholderAsset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""] forKey:@"thumbnailId"];
            
            [LocalImageHandler addImageDetailsToFile:dict isDeleted:NO];
            
            NSLog(@"Success");
        } else {
            NSLog(@"Failure");
        }
    }];
}

// Checks if image Id exists in server list and if yes then remove the image id from server list

- (NSDictionary *)getServerMatchedDictForImageId:(NSString *)imageId {
    
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"id=%@", imageId];
    
    NSArray *filteredArray = [self.mServerPhotosList filteredArrayUsingPredicate:idPredicate];
    
    if ([filteredArray count] > 0)
        return [filteredArray objectAtIndex:0];
    else
        return nil;
}

@end
