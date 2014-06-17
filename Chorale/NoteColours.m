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

// HSV values have Hue measured in degrees (derp).

// DeMaistre mapping from screenshot of colour music paintings, fudged a bit to make it work.
#define DEMAISTRE @[@39.0,@68.0,@74.0,@149.0,@191.0,@206.0,@241.0,@337.0,@347.0,@0.0,@10.0]


// Charles mapping evenly distributed around the HSV colour space, with A = red
#define CHARLES @[@60.0,@90.0,@120.0,@150.0,@180.0,@210.0,@240.0,@270.0,@300.0,@330.0,@0.0,@30.0]

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

