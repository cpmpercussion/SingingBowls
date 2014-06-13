//
//  NoteColours.m
//  SingingBowls
//
//  Created by Charles Martin on 13/06/2014.
//  Copyright (c) 2014 Charles Martin. All rights reserved.
//

#import "NoteColours.h"

// DeMaistre
// C #d7a039
// C# #94a754
// D #757e38
// D# #5c8f75
// E #599bcd
// F #688f98
// F# #8786cb
// G #82475e
// G# #be5b70
// A #d92c2c
// A# #ac2b29

// Newton
// C
// C#
// D
// D#
// E
// F
// F#
// G
// G#
// A
// A#

#define DEMAISTRE @[@39.0,@74.0,@68.0,@149.0,@206.0,@191.0,@241.0,@337.0,@347.0,@0.0,@10.0]

#define NEWTON

@implementation NoteColours

+ (UIColor *) colourForNote:(int) midiNumber {
    int midiDegree = midiNumber % 12;
    return [UIColor colorWithHue:[DEMAISTRE[midiDegree] floatValue]/360.0 saturation:0.8 brightness:1 alpha:1];
}

+ (UIColor *) colourForNote:(int) midiNumber withSaturation:(float) sat {
    int midiDegree = midiNumber % 12;
    return [UIColor colorWithHue:[DEMAISTRE[midiDegree] floatValue]/360.0 saturation:sat brightness:1 alpha:1];
}


@end

