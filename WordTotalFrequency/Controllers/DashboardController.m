//
//  DashboardController.m
//  WordTotalFrequency
//
//  Created by OCS on 11-7-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "DataUtil.h"
#import "DashboardController.h"
#import "Common.h"
#import "DashboardView.h"
#import "WordSet.h"
#import "WordSetController.h"
#import "UnitIconView.h"
#import "WordSetBriefView.h"
#import "UIColor+WTF.h"
#import "DataController.h"
#import "InfoScrollController.h"

@interface DashboardController()
- (void)dismissSearchResult:(BOOL)animated;
- (void)collapseWordSetBrief;
- (void)showInformation;
@end

@implementation DashboardController

@synthesize wordSets = _wordSets;
@synthesize unitIcons = _unitIcons;
@synthesize wordSetBrief = _wordSetBrief;
@synthesize briefView = _briefView;
@synthesize searchBar = _searchBar;
@synthesize listController = _listController;
@synthesize collapseButton = _collapseButton;
@synthesize fetchRequest = _fetchRequest;

#define SEARCH_BAR_HEIGHT 40
#define WORDSETBRIEF_HEIGHT 124
#define PIE_LABEL_TAG_BASE 11

- (void)dealloc
{
    [_collapseButton release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_fetchRequest release];
    _fetchRequest = nil;
    
    [_wordSets release];
    [_unitIcons release];
    [_briefView release];
    [_wordSetBrief release];
    [_searchBar release];
    [_listController release];
    [_barContainer release];
    [_pieView release];
    
    [super dealloc];
}

