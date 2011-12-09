//
//  SettingView.m
//  WordTotalFrequency
//
//  Created by Perry on 11-10-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SettingsView.h"
#import "UIColor+WTF.h"
#import "DataController.h"
#import "WordSetController.h"
#import "DataUtil.h"
#import "NSDate+Ext.h"
#import "Constant.h"
#import <sqlite3.h>

@interface SettingsView ()

- (void)markAll:(UIButton *)button;
- (void)unmarkAll:(UIButton *)button;

@end

@implementation SettingsView

@synthesize wordSetController = _wordSetController;

#define BTN_CLEAN_HISTORY 1;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 37, 200, 26)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:22];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.5, 1);
        label.text = @"设置：";
        label.textColor = [UIColor colorForNormalText];
        [self addSubview:label];
        [label release];
        
        // 1st setting
        UIImageView *dot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dot"]];
        dot.frame = CGRectMake(18, 81, 5, 5);
        [self addSubview:dot];
        [dot release];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(30, 68, 170, 50)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:15];
        label.numberOfLines = 0;
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.5, 1);
        label.text = @"将本单词集中所有单词标记为“已记住”";
        label.textColor = [UIColor colorForNormalText];
        [self addSubview:label];
        [label release];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *buttonBackground = [UIImage imageNamed:@"button-bg"];
        UIImage *newImage = [buttonBackground stretchableImageWithLeftCapWidth:7.f topCapHeight:0.f];
        [btn setBackgroundImage:newImage forState:UIControlStateNormal];
        btn.frame = CGRectMake(210, 76, 94, 34);
        [btn setTitle:@"全部标记" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(markAll:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
        [self addSubview:btn];
        
        // 2nd setting
        dot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dot"]];
        dot.frame = CGRectMake(18, 137, 5, 5);
        [self addSubview:dot];
        [dot release];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(30, 124, 174, 50)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:15];
        label.numberOfLines = 0;
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.5, 1);
        label.text = @"清除本单词集中所有标签和历史";
        label.textColor = [UIColor colorForNormalText];
        [self addSubview:label];
        [label release];
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonBackground = [UIImage imageNamed:@"button-bg"];
        newImage = [buttonBackground stretchableImageWithLeftCapWidth:7.f topCapHeight:0.f];
        [btn setBackgroundImage:newImage forState:UIControlStateNormal];
        btn.frame = CGRectMake(210, 132, 94, 34);
        [btn setTitle:@"全部清除" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(unmarkAll:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
        [self addSubview:btn];
        
        // 3rd setting
        dot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dot"]];
        dot.frame = CGRectMake(18, 193, 5, 5);
        [self addSubview:dot];
        [dot release];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(30, 180, 170, 50)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:15];
        label.numberOfLines = 0;
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.5, 1);
        label.text = @"在测验中隐藏已标记为记住的单词";
        label.textColor = [UIColor colorForNormalText];
        [self addSubview:label];
        [label release];
        
        UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(210, 188, 94, 30)];
        NSDictionary *dict = [[DataController sharedDataController] dictionaryForCategoryId:_wordSetController.wordGroup.categoryId];
        toggle.on = [[dict valueForKey:@"testMarked"] boolValue];
        [toggle addTarget:self action:@selector(toggleMarkedOnly:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:toggle];
        [toggle release];
        
        // 4th setting
        dot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dot"]];
        dot.frame = CGRectMake(18, 249, 5, 5);
        [self addSubview:dot];
        [dot release];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(30, 236, 170, 50)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:15];
        label.numberOfLines = 0;
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.5, 1);
        label.text = @"每日单词提醒，给您每天提供一个生词";
        label.textColor = [UIColor colorForNormalText];
        [self addSubview:label];
        [label release];
        
        toggle = [[UISwitch alloc] initWithFrame:CGRectMake(210, 244, 94, 30)];
        toggle.on = [[DataController sharedDataController] isNoticationOn];
        [toggle addTarget:self action:@selector(toggleNotification:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:toggle];
        [toggle release];
        
        // 5th setting
        dot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dot"]];
        dot.frame = CGRectMake(18, 305, 5, 5);
        [self addSubview:dot];
        [dot release];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(30, 292, 170, 50)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:15];
        label.numberOfLines = 0;
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.5, 1);
        label.text = @"在词条和测试页面自动朗读";
        label.textColor = [UIColor colorForNormalText];
        [self addSubview:label];
        [label release];
        
        toggle = [[UISwitch alloc] initWithFrame:CGRectMake(210, 300, 94, 30)];
        toggle.on = [[DataController sharedDataController] isDetailPageAutoSpeakOn];
        [toggle addTarget:self action:@selector(toggleAutoSpeak:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:toggle];
        [toggle release];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setWordSetController:(WordSetController *)wordSetController
{
    _wordSetController = wordSetController;
}

#pragma mark - private message


- (void)markAll:(UIButton *)button
{
    _alertType = markAllWord;
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@""
                                                     message:@"将这个单词集中\n所有的单词都标记上?"
                                                    delegate:self
                                           cancelButtonTitle:@"确认"
                                           otherButtonTitles:@"取消", nil] autorelease];
    [alert show];
}



