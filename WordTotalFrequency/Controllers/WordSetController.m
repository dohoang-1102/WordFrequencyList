//
//  WordSetController.m
//  WordTotalFrequency
//
//  Created by OCS on 11-7-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WordSetController.h"
#import "DashboardView.h"
#import "CustomProgress.h"
#import "UIColor+WTF.h"
#import "DataController.h"
#import "Constant.h"
#import "WordListCell.h"
#import "Util.h"

typedef enum {
    CapLeft          = 0,
    CapMiddle        = 1,
    CapRight         = 2,
    CapLeftAndRight  = 3
} CapLocation;


@interface WordSetController ()
- (void)updateMarkedCount;
@end

@implementation WordSetController

@synthesize viewContainer = _viewContainer;
@synthesize wordGroup = _wordGroup;
@synthesize currentTestWordIndex = _currentTestWordIndex;
@synthesize fetchRequest = _fetchRequest;
@synthesize wordTestView = _wordTestView;
@synthesize settingsView = _settingsView;
@synthesize selectedViewIndex = _selectedViewIndex;
@synthesize fetchedWordResultsController = _fetchedWordResultsController;

#define ICON_IMAGE_TAG 1
#define PERCENT_LABEL_TAG 2
#define PROGRESS_TAG 3

#define kSegmentLabelTag 99


- (NSArray *)testingWords
{
    NSDictionary *dict = [[DataController sharedDataController] dictionaryForCategoryId:_wordGroup.categoryId];
    if ([[dict valueForKey:@"testMarked"] boolValue]){
        if (_testingWords == nil){
            NSFetchRequest *_fetchTestingRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word"
                                                      inManagedObjectContext:[DataController sharedDataController].managedObjectContext];
            [_fetchTestingRequest setEntity:entity];
            [_fetchTestingRequest setPredicate:[NSPredicate predicateWithFormat:@"category = %d  and group = %d and spell in %@",
                                                _wordGroup.categoryId,
                                                _wordGroup.groupId,
                                                [[DataController sharedDataController] getUnmarkedWordsByCategory:_wordGroup.categoryId AndGroup:_wordGroup.groupId]]];
            
            NSError *error = nil;
            NSAutoreleasePool *ap = [[NSAutoreleasePool alloc] init];
            _testingWords = [[MANAGED_OBJECT_CONTEXT executeFetchRequest:_fetchTestingRequest error:&error] retain];
            [ap release];
            [_fetchTestingRequest release];
        }
        return _testingWords;
    }
    else{
        return _listController.wordsArray;
    }
}

- (NSArray *)listingWords
{
    return _listController.wordsArray;
}

