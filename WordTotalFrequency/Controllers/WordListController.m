//
//  WordListController.m
//  WordTotalFrequency
//
//  Created by OCS on 11-7-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WordListController.h"
#import "WordDetailController.h"
#import "Word.h"
#import "DataController.h"
#import "WordListCell.h"
#import "UIColor+WTF.h"
#import "WordTotalFrequencyAppDelegate.h"


@implementation WordListController

@synthesize delegate = _delegate;

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize searchString = _searchString;
@synthesize wordSetController = _wordSetController;
@synthesize wordSetIndex = _wordSetIndex;
@synthesize listType = _listType;

static NSString *predicateString;
static NSPredicate *searchPredicate;

- (NSArray *)wordsArray
{
    if (_fetchedResultsController != nil){
        return _fetchedResultsController.fetchedObjects;
    }
    return nil;
}

- (id)initWIthListType:(WordListType)listType
{
    if ((self = [super init]))
    {
        _listType = listType;
        self.wordSetIndex = -1;
    }
    return self;
}

- (void)dealloc
{
    if (_fetchedResultsController != nil){
        _fetchedResultsController.delegate = nil;
        [_fetchedResultsController release];
        _fetchedResultsController = nil;
    }
    
    [_searchString release];
    
    [predicateString release];
    predicateString = nil;
    [searchPredicate release];
    searchPredicate = nil;
    
    [super dealloc];
}

