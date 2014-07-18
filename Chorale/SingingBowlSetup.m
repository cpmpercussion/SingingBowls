//
//  SingingBowlSetup.m
//  Chorale
//
//  Created by Charles Martin on 22/01/2014.
//  Copyright (c) 2014 Charles Martin. All rights reserved.
//

#import "SingingBowlSetup.h"

#define NOTENAMES @[@"C",@"C#",@"D",@"D#",@"E",@"F",@"F#",@"G",@"G#",@"A",@"A#",@"B",]


@implementation SingingBowlSetup

- (NSMutableArray *) pitches {
    if (!_pitches) {
        _pitches = [NSMutableArray init];
    }
    return _pitches;
}

- (SingingBowlSetup *) initWithPitches:(NSMutableArray *)pitches {
    self = [super init];
    self.pitches = pitches;
    return self;
}

- (int) numberOfPitches
{
    return (int) [self.pitches count];
}

- (int) pitchAtIndex:(int)index
{
    NSNumber *n = (NSNumber *) [self.pitches objectAtIndex:index];
    return [n intValue];
}

- (int) pitchAtRadius:(CGFloat)radius
{
    int pitchNumber = floor(radius * [self numberOfPitches]);
    pitchNumber = MIN(pitchNumber,([self numberOfPitches]-1));
    return [((NSNumber *) [self.pitches objectAtIndex:pitchNumber]) intValue];
}


+(NSString *) noteNameForMidiNumber:(int) midinumber
{
    return NOTENAMES[midinumber % 12];
}

@end
