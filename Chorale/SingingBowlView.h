//
//  SingingBowlView.h
//  Chorale
//
//  Created by Charles Martin on 22/01/2014.
//  Copyright (c) 2014 Charles Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingingBowlSetup.h"
#import "NoteColours.h"



@interface SingingBowlView : UIView
-(void) drawSetup:(SingingBowlSetup *) setup;
-(void) drawBowlRimAtRadius:(CGFloat) radius withNote:(NSString *) note;
-(void) continuouslyAnimateBowlAtRadius:(CGFloat) radius;
-(void) changeBowlVolumeTo:(CGFloat) level;
-(void) changeContinuousAnimationSpeed:(CGFloat) speed;
-(void) stopAnimatingBowl;
-(void) changeContinuousColour:(CGFloat) amount forRadius:(CGFloat)radius;

@property (strong,nonatomic) UIColor *rimColour;
@property (strong,nonatomic) UIColor *textColour;
@property (strong,nonatomic) UIColor *tapColour;
@property (strong,nonatomic) UIColor *swirlColour;
@property (strong, nonatomic) NSMutableArray* rimLayers;


@end