- (void)dealloc
{    
    [MANAGED_OBJECT_CONTEXT reset];
    [NSFetchedResultsController deleteCacheWithName:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_listController release];
    _listController = nil;
    
    [_historyController release];
    _historyController = nil;
    
    [_settingsView release];
    _settingsView = nil;

    [_testingWords release];
    _testingWords = nil;
    
    [_fetchRequest release];
    _fetchRequest = nil;
    [_wordTestView release];
    _wordTestView = nil;
    
    [_segmentedControl release];
    [_viewContainer release];
    [_wordGroup release];
    [super dealloc];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateMarkedCount
{
    _wordGroup.intermediateMarkedWordCount = [[DataController sharedDataController] getMarkCountByCategory:_wordGroup.categoryId
                                                                                                  AndGroup:_wordGroup.groupId
                                                                                                 AndStatus:0];
    _wordGroup.completeMarkedWordCount = [[DataController sharedDataController] getMarkCountByCategory:_wordGroup.categoryId
                                                                                              AndGroup:_wordGroup.groupId
                                                                                             AndStatus:1];

    // update control
    [(UILabel *)[self.view viewWithTag:PERCENT_LABEL_TAG] setText:[NSString stringWithFormat:@"%d / %d", _wordGroup.markedWordCount, _wordGroup.totalWordCount]];
    CustomProgress *progress = (CustomProgress *)[self.view viewWithTag:PROGRESS_TAG];
    progress.currentValue = _wordGroup.completePercentage;
}


#pragma mark - notification handler

- (void)testSettingChanged:(NSNotification *)note
{
    _currentTestWordIndex = 0;
    
    [_testingWords release];
    _testingWords = nil;

    [_wordTestView release];
    _wordTestView = nil;
    
    [self updateMarkedCount];
}

- (void)historyChanged:(NSNotification *)note
{
    switch (_selectedViewIndex) {
        case 1:
            [_historyController release];
            _historyController = nil;
            [self updateMarkedCount];
            break;
        case 2:
            [[_viewContainer.subviews objectAtIndex:0] removeFromSuperview];
            [_historyController release];
            _historyController = nil;
            [_viewContainer addSubview:self.historyView];
            [self testSettingChanged:NULL];
            break;
        default:
            [_historyController release];
            _historyController = nil;
            [self testSettingChanged:NULL];
            break;
    }
}

- (void)batchMarkUpdated:(NSNotification *)note
{
    [MANAGED_OBJECT_CONTEXT reset];
    if (Util.iOSVersionMajor < 5)
        [_listController forceUpdateDataSource];
    [self testSettingChanged:NULL];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{    
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
    
    _viewContainer = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                              45.5,
                                                              CGRectGetWidth(self.view.bounds),
                                                              CGRectGetHeight(self.view.bounds)-100)];
    [self.view addSubview:_viewContainer];
    
    
    UIImageView *segmentBg = [[UIImageView alloc] initWithFrame:CGRectMake(6, CGRectGetHeight(rect)-49, 309, 48)];
    segmentBg.image = [UIImage imageNamed:@"segment-bg"];
    [self.view addSubview:segmentBg];
    [segmentBg release];
    
    //NSArray *titles = [NSArray arrayWithObjects:@"List", @"Test", @"History", @"Setting", nil];
    NSArray *titles = [NSArray arrayWithObjects:@"列表", @"测试", @"历史", @"设置", nil];
    _segmentedControl = [[CustomSegmentedControl alloc]
                                                     initWithSegmentCount:titles.count
                                                     segmentsize:CGSizeMake(77, 48)
                                                     dividerImage:[UIImage imageNamed:@"segment-breaker"]
                                                     tag:1000
                                                    delegate:self];
    _segmentedControl.frame = CGRectMake(6, CGRectGetHeight(rect)-54, 308, 48);
    [self.view addSubview:_segmentedControl];
    
    // notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(testSettingChanged:)
                                                 name:TEST_SETTING_CHANGED_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(historyChanged:)
                                                 name:HISTORY_CHANGED_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batchMarkUpdated:)
                                                 name:BATCH_MARKED_NOTIFICATION
                                               object:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [(UIImageView *)[self.view viewWithTag:ICON_IMAGE_TAG] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"unit-%d", _wordGroup.categoryId+1]]];
    CustomProgress *progress = (CustomProgress *)[self.view viewWithTag:PROGRESS_TAG];
    [progress setImageName:[NSString stringWithFormat:@"progress-fg-%d", _wordGroup.categoryId+1]];
    progress.currentValue = _wordGroup.completePercentage;
    
    _listController = [[WordListController alloc] initWIthListType:WordListTypeWordSet];
    _listController.wordSetIndex = _wordGroup.categoryId;
    _listController.wordGroupIndex = _wordGroup.groupId;
    _listController.wordSetController = self;
    _listController.view.frame = _viewContainer.bounds;
    [_viewContainer addSubview:_listController.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (Util.iOSVersionMajor < 5)
        [self updateMarkedCount];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (Util.iOSVersionMajor == 5)
        [self updateMarkedCount];

    if (_selectedViewIndex == 0)
        [_listController.tableView deselectRowAtIndexPath:[_listController.tableView indexPathForSelectedRow] animated:YES];
    else if (_selectedViewIndex == 2)
        [_historyController.tableView deselectRowAtIndexPath:[_historyController.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - CustomSegmentedControlDelegate

- (void)touchDownAtSegmentIndex:(NSUInteger)segmentIndex
{
    for (int i=0; i<4; i++) {
        UIButton* button = (UIButton *)[_segmentedControl viewWithTag:i+10];
        UILabel *label = (UILabel *)[button viewWithTag:kSegmentLabelTag];
        if (i == segmentIndex)
        {
            label.textColor = [UIColor whiteColor];
            label.shadowOffset = CGSizeMake(0, 0);
        }
        else
        {
            label.textColor = [UIColor colorForNormalText];
            label.shadowOffset = CGSizeMake(.5, 1);
        }
    }
}

- (void)touchUpInsideSegmentIndex:(NSUInteger)segmentIndex
{
    [[_viewContainer.subviews objectAtIndex:0] removeFromSuperview];
    switch (segmentIndex) {
        case 0:
            [_viewContainer addSubview:_listController.view];
            NSArray *cells = [_listController.tableView visibleCells];
            for (WordListCell *cell in cells) {
                if (Util.iOSVersionMajor == 5) {
                    NSIndexPath *indexPath = [_listController.tableView indexPathForCell:cell];
                    cell.word = [_listController.fetchedResultsController objectAtIndexPath:indexPath];
                }
                [cell setNeedsLayout];
            }
            break;
        case 1:
            [_viewContainer addSubview:self.wordTestView];
            break;
        case 2:
            [_viewContainer addSubview:self.historyView];
            break;
        case 3:
            [_viewContainer addSubview:self.settingsView];
            break;
    }
    _selectedViewIndex = segmentIndex;
}

- (UIButton *)buttonFor:(CustomSegmentedControl*)segmentedControl atIndex:(NSUInteger)segmentIndex;
{
//    NSUInteger dataOffset = segmentedControl.tag - TAG_VALUE ;
//    NSDictionary* data = [buttons objectAtIndex:dataOffset];
    //NSArray *titles = [NSArray arrayWithObjects:@"List", @"Test", @"History", @"Setting", nil];
    NSArray *titles = [NSArray arrayWithObjects:@"列表", @"测试", @"历史", @"设置", nil];
    
    CapLocation location;
    if (segmentIndex == 0)
        location = CapLeft;
    else if (segmentIndex == titles.count - 1)
        location = CapRight;
    else
        location = CapMiddle;
    
    UIImage* buttonImage = nil;
    UIImage* buttonPressedImage = nil;
    
    CGFloat capWidth = 0;
    CGSize buttonSize = CGSizeMake(77, 48);
    
    if (location == CapLeft)
    {
        buttonPressedImage = [[UIImage imageNamed:@"segment-left-pressed"] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
    }
    else if (location == CapRight)
    {
        buttonPressedImage = [[UIImage imageNamed:@"segment-right-pressed"] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
    }
    else
    {
        buttonPressedImage = [[UIImage imageNamed:@"segment-middle-pressed"] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
    }
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, buttonSize.width, buttonSize.height);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, buttonSize.width, 40)];
    label.tag = kSegmentLabelTag;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorForNormalText];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(.5, 1);
    label.text = [titles objectAtIndex:segmentIndex];
    [button addSubview:label];
    [label release];
    
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateSelected];
    button.adjustsImageWhenHighlighted = NO;
    
    if (segmentIndex == 0)
    {
        button.selected = YES;
        label.textColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0, 0);
    }
    return button;
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

- (NSFetchedResultsController *)fetchedWordResultsController{
    return _listController.fetchedResultsController;
}



#pragma mark - segmented views

- (WordTestView *)wordTestView
{
    if (_wordTestView == nil)
    {
        _wordTestView = [[WordTestView alloc] initWithFrame:_viewContainer.bounds];
        _wordTestView.wordSetController = self;
    }
    return _wordTestView;
}

- (UIView *)historyView
{
    if (_historyController == nil)
    {
        _historyController = [[WordListController alloc] initWIthListType:WordListTypeHistory];
        _historyController.wordSetIndex = _wordGroup.categoryId;
        _historyController.wordGroupIndex = _wordGroup.groupId;
        _historyController.wordSetController = self;
        _historyController.view.frame = _viewContainer.bounds;
    }
    return _historyController.view;
}

- (SettingsView *)settingsView
{
    if (_settingsView == nil)
    {
        _settingsView = [[SettingsView alloc] initWithFrame:_viewContainer.bounds];
        _settingsView.wordSetController = self;
    }
    return _settingsView;
}

@end
