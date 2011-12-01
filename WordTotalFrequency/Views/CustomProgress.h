//
//  CustomProgress.h
//  WordTotalFrequency
//
//  Created by Perry on 11-9-3.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomProgress : UIView {
    UIImageView *_percentImage;
}

@property (nonatomic) float currentValue;

- (void)setImageName:(NSString *)imageName;

@end
