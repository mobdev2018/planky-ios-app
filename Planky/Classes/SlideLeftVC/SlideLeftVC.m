//
//  SlideLeftVC.m
//  Planky
//
//  Created by CanvasM on 30/10/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import "Common.h"
#import "SlideLeftVC.h"
#import "SettingsVC.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "ShareOptionVC.h"
#import "PhotoGalleryVC.h"
#import "SlideLeftTableViewCell.h"

#define kRowHeight      160

@interface SlideLeftVC ()

// IBOutlets
@property (strong, nonatomic) IBOutlet UILabel *mViewTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *mViewDetailLabel;
@property (nonatomic, weak) IBOutlet UITableView*   mTableView;

// Other objects
@property (nonatomic, strong) NSMutableArray*       mOptionsArray;

@end

@implementation SlideLeftVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initialize views
    [self initializeViews];
    
    // Load options array
    self.mOptionsArray = [[NSMutableArray alloc] init];
    
    // Photo Gallery
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"Photos" forKey:@"name"];
    [dict setObject:@"photo" forKey:@"image"];
    [self.mOptionsArray addObject:dict];
    
    // Download
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"Download" forKey:@"name"];
    [dict setObject:@"downloads-menu" forKey:@"image"];
    [self.mOptionsArray addObject:dict];
    
    // Settings
    dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"Settings" forKey:@"name"];
    [dict setObject:@"settings" forKey:@"image"];
    [self.mOptionsArray addObject:dict];
    
    // Select first row initially
    [self.mTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    // Load photo gallery in advance
    PhotoGalleryVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoGalleryVC"];
    
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:YES
                                                                     andCompletion:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (self._selectedIndex >= 0) {
        [self.mTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self._selectedIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void) initializeViews
{
    self.mViewTitleLabel.font = [Common getFontWithFamilyName:BariolLight withFontSize:70];
    self.mViewDetailLabel.font = [Common getFontWithFamilyName:BariolLight withFontSize:48];
    
    self.mViewTitleLabel.text = g_freeSpace;
}

#pragma mark - UITableView Cell Delegate And Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.mOptionsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return kRowHeight * screenSize.height / 1334.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SlideLeftTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SlideLeftCellIdentifier"];
    
    NSDictionary *dict = [self.mOptionsArray objectAtIndex:indexPath.row];
    
    //CGRect imgFrame = CGRectMake(offsetX, offsetY, cell.frame.size.width * 100 / 750.0f, height);
    cell.mImgIcon.image = [UIImage imageNamed:[dict objectForKey:@"image"]];
    cell.mImgIcon.contentMode = UIViewContentModeLeft;
    
    // Cell title label
    cell.mTitleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
    cell.mTitleLabel.text = [dict objectForKey:@"name"];
    
    // Add seperator view
    UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(20, kRowHeight-1, tableView.frame.size.width-40, 1)];
    seperatorView.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:seperatorView];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {               // Photo gallery
        PhotoGalleryVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoGalleryVC"];
        
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                 withSlideOutAnimation:YES
                                                                         andCompletion:nil];
        
        // Sunilgoyal219@gmail.com

    }
    
   else if (indexPath.row == 1) {           // Download
        ShareOptionVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareOptionVC"];
        
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                 withSlideOutAnimation:YES
                                                                         andCompletion:nil];
    }
    
    else if (indexPath.row == 2) {           // Settings
        SettingsVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsVC"];
        
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                 withSlideOutAnimation:YES
                                                                         andCompletion:nil];
    }
}


@end
