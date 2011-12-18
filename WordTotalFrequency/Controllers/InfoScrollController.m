//
//  InfoScrollController.m
//  WordTotalFrequency
//
//  Created by Perry on 11-11-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "InfoScrollController.h"
#import "UIColor+WTF.h"

static NSUInteger kNumberOfPages = 6;

@interface InfoScrollController ()
- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
@end

@implementation InfoScrollController

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize pageImages = _pageImages;
@synthesize displayType = _displayType;
- (void)dealloc
{
    [_closeButton release];
    [_scrollView release];
    [_pageControl release];
    [_pageImages release];
    [super dealloc];
}

- (id)initWithDisplayType:(InfoScrollType)displayType
{
    if ((self = [super init]))
    {
        _displayType = displayType;
        if (_displayType == firstLoad) {
            kNumberOfPages  = 6;
        }
        else if (_displayType == normalLoad){
            kNumberOfPages  = 5;
        }
    }
    return self;
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:NO];
}



#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect rect     = [UIScreen mainScreen].applicationFrame;
    UIView *view    = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor colorForTheme];
    self.view = view;
    [view release];
    
    // scroll view
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_scrollView];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++)
    {
		[images addObject:[NSNull null]];
    }
    self.pageImages = images;
    [images release];
    
    // a page is the width of the scroll view
    _scrollView.bounces         = NO;
    _scrollView.pagingEnabled   = YES;
    _scrollView.contentSize     = CGSizeMake(_scrollView.frame.size.width * kNumberOfPages, _scrollView.frame.size.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop    = NO;
    _scrollView.delegate        = self;
    
    // page controll
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 438, 320, 20)];
    _pageControl.numberOfPages = kNumberOfPages;
    _pageControl.currentPage = 0;
    [self.view addSubview:_pageControl];
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    
    if (_displayType == firstLoad) {
        _closeButton        = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _closeButton.frame  = CGRectMake((kNumberOfPages-1)*320+62, 158, 105, 105);
        _closeButton.showsTouchWhenHighlighted = YES;
        [_closeButton setImage:[UIImage imageNamed:@"Icon@2x.png"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:_closeButton];
    }
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    
    // replace the placeholder if necessary
    UIView *imageView = [_pageImages objectAtIndex:page];
    if ((NSNull *)imageView == [NSNull null])
    {
        imageView = [[UIView alloc] initWithFrame:self.view.bounds];
        [_pageImages replaceObjectAtIndex:page withObject:imageView];
        [imageView release];
    }
    
    // add the controller's view to the scroll view
    if (imageView.superview == nil)
    {
        CGRect frame = _scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        imageView.frame = frame;
        [_scrollView insertSubview:imageView atIndex:0];
        
        imageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"info%d", page]]];
        
        if (_displayType == normalLoad) {
            UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
            close.frame = CGRectMake(280, -1, 44, 44);
            close.showsTouchWhenHighlighted = YES;
            [close setImage:[UIImage imageNamed:@"close-btn"] forState:UIControlStateNormal];
            [close addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
            [imageView addSubview:close];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

@end
