//
//  SingingBowlSetup.h
//  Chorale
//
//  Created by Charles Martin on 22/01/2014.
//  Copyright (c) 2014 Charles Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingingBowlSetup : NSObject

-(SingingBowlSetup *) initWithPitches:(NSMutableArray *) pitches;
@property (strong, nonatomic) NSMutableArray *pitches;

+(NSString *) noteNameForMidiNumber:(int) midinumber;
-(int) numberOfPitches;
-(int) pitchAtIndex:(int) index;
-(int) pitchAtRadius:(CGFloat) radius;

@end
