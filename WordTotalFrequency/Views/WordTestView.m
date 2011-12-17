//
//  WordTestView.m
//  WordTotalFrequency
//
//  Created by Perry on 11-8-15.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WordTestView.h"
#import "WordSetController.h"
#import "DataController.h"


@implementation WordTestView

@synthesize wordSetController = _wordSetController;
@synthesize player = _player;

- (NSArray *)getTestOptionsWithAnswer:(NSString *)answer atIndex:(NSUInteger)answerIndex
{
    int total = [_wordSetController.listingWords count];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i=0; i<3; i++){
        Word *word = [_wordSetController.listingWords objectAtIndex:rand()%total];
        [array addObject:word.translate];
        [[DataController sharedDataController].managedObjectContext refreshObject:word mergeChanges:NO];
    }
    
    [array insertObject:answer atIndex:answerIndex];
    return [array autorelease];
}

- (void)getPaperView
{
    if ([_wordSetController.testingWords count] > 0){
        Word *word = [_wordSetController.testingWords objectAtIndex:_wordSetController.currentTestWordIndex];
        if([[DataController sharedDataController] isDetailPageAutoSpeakOn]){
            
            [self performSelector:@selector(playWordSound:) withObject:word afterDelay:0.5 ];
        }
        int answerIndex = rand()%4;
        NSArray *options = [self getTestOptionsWithAnswer:word.translate atIndex:answerIndex];
        _paperView = [[WordPaperView alloc] initWithFrame:_containerView.bounds
                                                     word:word
                                                  options:options
                                                   answer:answerIndex
                                                   footer:[NSString stringWithFormat:@"%d/%d", _wordSetController.currentTestWordIndex+1, [_wordSetController.testingWords count]]
                                                 testView:self];
        _paperView.backgroundColor = [UIColor whiteColor];
        [[DataController sharedDataController].managedObjectContext refreshObject:word mergeChanges:NO];
    }
    else{
        _paperView = [[WordPaperView alloc] initWithFrame:_containerView.bounds];
        _paperView.backgroundColor = [UIColor whiteColor];
        
        UIImage *congratulation = [UIImage imageNamed:@"test-finished"];
        UIImageView *view = [[UIImageView alloc] initWithImage:congratulation];
        view.frame = CGRectMake(30, 0, congratulation.size.width, congratulation.size.height);
        [_paperView addSubview:view];
        [view release];
    }
}

- (void)playWordSound:(Word*)word{
    
    NSString *file = [[word.soundFile stringByDeletingPathExtension]
                      stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (file && [file length] > 0)
    {
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:file ofType:@"mp3"]];
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        self.player = audioPlayer;
        [fileURL release];
        [audioPlayer release];
        [self.player prepareToPlay];
        
        if([[DataController sharedDataController] isDetailPageAutoSpeakOn]){
            [self.player play];
        }
    }
}


- (void)setWordSetController:(WordSetController *)wordSetController
{
    _wordSetController = wordSetController;
    
    if (_paperView)
    {
        [_paperView removeFromSuperview];
        [_paperView release];
        _paperView = nil;
    }
    
    [self getPaperView];
    [_containerView addSubview:_paperView];
}

- (void)previousTestWord
{
    if (_wordSetController.currentTestWordIndex == 0) return;
    _wordSetController.currentTestWordIndex--;
    
    [_paperView removeFromSuperview];
    [_paperView release];
    _paperView = nil;
    
    
    [self getPaperView];
    [UIView transitionWithView:_containerView duration:0.5
                       options:UIViewAnimationOptionTransitionCurlDown
                    animations:^ { [_containerView addSubview:_paperView]; }
                    completion:nil];
}

- (void)nextTestWord
{
    if (_wordSetController.currentTestWordIndex == [_wordSetController.testingWords count]-1)
        return;
    
    _wordSetController.currentTestWordIndex++;
    [UIView transitionWithView:_containerView duration:0.5
                       options:UIViewAnimationOptionTransitionCurlUp
                    animations:^ { [_paperView removeFromSuperview]; }
                    completion:^(BOOL finished) {
                    }];
    
    [_paperView release];
    _paperView = nil;
    
    [self getPaperView];
    [_containerView addSubview:_paperView];
}

- (void)swipeAction:(UISwipeGestureRecognizer *)recognizer
{
    if ([_wordSetController.testingWords count] == 0) return;
    
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [self nextTestWord];
    }
    else
    {
        [self previousTestWord];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        
        UIImage *image = [UIImage imageNamed:@"paper"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake((rect.size.width-image.size.width)/2.0, (rect.size.height-image.size.height)/2.0, image.size.width, image.size.height);
        [self addSubview:imageView];
        [imageView release];
        
        UISwipeGestureRecognizer *recognizer;
        recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        recognizer.delegate = self;
        [self addGestureRecognizer:recognizer];
        [recognizer release];
        
        recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        recognizer.direction = UISwipeGestureRecognizerDirectionRight;
        recognizer.delegate = self;
        [self addGestureRecognizer:recognizer];
        [recognizer release];
        
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(23, 18, 270, 328)];
        [self addSubview:_containerView];
    }
    return self;
}

- (void)dealloc
{
    if (_paperView)
    {
        [_paperView release];
        _paperView = nil;
    }
    [_containerView release];
    [super dealloc];
}

@end