- (void)forceUpdateDataSource
{
    if (_wordSetIndex > -1)
    {
        self.tableView.backgroundColor = [UIColor colorForTheme];
        if (_listType == WordListTypeWordSet)
            [self.fetchedResultsController.fetchRequest
             setPredicate:[NSPredicate predicateWithFormat:@"category = %d", _wordSetIndex]];
        else
            [self.fetchedResultsController.fetchRequest
             setPredicate:[NSPredicate predicateWithFormat:@"category = %d and markStatus > 0", _wordSetIndex]];
    }
    else
    {
        self.tableView.backgroundColor = [UIColor colorWithRed:203.0/255 green:234.0/255 blue:1.0 alpha:1.0];
    }
    
    if (_wordSetIndex > -1 || _searchString)
    {
        dispatch_queue_t main_queue = dispatch_get_main_queue();
        dispatch_queue_t request_queue = dispatch_queue_create("com.app.biterice", NULL);
        
        __block __typeof__(self) blockSelf = self;
        
        dispatch_async(request_queue, ^{
            if (_wordSetIndex > -1)
                [blockSelf.fetchedResultsController.fetchRequest setFetchLimit:20];
            
            NSError *error;
            if (![blockSelf.fetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                exit(-1);  // Fail
            }
            
            dispatch_sync(main_queue, ^{
                [blockSelf.tableView reloadData];
                
                if (_wordSetIndex > -1 && 
                    [blockSelf.fetchedResultsController.fetchedObjects count] == 20){
                    dispatch_async(request_queue, ^{
                        //[blockSelf.fetchedResultsController.fetchRequest setFetchOffset:20];
                        [blockSelf.fetchedResultsController.fetchRequest setFetchLimit:0];
                        
                        NSError *error;
                        if (![blockSelf.fetchedResultsController performFetch:&error]) {
                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                            exit(-1);  // Fail
                        }
                        
                        dispatch_sync(main_queue, ^{
                            [blockSelf.tableView reloadData];
                            // load scroll index
                            NSDictionary *dict = [[DataController sharedDataController] dictionaryForCategoryId:_wordSetIndex];
                            int topIndex = [[dict valueForKey:@"listTopWordIndex"] intValue];
                            if (topIndex > 0 && _listType == WordListTypeWordSet){
                                NSUInteger ii[2] = {0, topIndex};
                                NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
                                [blockSelf.tableView scrollToRowAtIndexPath:indexPath
                                                           atScrollPosition:UITableViewScrollPositionTop
                                                                   animated:YES];
                            }
                            
                            dispatch_release(request_queue);
                        });
                    });
                }
                else{
                    dispatch_release(request_queue);
                }
            });
        });
    }
}


- (void)setSearchString:(NSString *)searchString
{
    if (predicateString == nil){
        predicateString = [[NSString stringWithFormat:@"$SEARCH_TEXT <= spell AND spell < $SEARCH_TEXT_2"] retain];
        searchPredicate = [[NSPredicate predicateWithFormat:predicateString] retain];
    }
    
    searchString = [searchString lowercaseString];
    if (YES /*_searchString != searchString*/)
    {
        [_searchString release];
        _searchString = [searchString copy];
        
        [NSFetchedResultsController deleteCacheWithName:nil];
        if ([searchString isEqualToString:@""])
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"1 = -1"];
            [self.fetchedResultsController.fetchRequest setPredicate:predicate];
        }
        else
        {
            unichar chr = [searchString characterAtIndex:[searchString length]-1];
            NSString *searchString2 = [NSString stringWithFormat:@"%@%c", [searchString substringToIndex:[searchString length]-1], chr+1];
            NSDictionary *variables = [NSDictionary
                                       dictionaryWithObjects:[NSArray arrayWithObjects:searchString,
                                                              searchString2, nil]
                                       forKeys:[NSArray arrayWithObjects:@"SEARCH_TEXT", @"SEARCH_TEXT_2", nil]];
            NSPredicate *localPredicate = [searchPredicate predicateWithSubstitutionVariables:variables];
            [self.fetchedResultsController.fetchRequest setPredicate:localPredicate];
        }
        
        
        dispatch_queue_t main_queue = dispatch_get_main_queue();
        dispatch_queue_t request_queue = dispatch_queue_create("com.app.biterice", NULL);
        
        __block __typeof__(self) blockSelf = self;
        
        dispatch_async(request_queue, ^{
            NSError *error;
            if (![blockSelf.fetchedResultsController performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                exit(-1);  // Fail
            }
            
            dispatch_sync(main_queue, ^{
                [blockSelf.tableView reloadData];
                
                dispatch_release(request_queue);
            });
        });
    }
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.separatorColor = [UIColor colorWithWhite:1.f alpha:.5f];
    
    [self forceUpdateDataSource];
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [_fetchedResultsController.sections objectAtIndex:section];
    if (_wordSetIndex > -1)
    {
        return [sectionInfo numberOfObjects];        
    }
    return MIN(30, [sectionInfo numberOfObjects]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    WordListCell *cell = (WordListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[WordListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.wordSetController = _wordSetController;
        cell.ownerTable = tableView;
    }
    
    cell.word = [_fetchedResultsController objectAtIndexPath:indexPath];    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Word *word = (Word *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    [self.delegate willSelectWord:word];
    [self.delegate willSelectWord:word];
    
    WordDetailController *controller = [[WordDetailController alloc] init];
    controller.word = word;
    controller.words = _wordSetController.fetchedWordResultsController.fetchedObjects;
    controller.wordSetIndex = self.wordSetIndex;
    controller.currentWordIndex = indexPath.row;
    controller.wordSetController = self.wordSetController;
    controller.wordListController = self;
    controller.navigatable = (_listType != WordListTypeSearchResult);
    
    WordTotalFrequencyAppDelegate *del = (WordTotalFrequencyAppDelegate *)[UIApplication sharedApplication].delegate;
    [del.navigationController pushViewController:controller animated:YES];
    [controller release];
}


#pragma mark -- Fetched Results Controller

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
	// Create and configure a fetch request with the Book entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Word"
                                              inManagedObjectContext:[DataController sharedDataController].managedObjectContext];
	[fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    if (_listType == WordListTypeWordSet || _listType == WordListTypeSearchResult){
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"rank" ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:descriptor]];
        [descriptor release];
    }
    else{
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"markDate" ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:descriptor]];
        [descriptor release];
    }
    NSArray *propertiesToFetch = [[NSArray alloc] initWithObjects:@"markStatus", @"spell", @"translate", nil];
    [fetchRequest setPropertiesToFetch:propertiesToFetch];
    [propertiesToFetch release];


    [fetchRequest setFetchBatchSize:20];
    	
	// Create and initialize the fetch results controller.
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:fetchRequest
                                                             managedObjectContext:[DataController sharedDataController].managedObjectContext
                                                             sectionNameKeyPath:nil cacheName:nil];
	_fetchedResultsController = [aFetchedResultsController retain];
	_fetchedResultsController.delegate = self;
	
	// Memory management.
	[aFetchedResultsController release];
	[fetchRequest release];
	return _fetchedResultsController;
}

@end
