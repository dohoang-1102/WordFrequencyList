//
//  WordDetailController.m
//  WordTotalFrequency
//
//  Created by OCS on 11-7-27.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WordDetailController.h"
#import "DashboardView.h"
#import "UIColor+WTF.h"
#import "DataController.h"
#import "WordDetailView.h"
#import "WordListCell.h"


typedef enum {
    CapLeft          = 0,
    CapMiddle        = 1,
    CapRight         = 2,
    CapLeftAndRight  = 3
} CapLocation;


@implementation WordDetailController

@synthesize word = _word;
@synthesize words = _words;
@synthesize wordSetIndex = _wordSetIndex;
@synthesize currentWordIndex = _currentWordIndex;
@synthesize wordSetController = _wordSetController;
@synthesize wordListController = _wordListController;
@synthesize historyListDirty = _historyListDirty;
@synthesize navigatable = _navigatable;

#define MARK_ICON_TAG 1
#define SPELL_LABEL_TAG 2
#define PHONETIC_LABEL_TAG 3
#define DETAIL_LABEL_TAG 4
#define SEGMENT_BG_TAG 17

#define kSegmentLabelTag 99
#define kSegmentMarkTag 97

- (id)init
{
    if ((self = [super init]))
    {
        _wordSetIndex = -1;
    }
    return self;
}

- (void)dealloc
{
    [_word release];
    [_words release];
    [_containerView release];
    [_segmentedControl release];
    [super dealloc];
}

