//
//  SingingBowlView.h
//  Chorale
//
//  Created by Charles Martin on 22/01/2014.
//  Copyright (c) 2014 Charles Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingingBowlSetup.h"



@interface SingingBowlView : UIView
-(void) drawSetup:(SingingBowlSetup *) setup;
-(void) drawBowlRimAtRadius:(CGFloat) radius withNote:(NSString *) note;

@property (strong,nonatomic) UIColor *rimColour;
@property (strong,nonatomic) UIColor *textColour;
@property (strong, nonatomic) NSMutableArray* rimLayers;


@end