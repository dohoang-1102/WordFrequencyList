//
//  SettingView.h
//  WordTotalFrequency
//
//  Created by Perry on 11-10-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    unmarkAllWord   = 0,
    markAllWord     = 1
} AlertType;

@class WordSetController;


@interface SettingsView : UIView<UIAlertViewDelegate> {
    AlertType _alertType;
    
}

@property (nonatomic, assign) WordSetController *wordSetController;

@end