- (void)loadData
{
    _wordSets = [[NSMutableArray alloc] init];
    
    NSDictionary *dict = [[DataController sharedDataController] settingsDictionary];
    NSArray *array = [dict objectForKey:@"WordSets"];
    int totalOfAllSets = 0;
    for (NSDictionary *dict in array) {
        WordSet *set    = [[WordSet alloc] init];
        
        // ***********
        // value from plist
        // ***********
        set.color       = [UIColor colorWithHex:[[dict objectForKey:@"color"] intValue]];
        set.description = [dict objectForKey:@"description"];
        set.iconUrl     = [dict objectForKey:@"iconUrl"];
        set.categoryId  = [[dict objectForKey:@"categoryId"] intValue];
        set.arrowColor  = [UIColor colorWithHex:[[dict objectForKey:@"arrowColor"] intValue]];
        
        // ***********
        // value from database
        // ***********
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category = %d", set.categoryId];
        [self.fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSUInteger total = [[DataController sharedDataController].managedObjectContext countForFetchRequest:self.fetchRequest error:&error];
        
        set.totalWordCount = total;
        totalOfAllSets += total;

        // marked count
        predicate = [NSPredicate predicateWithFormat:@"category = %d and markStatus = 1", set.categoryId];
        [self.fetchRequest setPredicate:predicate];
        set.intermediateMarkedWordCount = [[DataController sharedDataController].managedObjectContext countForFetchRequest:self.fetchRequest error:&error];
        
        predicate = [NSPredicate predicateWithFormat:@"category = %d and markStatus = 2", set.categoryId];
        [self.fetchRequest setPredicate:predicate];
        set.completeMarkedWordCount = [[DataController sharedDataController].managedObjectContext countForFetchRequest:self.fetchRequest error:&error];
        
        
        UnitIconView *icon = [_unitIcons objectAtIndex:set.categoryId];
        [icon updateData];
        
        [_wordSets addObject:set];
        [set release];
    }
}


/********************************************
 * when click the wordset icon, (which is the round icons on the top with digital on it)
 * it will result showing the brief bubble
 ********************************************/
- (void)presentWordSetBrief
{
    [UIView transitionWithView:_barContainer duration:.2
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^ {
                        _wordSetBrief.frame = CGRectMake(0, 0, 320, WORDSETBRIEF_HEIGHT);
                    }
                    completion:^(BOOL finished) {
                        if (finished)
                            _briefView.hidden = YES;
                    }];
}

- (void)dismissWordSetBrief
{
    [UIView transitionWithView:_barContainer duration:.2
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^ {
                        _wordSetBrief.frame = CGRectMake(0, -WORDSETBRIEF_HEIGHT, 320, WORDSETBRIEF_HEIGHT);
                    }
                    completion:^(BOOL finished) {
                    }];
    _briefView.hidden = NO;
}

- (NSInteger)selectedIconIndex
{
    @synchronized(self) {
        return _selectedIconIndex;
    }
}

- (void)setSelectedIconIndex:(NSInteger)selectedIconIndex
{
    @synchronized(self) {
        NSInteger oldIndex = _selectedIconIndex;
        _selectedIconIndex = selectedIconIndex;
        
        UnitIconView *icon;
        if (selectedIconIndex > -1)
        {
            _wordSetBrief.wordSet = [_wordSets objectAtIndex:selectedIconIndex];
            
            icon = [_unitIcons objectAtIndex:selectedIconIndex];
            CGPoint point = icon.center;
            point = [_wordSetBrief convertPoint:point fromView:icon.superview];
            [_wordSetBrief centerArrowToX:point.x];
            [self performSelector:@selector(presentWordSetBrief) withObject:nil afterDelay:.25];
            [_pieView gotoPart:selectedIconIndex];
        }
        else if (oldIndex > -1)
        {
            icon = [_unitIcons objectAtIndex:oldIndex];
            [icon toggleDisplayState:icon affectDashboard:NO];
            [self dismissWordSetBrief];
        }
        
    }
}

- (void)keyboardWillShow:(NSNotification *)note {
    NSArray *allWindows = [[UIApplication sharedApplication] windows];
	int topWindow = [allWindows count] - 1;
	UIWindow *keyboardWindow = [allWindows objectAtIndex:topWindow];
    [keyboardWindow addSubview:self.collapseButton];

    [UIView transitionWithView:self.collapseButton duration:0.2
                       options:UIViewAnimationOptionCurveLinear
                    animations:^ {
                        self.collapseButton.frame = CGRectMake(242, 438, 75, 39);
                    }
                    completion:^(BOOL finished) {
                    }];
}

- (void)keyboardWillHide:(NSNotification *)note {
    [UIView transitionWithView:self.collapseButton duration:0.2
                       options:UIViewAnimationOptionCurveLinear
                    animations:^ {
                        self.collapseButton.frame = CGRectMake(242, 480, 75, 39);
                    }
                    completion:^(BOOL finished) {
                        if (finished)
                            [self.collapseButton removeFromSuperview];
                    }];
}

- (void)dismissKeyboard
{
    [_searchBar resignFirstResponder];
}


#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    //if frist time lunch,then goto open tutorial slides 
    int times = [[[DataController sharedDataController].settingsDictionary objectForKey:@"AppLoadedTimes"] intValue];
    
    if (times==0) {
        InfoScrollController *infoController = [[InfoScrollController alloc] initWithDisplayType:firstLoad];
        [self.navigationController pushViewController:infoController animated:NO];
        [infoController release];
    }
    
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    
    self.view = [[[DashboardView alloc] initWithFrame:rect] autorelease];

    //searchbar
    
    _searchBar = [[CustomSearchBar alloc] init];
    _searchBar.keyboardType             = UIKeyboardTypeASCIICapable;
    _searchBar.autocapitalizationType   = UITextAutocapitalizationTypeNone;
    _searchBar.delegate                 = self;
    _searchBar.placeholder              = @"type to search";
    
    [_searchBar sizeToFit];
    [self.view addSubview:_searchBar];
    
    
    
    // unit icons
    
    _unitIcons = [[NSMutableArray alloc] init];
    for (int i=0; i<5; i++)
    {
        UnitIconView *icon = [[UnitIconView alloc]
                              initWithFrame:CGRectMake(20 + i * 57, 46, 44, 44)
                              image:[NSString stringWithFormat:@"Unit-%d", (i+1)]];
        icon.dashboard = self;
        icon.index = i;
        [self.view addSubview:icon];
        [_unitIcons addObject:icon];
        [icon release];
    }
    
    _barContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 92, CGRectGetWidth(rect), WORDSETBRIEF_HEIGHT)];
    _barContainer.clipsToBounds = YES;
    [self.view addSubview:_barContainer];
    
    _briefView = [[BriefView alloc] 
                  initWithFrame:CGRectMake(10, 20, CGRectGetWidth([UIScreen mainScreen].applicationFrame)-20, 100)];
    [_barContainer addSubview:_briefView];

    
    // word set brief
    _wordSetBrief = [[WordSetBriefView alloc]
                     initWithFrame:CGRectMake(0, -WORDSETBRIEF_HEIGHT, CGRectGetWidth(rect), WORDSETBRIEF_HEIGHT)];
    [_barContainer addSubview:_wordSetBrief];
    
    
    
    // pie chart
    _pieView = [[OpenGLView alloc] initWithFrame:CGRectMake(0, 160, 320, 320)];
    [self.view insertSubview:_pieView atIndex:1];
    
    // pie label is the tiny label displayed on pie chart
    for (int i=0; i<5; i++) {
        UIImage *backImage      = [[UIImage imageNamed:@"pieLabel"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
        CGRect frame            = CGRectMake(320, 480, backImage.size.width, backImage.size.height);
        UIImageView *pieLabel   = [[UIImageView alloc] initWithFrame:frame];
        pieLabel.tag            = PIE_LABEL_TAG_BASE + i;
        pieLabel.image          = backImage;
        
        UILabel *label          = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, backImage.size.width, 19)];
        label.backgroundColor   = [UIColor clearColor];
        label.textAlignment     = UITextAlignmentCenter;
        label.textColor         = [UIColor colorForNormalText];
        label.font              = [UIFont systemFontOfSize:14];
        label.shadowColor       = [UIColor whiteColor];
        label.shadowOffset      = CGSizeMake(.5, 1);
        [pieLabel addSubview:label];
        [label release];
        
        [self.view addSubview:pieLabel];
        [pieLabel release];
    }
    
    //list controller
    //normally this list will hide,it will only show up when user clicked the search field 
    
    _listController = [[WordListController alloc] initWIthListType:WordListTypeSearchResult];
    _listController.delegate = self;
    [self.view addSubview:_listController.view];
    
    // info button
    // at the bottom-right, there is a info button, it has 2 layers
    // infoview is a pure image ,shows a fliped corner
    // infoBtn is the "i" image on top of it
    UIImage *info = [UIImage imageNamed:@"info-bg"];
    UIImageView *infoView = [[UIImageView alloc] initWithImage:info];
    infoView.frame = CGRectMake(CGRectGetWidth(rect) - info.size.width,
                                CGRectGetHeight(rect) - info.size.height,
                                info.size.width,
                                info.size.height);
    [self.view addSubview:infoView];
    [infoView release];
    
    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    infoBtn.frame = CGRectMake(CGRectGetMinX(infoView.frame)+16, CGRectGetMinY(infoView.frame)+22, 44, 44);
    [infoBtn setImage:[UIImage imageNamed:@"info-btn"] forState:UIControlStateNormal];
    [infoBtn addTarget:self action:@selector(showInformation) forControlEvents:UIControlEventTouchUpInside];
    [infoBtn setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:infoBtn];
    
    // keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //config the closebutton of keyboard
    self.collapseButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    self.collapseButton.frame = CGRectMake(242, 480, 75, 39);
    [self.collapseButton setImage:[UIImage imageNamed:@"down-button.png"] forState:UIControlStateNormal];
    [self.collapseButton setImage:[UIImage imageNamed:@"down-button.png"] forState:UIControlStateHighlighted];
    [self.collapseButton addTarget:self action:@selector(dismissKeyboard)  forControlEvents:UIControlEventTouchUpInside];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _listController.view.frame = CGRectMake(0,
                                            CGRectGetHeight(self.view.frame),
                                            CGRectGetWidth(self.view.frame),
                                            CGRectGetHeight(self.view.frame)- SEARCH_BAR_HEIGHT);
    
    [_searchBar resignFirstResponder];
    [self dismissSearchResult:NO];
    
    if (_selectedIconIndex > -1){
        [_wordSetBrief updateDisplay];
        UnitIconView *icon = [_unitIcons objectAtIndex:_selectedIconIndex];
        [icon updateData];
    }
    
    // update total marked count
    int total = 0;
    for (WordSet *wordSet in _wordSets) {
        total += wordSet.markedWordCount;
    }
    [_briefView updateTotalMarkedCount:total];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    for (UnitIconView *icon in _unitIcons) {
        [icon addCADisplayLink];
    }
    
    if (_selectedIconIndex > -1)
    {
        [_wordSetBrief performSelector:@selector(fadeSelectedBackground) withObject:nil afterDelay:0.15];
        [_wordSetBrief updateDisplay];
//        [self performSelector:@selector(collapseWordSetBrief) withObject:nil afterDelay:0.65];
    }
    
    if (_searchBar.text != NULL)
        _listController.searchString = _searchBar.text;
    
    // setup pie chart
    int totalOfAllSets = 0;
    for (WordSet *wordSet in _wordSets) {
        totalOfAllSets += wordSet.totalWordCount;
    }
    
    float pieValue[5], pieGreenValue[5], pieYellowValue[5];
    for (int i=0; i<5; i++) {
        UIImageView *pieLabel = (UIImageView *)[self.view viewWithTag:PIE_LABEL_TAG_BASE+i];
        UILabel *label = (UILabel *)[pieLabel.subviews objectAtIndex:0];
        label.text = [NSString stringWithFormat:@"%d", [[_wordSets objectAtIndex:i] totalWordCount]];
        
        WordSet *wordSet = [_wordSets objectAtIndex:i];
        pieValue[i] = 1.0 * wordSet.totalWordCount / totalOfAllSets;
        pieGreenValue[i] = 1.0 * wordSet.completeMarkedWordCount  / wordSet.totalWordCount;
        pieYellowValue[i] = 1.0 * wordSet.intermediateMarkedWordCount  / wordSet.totalWordCount;
        
    }
    [_pieView setupPartData:pieValue : pieGreenValue : pieYellowValue];
    [_pieView setupTimer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_pieView destroyTimer];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self loadData];
    for (int i=0; i<[_wordSets count]; i++)
    {
        UnitIconView *icon = [_unitIcons objectAtIndex:i];
        icon.wordSet = [_wordSets objectAtIndex:i];
    }
    
    _selectedIconIndex = -1;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_wordSets release];
    [self.collapseButton removeTarget:self action:@selector(dismissKeyboard)  forControlEvents:UIControlEventTouchUpInside];
    [_collapseButton release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [_searchBar resignFirstResponder];
    [self dismissSearchResult:YES];
    [self dismissWordSetBrief];
    self.selectedIconIndex = -1;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar.searchBox setBackground:[UIImage imageNamed:@"search-bg-highlight"]];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
    
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.2];
	CGRect rect = _listController.view.frame;
	rect.origin.y = SEARCH_BAR_HEIGHT;
	_listController.view.frame = rect;
    
    [UIView commitAnimations];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self dismissSearchResult:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
    [self dismissSearchResult:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _listController.searchString = searchBar.text;
}

#pragma mark - WordListDelegate

- (void)willSelectWord:(Word *)word
{
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

#pragma mark - private messages

- (void)dismissSearchResult:(BOOL)animated
{
    if (animated)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.2];
        CGRect rect     = _listController.view.frame;
        rect.origin.y   = CGRectGetHeight(self.view.frame);
        _listController.view.frame = rect;
        
        [UIView commitAnimations];
    }
    else
    {
        CGRect rect = _listController.view.frame;
        rect.origin.y = CGRectGetHeight(self.view.frame);
        _listController.view.frame = rect;
    }
}

- (void)collapseWordSetBrief
{
    self.selectedIconIndex = -1;
}

- (void)showInformation
{
    InfoScrollController *controller = [[InfoScrollController alloc] initWithDisplayType:normalLoad];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

@end