- (void)unmarkAll:(UIButton *)button
{
    _alertType = unmarkAllWord;

    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@""
                                                     message:@"清理这个单词集中\n所有的标记和历史?"
                                                    delegate:self
                                           cancelButtonTitle:@"确认"
                                           otherButtonTitles:@"取消", nil] autorelease];
    [alert show];
}

- (void)toggleMarkedOnly:(UISwitch *)toggle
{
    NSDictionary *dict = [[DataController sharedDataController] dictionaryForCategoryId:_wordSetController.wordGroup.categoryId];
    [dict setValue:[NSNumber numberWithBool:toggle.on] forKey:@"testMarked"];
    [[DataController sharedDataController] saveSettingsDictionary];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TEST_SETTING_CHANGED_NOTIFICATION object:self];
}

- (void)toggleNotification:(UISwitch *)toggle
{
        if (toggle.on){
        
        }
        else{
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        }
    
        [[DataController sharedDataController] setNotificationOn:toggle.on];
        [[DataController sharedDataController] saveSettingsDictionary];
}

- (void)toggleAutoSpeak:(UISwitch *)toggle
{
    [[DataController sharedDataController] setDetailPageAutoSpeakOn:toggle.on];
    [[DataController sharedDataController] saveSettingsDictionary];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex==0){
    if (_alertType == markAllWord) {
        
        sqlite3 *database;
        NSString *dbPath = [[DataController sharedDataController] dbPath];
        if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
            NSString *sql = [NSString stringWithFormat:@"UPDATE ZWORD SET ZMARKSTATUS=2, ZMARKDATE='%@' WHERE ZCATEGORY=%d AND ZMARKSTATUS=0",
                             [[NSDate date] formatLongDate],
                             _wordSetController.wordGroup.categoryId];
            sqlite3_stmt *statement;
            if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
                sqlite3_step(statement);
            }
            sqlite3_finalize(statement);
        } else {
            NSLog(@"failed open db");
        }
        sqlite3_close(database);
        database = NULL;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HISTORY_CHANGED_NOTIFICATION object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:BATCH_MARKED_NOTIFICATION object:self];
        
    }else if(_alertType==unmarkAllWord){
        if (buttonIndex == 0) {
            sqlite3 *database;
            NSString *dbPath = [[DataController sharedDataController] dbPath];
            if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
                NSString *sql = [NSString stringWithFormat:@"UPDATE ZWORD SET ZMARKSTATUS=0, ZMARKDATE='' WHERE ZCATEGORY=%d AND ZMARKSTATUS>0", _wordSetController.wordGroup.categoryId];
                sqlite3_stmt *statement;
                if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
                    sqlite3_step(statement);
                }
                sqlite3_finalize(statement);
            } else {
                NSLog(@"failed open db");
            }
            sqlite3_close(database);
            database = NULL;
        
            [[NSNotificationCenter defaultCenter] postNotificationName:HISTORY_CHANGED_NOTIFICATION object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:BATCH_MARKED_NOTIFICATION object:self];
        }
    }
    }
}

@end
