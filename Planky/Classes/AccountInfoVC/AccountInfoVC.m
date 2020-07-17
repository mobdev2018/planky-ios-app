//
//  AccountInfoVC.m
//  Planky
//
//  Created by CanvasM on 03/11/15.
//  Copyright (c) 2015 Neelesh Aggarwal. All rights reserved.
//

#import "AccountInfoVC.h"

#define kRowHeight      50
#define kSectionHeight  20


@interface AccountInfoVC ()

// IBOutlets
@property (nonatomic, weak) IBOutlet UITableView*           mTableView;

// Other objects
@property (nonatomic, strong) NSMutableArray*               mSettingsArray;

@end

@implementation AccountInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadSettingsArray];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)loadSettingsArray {
    
    self.mSettingsArray = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *sectionDict = [[NSMutableDictionary alloc] init];
    
    // Section 1  -----------------
    // Name
    NSMutableDictionary *nameDict = [[NSMutableDictionary alloc] init];
    [nameDict setObject:@"Name" forKey:@"title"];
    [nameDict setObject:@"name" forKey:@"valueKey"];
    [nameDict setObject:@"NO" forKey:@"hasDetails"];
    
    // Email
    NSMutableDictionary *emailDict = [[NSMutableDictionary alloc] init];
    [emailDict setObject:@"Email" forKey:@"title"];
    [emailDict setObject:@"email" forKey:@"valueKey"];
    [emailDict setObject:@"NO" forKey:@"hasDetails"];
    
    [sectionDict setObject:@[nameDict, emailDict] forKey:@"itemsArray"];
    [self.mSettingsArray addObject:sectionDict];    //------------------------
    
    
    // Section 2 -----------------------
    sectionDict = [[NSMutableDictionary alloc] init];
    // Edit
    NSMutableDictionary *editDict = [[NSMutableDictionary alloc] init];
    [editDict setObject:@"Edit" forKey:@"title"];
    [editDict setObject:@"edit" forKey:@"valueKey"];
    [editDict setObject:@"NO" forKey:@"hasDetails"];
    
    [sectionDict setObject:@[editDict] forKey:@"itemsArray"];
    [self.mSettingsArray addObject:sectionDict];        //--------------------------
    
    // Section 3 -----------------------
    sectionDict = [[NSMutableDictionary alloc] init];
    // Plan
    NSMutableDictionary *planDict = [[NSMutableDictionary alloc] init];
    [planDict setObject:@"Plan" forKey:@"title"];
    [planDict setObject:@"plan" forKey:@"valueKey"];
    [planDict setObject:@"NO" forKey:@"hasDetails"];
    
    // Photos
    NSMutableDictionary *photosDict = [[NSMutableDictionary alloc] init];
    [photosDict setObject:@"Photos" forKey:@"title"];
    [photosDict setObject:@"photosCount" forKey:@"valueKey"];
    [photosDict setObject:@"NO" forKey:@"hasDetails"];
  
    // Joined
    NSMutableDictionary *joinedDict = [[NSMutableDictionary alloc] init];
    [joinedDict setObject:@"Joined" forKey:@"title"];
    [joinedDict setObject:@"joined" forKey:@"valueKey"];
    [joinedDict setObject:@"NO" forKey:@"hasDetails"];
    
    [sectionDict setObject:@[planDict, photosDict, joinedDict] forKey:@"itemsArray"];
    [self.mSettingsArray addObject:sectionDict];
    
    // Section 4
    sectionDict = [[NSMutableDictionary alloc] init];
    // Change plan
    NSMutableDictionary *changePlan = [[NSMutableDictionary alloc] init];
    [changePlan setObject:@"Change Plan" forKey:@"title"];
    [changePlan setObject:@"NO" forKey:@"hasDetails"];
    
    [sectionDict setObject:@[changePlan] forKey:@"itemsArray"];
    [self.mSettingsArray addObject:sectionDict];
    
}


#pragma mark - Slide Left Button

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - SlideNavigationController Methods

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}


#pragma mark - UITableView Cell Delegate And Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.mSettingsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kSectionHeight)];
    sectionHeader.backgroundColor = [UIColor clearColor];
    
    // Header label
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, sectionHeader.frame.size.width-20, kSectionHeight-20)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor darkGrayColor];
    headerLabel.text = [[self.mSettingsArray objectAtIndex:section] objectForKey:@"title"];
    [sectionHeader addSubview:headerLabel];
    
    return sectionHeader;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.mSettingsArray objectAtIndex:section] objectForKey:@"itemsArray"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
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
    
    // Cell title label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 150, kRowHeight)];
    titleLabel.font = [UIFont systemFontOfSize:15];
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
    
    // Details value label
    if ([dict objectForKey:@"valueKey"]) {
        UILabel *detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 200, 0, 180, kRowHeight)];
        detailsLabel.font = [UIFont systemFontOfSize:15];
        detailsLabel.backgroundColor = [UIColor clearColor];
        detailsLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:[dict objectForKey:@"valueKey"]];
        [cell.contentView addSubview:detailsLabel];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
