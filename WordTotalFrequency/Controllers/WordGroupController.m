//
//  WordGroupController.m
//  WordFrequencyList
//
//  Created by hx on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WordGroupController.h"
#import "DashboardView.h"
#import "UIColor+WTF.h"
#import "CustomProgress.h"
#import "DataController.h"
#import "WordGroupCell.h"
#import "WordTotalFrequencyAppDelegate.h"


#define ICON_IMAGE_TAG 1
#define PERCENT_LABEL_TAG 2
#define PROGRESS_TAG 3

@implementation WordGroupController

@synthesize wordSet         = _wordSet;
@synthesize fetchRequest    = _fetchRequest;
@synthesize tableView       = _tableView;
@synthesize groups          = _groups;


- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateMarkedCount
{
    NSPredicate *predicate;
    NSError *error;
    NSUInteger count;
    
    predicate = [NSPredicate predicateWithFormat:@"category = %d and markStatus = 1", _wordSet.categoryId];
    [self.fetchRequest setPredicate:predicate];
    count = [[DataController sharedDataController].managedObjectContext countForFetchRequest:self.fetchRequest error:&error];
    _wordSet.intermediateMarkedWordCount = count;
    
    predicate = [NSPredicate predicateWithFormat:@"category = %d and markStatus = 2", _wordSet.categoryId];
    [self.fetchRequest setPredicate:predicate];
    count = [[DataController sharedDataController].managedObjectContext countForFetchRequest:self.fetchRequest error:&error];
    _wordSet.completeMarkedWordCount = count;
    
    // update control
    [(UILabel *)[self.view viewWithTag:PERCENT_LABEL_TAG] setText:[NSString stringWithFormat:@"%d / %d", _wordSet.markedWordCount, _wordSet.totalWordCount]];
    CustomProgress *progress = (CustomProgress *)[self.view viewWithTag:PROGRESS_TAG];
    progress.currentValue = _wordSet.completePercentage;
    
    // update percent for groups
    for (WordGroup *wordGroup in self.groups) {
        predicate = [NSPredicate predicateWithFormat:@"category = %d and group = %d and markStatus = 1", wordGroup.categoryId, wordGroup.groupId];
        [self.fetchRequest setPredicate:predicate];
        count = [[DataController sharedDataController].managedObjectContext countForFetchRequest:self.fetchRequest error:&error];
        wordGroup.intermediateMarkedWordCount = count;
        
        predicate = [NSPredicate predicateWithFormat:@"category = %d and group = %d and markStatus = 2", wordGroup.categoryId, wordGroup.groupId];
        [self.fetchRequest setPredicate:predicate];
        count = [[DataController sharedDataController].managedObjectContext countForFetchRequest:self.fetchRequest error:&error];
        wordGroup.completeMarkedWordCount = count;
    }
}

- (NSFetchRequest *)fetchRequest
{
    if (_fetchRequest != nil)
    {
        return _fetchRequest;
    }
    
    _fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word"
                                              inManagedObjectContext:[DataController sharedDataController].managedObjectContext];
    [_fetchRequest setEntity:entity];
    return _fetchRequest;
}

- (void)loadData
{
    self.groups = [NSMutableArray array];
    
    int currentGroupId = 0;
    int startNumber = 1;
    
    while (YES) {
        NSPredicate *predicate;
        NSError *error;
        NSUInteger count;
        
        predicate = [NSPredicate predicateWithFormat:@"category = %d and group = %d", _wordSet.categoryId, currentGroupId];
        [self.fetchRequest setPredicate:predicate];
        count = [[DataController sharedDataController].managedObjectContext countForFetchRequest:self.fetchRequest error:&error];
        
        if (count > 0) {
            WordGroup *wg = [[WordGroup alloc] init];
            wg.categoryId = _wordSet.categoryId;
            wg.groupId = currentGroupId;
            wg.startNumber = startNumber;
            wg.totalWordCount = count;
            [self.groups addObject:wg];
            [wg release];
            
            currentGroupId++;
            startNumber += count;
        }
        else {
            break;
        }
    }
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [self loadData];
    
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    
    self.view = [[[DashboardView alloc] initWithFrame:rect] autorelease];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 2, 44, 44);
    [button setImage:[UIImage imageNamed:@"arrow-back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [button setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:button];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 7, 30, 30)];
    imageView.tag = ICON_IMAGE_TAG;
    [self.view addSubview:imageView];
    [imageView release];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(114, 4, 160, 16)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor colorForNormalText];
    label.tag = PERCENT_LABEL_TAG;
    [self.view addSubview:label];
    [label release];
    
    CustomProgress *progress = [[CustomProgress alloc] initWithFrame:CGRectMake(110, 21, 160, 13)];
    progress.tag = PROGRESS_TAG;
    [self.view addSubview:progress];
    [progress release];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(rect), 1.5)];
    line.backgroundColor = [UIColor colorWithWhite:1.f alpha:.6f];
    [self.view addSubview:line];
    [line release];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                              45,
                                                              CGRectGetWidth(self.view.bounds),
                                                              CGRectGetHeight(self.view.bounds)-45)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor colorWithWhite:1.f alpha:.5f];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [(UIImageView *)[self.view viewWithTag:ICON_IMAGE_TAG] setImage:[UIImage imageNamed:_wordSet.iconUrl]];
    CustomProgress *progress = (CustomProgress *)[self.view viewWithTag:PROGRESS_TAG];
    [progress setImageName:[NSString stringWithFormat:@"progress-fg-%d", _wordSet.categoryId+1]];
    progress.currentValue = _wordSet.completePercentage;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateMarkedCount];
    [self.tableView reloadData];
}

- (void)dealloc
{
    [_wordSet release];
    [_fetchRequest release];
    [_tableView release];
    [_groups release];
    
    [super dealloc];
}

#pragma mark - UITableViewDataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groups count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    WordGroupCell *cell = (WordGroupCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[WordGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.wordGroup = [self.groups objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WordSetController *wsc = [[WordSetController alloc] init];
    wsc.wordGroup = [self.groups objectAtIndex:indexPath.row];
    
    WordTotalFrequencyAppDelegate *del = (WordTotalFrequencyAppDelegate *)[UIApplication sharedApplication].delegate;
    [del.navigationController pushViewController:wsc animated:YES];
    [wsc release];
}

@end
