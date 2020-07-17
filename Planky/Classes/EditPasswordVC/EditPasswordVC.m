//
//  EditPasswordVC.m
//  Planky
//
//  Created by beauty on 1/4/16.
//  Copyright © 2016 Neelesh Aggarwal. All rights reserved.
//

#import "Common.h"
#import "EditPasswordVC.h"

#define kRowHeight 90
#define kSectionHeight 48

@interface EditPasswordVC ()
{
    CGSize screenSize;
}
@property (strong, nonatomic) IBOutlet UILabel      *mViewTitleLabel;

@property (strong, nonatomic) IBOutlet UIButton     *mCancelButton;
@property (strong, nonatomic) IBOutlet UIButton     *mSaveButton;

@property (strong, nonatomic) IBOutlet UITableView  *mTableView;

@property (nonatomic, strong) NSMutableArray        *mTableDataArray;

@end

@implementation EditPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    screenSize = [UIScreen mainScreen].bounds.size;
    
    [self loadSettingsArray];
    [self initializeViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initializeViews
{
    self.mViewTitleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:48];
    
    self.mCancelButton.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:36];
    self.mSaveButton.titleLabel.font = [Common getFontWithFamilyName:BariolRegular withFontSize:36];
    
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;
}

- (void)loadSettingsArray {
    
    self.mTableDataArray = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *sectionDict = [[NSMutableDictionary alloc] init];
    
    // Section 1  ---------------------------------------
    // Current Password
    NSMutableDictionary *currentPassDict = [[NSMutableDictionary alloc] init];
    [currentPassDict setObject:@"Current password" forKey:@"title"];
    
    [sectionDict setObject:@[currentPassDict] forKey:@"itemsArray"];
    [self.mTableDataArray addObject:sectionDict];
    
    // Section 2  --------------------------------------
    sectionDict = [[NSMutableDictionary alloc] init];
    
    // New password
    NSMutableDictionary *newPassDict = [[NSMutableDictionary alloc] init];
    [newPassDict setObject:@"New password" forKey:@"title"];
    
    // Repeat password
    NSMutableDictionary *repeatPassDict = [[NSMutableDictionary alloc] init];
    [repeatPassDict setObject:@"Repeat password" forKey:@"title"];
    
    [sectionDict setObject:@[newPassDict, repeatPassDict] forKey:@"itemsArray"];
    [self.mTableDataArray addObject:sectionDict];
    
}


#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRowHeight * screenSize.height / 1334.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kSectionHeight * screenSize.height / 1334.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 1.0f)];
    sectionHeader.backgroundColor = [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f];
    
    return sectionHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kSectionHeight * screenSize.height / 1334.0f)];
    sectionHeader.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:241/255.0 alpha:1.0];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, kSectionHeight * screenSize.height / 1334.0f - 1, screenSize.width, 1.0f)];
    separatorView.backgroundColor = [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f];
    [sectionHeader addSubview:separatorView];
    
    return sectionHeader;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.mTableDataArray objectAtIndex:section] objectForKey:@"itemsArray"] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.mTableDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    // remove previous view
    for (id view in cell.contentView.subviews)
        [view removeFromSuperview];
    
    NSDictionary *dict = [[[self.mTableDataArray objectAtIndex:indexPath.section] objectForKey:@"itemsArray"] objectAtIndex:indexPath.row];
    
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
    
    offsetX = 330 * screenSize.height / 1334.0f;
    width = 400 * screenSize.width / 750.0f;
    UITextField *contentText = [[UITextField alloc] initWithFrame:CGRectMake(offsetX, offsetY, width, height)];
    contentText.font = [Common getFontWithFamilyName:BariolRegular withFontSize:36];
    contentText.placeholder = @"Enter Password";
    contentText.textAlignment = NSTextAlignmentRight;
    [cell.contentView addSubview:contentText];

    
    return cell;
}


#pragma mark - button events

- (IBAction)onSave:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