- (void)backAction
{
    BOOL check = YES;
    if (_wordSetController.selectedViewIndex == 2 && self.historyListDirty){
        check = NO;
    }
    
    
    if (check && self.wordListController &&
        self.wordListController.listType != WordListTypeHistory){
        if (_currentWordIndex != [self.wordListController.tableView indexPathForSelectedRow].row)
        {
            NSUInteger ii[2] = {0, _currentWordIndex};
            NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
            [self.wordListController.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        }
        NSArray *cells = [self.wordListController.tableView visibleCells];
        for (WordListCell *cell in cells) {
            [cell setNeedsLayout];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateMarkOnSegmented
{
    int status = [[DataController sharedDataController] getMarkStatusBySpell:self.word.spell];
    NSString *imageName = [NSString stringWithFormat:@"mark-circle-%d", status];
    UIImageView *image = (UIImageView *)[self.view viewWithTag:kSegmentMarkTag];
    image.image = [UIImage imageNamed:imageName];
    UILabel *label = (UILabel *)[self.view viewWithTag:kSegmentLabelTag];
    if(status == 0){
        label.text = @"点此标记为“熟悉”";
    }else if(status == 1){
        label.text = @"点此标记为“记住”";
    }else if(status == 2){
        label.text = @"清除标记";
    }
    
}

- (void)updateMarkOnTopBar
{
    WordDetailView *view = (WordDetailView *)[_containerView.subviews objectAtIndex:0];
    [view markAction:nil];
}

- (void)previousWordDetail
{
    if (_currentWordIndex > 0)
    {
        CGRect rect = _containerView.bounds;
        rect.origin.x -= CGRectGetWidth(rect);
        WordDetailView *view = [[WordDetailView alloc] initWithFrame:rect];
        view.wordDetailController = self;
        [_containerView addSubview:view];
        
        WordDetailView *oldView =  [[_containerView subviews] objectAtIndex:0];
        [UIView transitionWithView:_containerView duration:0.5
                           options:UIViewAnimationOptionCurveEaseInOut
                        animations:^ {
                            view.frame = _containerView.bounds;
                            oldView.frame = CGRectMake(CGRectGetWidth(rect), rect.origin.y, CGRectGetWidth(rect), CGRectGetHeight(rect));
                        }
                        completion:^(BOOL finished) {
                            // turn word back into a fault
                            [[DataController sharedDataController].managedObjectContext refreshObject:oldView.word mergeChanges:NO];
                            
                            [oldView removeFromSuperview];
                        }];
        
        self.word = [self.words objectAtIndex:--_currentWordIndex];
        view.word = self.word;
        [view updateWordData];
        [view release];
        
        [self updateMarkOnSegmented];
    }
}

- (void)nextWordDetail
{
    if (_currentWordIndex < [self.words count]-1)
    {
        CGRect rect = _containerView.bounds;
        rect.origin.x += CGRectGetWidth(rect);
        WordDetailView *view = [[WordDetailView alloc] initWithFrame:rect];
        view.wordDetailController = self;
        [_containerView addSubview:view];
        
        WordDetailView *oldView =  [[_containerView subviews] objectAtIndex:0];
        [UIView transitionWithView:_containerView duration:0.5
                           options:UIViewAnimationOptionCurveEaseInOut
                        animations:^ {
                            view.frame = _containerView.bounds;
                            oldView.frame = CGRectMake(-CGRectGetWidth(rect), rect.origin.y, CGRectGetWidth(rect), CGRectGetHeight(rect));
                        }
                        completion:^(BOOL finished) {
                            // turn word back into a fault
                            [[DataController sharedDataController].managedObjectContext refreshObject:oldView.word mergeChanges:NO];
                            
                            [oldView removeFromSuperview];
                        }];
        
        self.word = [self.words objectAtIndex:++_currentWordIndex];
        view.word = self.word;
        [view updateWordData];
        [view release];
        
        [self updateMarkOnSegmented];
    }
}

- (void)swipeAction:(UISwipeGestureRecognizer *)recognizer
{
    if (_wordSetIndex < 0) return;
    
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [self nextWordDetail];
    }
    else
    {
        [self previousWordDetail];
    }
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    
    self.view = [[[DashboardView alloc] initWithFrame:rect] autorelease];
    
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect)-49)];
    [self.view addSubview:_containerView];
    
    WordDetailView *view = [[WordDetailView alloc] initWithFrame:_containerView.bounds];
    view.wordDetailController = self;
    [_containerView addSubview:view];
    [view release];
    
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    recognizer.delegate = self;
    [_containerView addGestureRecognizer:recognizer];
    [recognizer release];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionRight;
    recognizer.delegate = self;
    [_containerView addGestureRecognizer:recognizer];
    [recognizer release];
    
    UIImageView *segmentBg = [[UIImageView alloc] initWithFrame:CGRectMake(6, CGRectGetHeight(rect)-49, 309, 48)];
    segmentBg.tag = SEGMENT_BG_TAG;
    segmentBg.image = [UIImage imageNamed:@"segment-bg"];
    [self.view addSubview:segmentBg];
    [segmentBg release];
    
    NSArray *titles = [NSArray arrayWithObjects:@"上一页", @"点此标记为“记住”", @"下一页", nil];
    _segmentedControl = [[CustomSegmentedControl alloc]
                         initWithSegmentCount:titles.count
                         segmentsize:CGSizeMake(77, 48)
                         dividerImage:[UIImage imageNamed:@"segment-breaker"]
                         tag:1000
                         delegate:self];
    _segmentedControl.frame = CGRectMake(6, CGRectGetHeight(rect)-54, 308, 48);
    [self.view addSubview:_segmentedControl];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_navigatable == NO){
        [_segmentedControl removeFromSuperview];
        UIImageView *bg = (UIImageView *)[self.view viewWithTag:SEGMENT_BG_TAG];
        [bg removeFromSuperview];
        for (UIGestureRecognizer *recognizer in _containerView.gestureRecognizers) {
            [_containerView removeGestureRecognizer:recognizer];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    WordDetailView *view =  [[_containerView subviews] objectAtIndex:0];
    view.word = _word;
    [view updateWordData];
    [self updateMarkOnSegmented];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.words = nil;
}

#pragma mark - CustomSegmentedControlDelegate

- (void)touchDownAtSegmentIndex:(NSUInteger)segmentIndex
{
    UIButton* button = (UIButton *)[_segmentedControl viewWithTag:segmentIndex+10];
    UILabel *label = (UILabel *)[button viewWithTag:kSegmentLabelTag];
    label.textColor = [UIColor darkGrayColor];
}

- (void)touchUpInsideSegmentIndex:(NSUInteger)segmentIndex
{
    UIButton* button = (UIButton *)[_segmentedControl viewWithTag:segmentIndex+10];
    UILabel *label = (UILabel *)[button viewWithTag:kSegmentLabelTag];
    label.textColor = [UIColor colorForNormalText];
    
    switch (segmentIndex) {
        case 0:
            [self previousWordDetail];
            break;
        case 1:
            [self updateMarkOnTopBar];
            [self setHistoryListDirty:YES];
            break;
        case 2:
            [self nextWordDetail];
            break;
    }
}

- (UIButton *) buttonFor:(CustomSegmentedControl*)segmentedControl atIndex:(NSUInteger)segmentIndex;
{
    NSArray *titles = [NSArray arrayWithObjects:@"上一页", @"点此标记为“记住”", @"下一页", nil];
    
    CapLocation location;
    if (segmentIndex == 0)
        location = CapLeft;
    else if (segmentIndex == titles.count - 1)
        location = CapRight;
    else
        location = CapMiddle;
    
    UIImage* buttonImage = nil;
    UIImage* buttonPressedImage = nil;
    
    CGSize buttonSize = CGSizeMake(84, 48);
    if (segmentIndex == 1)
        buttonSize = CGSizeMake(140, 48);
    
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, buttonSize.width, buttonSize.height);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, buttonSize.width, 40)];
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor colorForNormalText];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(.5, 1);
    label.text = [titles objectAtIndex:segmentIndex];
    [button addSubview:label];
    [label release];
    
    if (location == CapLeft)
    {
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-previous"]];
        image.frame = CGRectMake(16, 23, 10, 13);
        [button addSubview:image];
        [image release];
        
        label.frame = CGRectMake(32, label.frame.origin.y, label.frame.size.width-36, label.frame.size.height);
    }
    else if (location == CapRight)
    {
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-next"]];
        image.frame = CGRectMake(button.frame.size.width-26, 23, 10, 13);
        [button addSubview:image];
        [image release];        
        
        label.frame = CGRectMake(4, label.frame.origin.y, label.frame.size.width-36, label.frame.size.height);
        label.textAlignment = UITextAlignmentRight;
    }
    else
    {
        int status = [[DataController sharedDataController] getMarkStatusBySpell:self.word.spell];
        NSString *imageName = [NSString stringWithFormat:@"mark-circle-%d", status];
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        image.tag = kSegmentMarkTag;
        label.tag = kSegmentLabelTag;

        image.frame = CGRectMake(6, 22, 12, 13);
        [button addSubview:image];
        [image release];
        
        label.frame = CGRectMake(24, label.frame.origin.y, label.frame.size.width-26, label.frame.size.height);
    }
    
    
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateSelected];
    button.adjustsImageWhenHighlighted = NO;
    return button;
}

@end