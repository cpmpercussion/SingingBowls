//
//  NoteColours.h
//  SingingBowls
//
//  Created by Charles Martin on 13/06/2014.
//  Copyright (c) 2014 Charles Martin. All rights reserved.
//

#import "SingingBowlComposition.h"

@interface NoteColours : SingingBowlComposition
+ (UIColor *) colourForNote:(int) midiNumber;
+ (UIColor *) colourForNote:(int) midiNumber withSaturation:(float) sat;
@end
