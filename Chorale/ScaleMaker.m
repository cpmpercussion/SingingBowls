//
//  ScaleMaker.m
//  Metatone ENP
//
//  Created by Charles Martin on 6/07/13.
//  Copyright (c) 2013 Charles Martin. All rights reserved.
//

#import "ScaleMaker.h"

#define DEGREE @[@1,@2,@3,@4,@5,@6,@7]
#define LYDFIVE @[@0,@2,@4,@6,@8,@9,@11]
#define LYDIAN @[@0,@2,@4,@6,@7,@9,@11]
#define MAJOR @[@0,@2,@4,@5,@7,@9,@11]
#define MIXOLYDIAN @[@0,@2,@4,@5,@7,@9,@10]
#define DORIAN @[@0,@2,@3,@5,@7,@9,@10]
#define MINOR @[@0,@2,@3,@5,@7,@8,@10]
#define PHRYGIAN @[@0,@1,@3,@5,@7,@8,@10]
#define LOCHRIAN @[@0,@1,@3,@5,@6,@8,@10]
#define MIXOFLATSIX @[@0,@2,@4,@5,@7,@8,@10]
#define OCTATONIC @[@0,@2,@3,@5,@6,@8,@9,@11]
#define WHOLETONE @[@0,@2,@4,@6,@8,@10]

@implementation ScaleMaker

+(int)lydianSharpFive:(int)base withNote:(int)note {
    NSArray *scale = LYDFIVE;
    
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    //NSLog([NSString stringWithFormat:@"Scale calc in:%d, octave: %d, scalenote: %d, base: %d",
    //       note,octave,scalenote,base]);
    
    return (octave * 12) + scalenote + base;
}

+(int)lydian:(int)base withNote:(int)note {
    NSArray *scale = LYDIAN;
    
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    //NSLog([NSString stringWithFormat:@"Scale calc in:%d, octave: %d, scalenote: %d, base: %d",
    //       note,octave,scalenote,base]);
    
    return base  + (octave * 12) + scalenote;
}

+(int)major:(int)base withNote:(int)note {
    NSArray *scale = MAJOR;
    
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    //NSLog([NSString stringWithFormat:@"Scale calc in:%d, octave: %d, scalenote: %d, base: %d",
    //       note,octave,scalenote,base]);
    
    return base  + (octave * 12) + scalenote;
}

+(int)dorian:(int)base withNote:(int)note {
    NSArray *scale = DORIAN;
    
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    
    //NSLog([NSString stringWithFormat:@"Scale calc in:%d, octave: %d, scalenote: %d, base: %d",
    //       note,octave,scalenote,base]);
    
    return base  + (octave * 12) + scalenote;
}

+(int)mixolydian:(int)base withNote:(int)note {
    NSArray *scale = MIXOLYDIAN;
    
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    
    //NSLog([NSString stringWithFormat:@"Scale calc in:%d, octave: %d, scalenote: %d, base: %d",
    //       note,octave,scalenote,base]);
    
    return base  + (octave * 12) + scalenote;
}

+(int)aeolian:(int)base withNote:(int)note {
    NSArray *scale = MINOR;
    
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    
    //NSLog([NSString stringWithFormat:@"Scale calc in:%d, octave: %d, scalenote: %d, base: %d",
    //       note,octave,scalenote,base]);
    
    return base  + (octave * 12) + scalenote;
}

+(int)phrygian:(int)base withNote:(int)note {
    NSArray *scale = PHRYGIAN;
    
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    
    //NSLog([NSString stringWithFormat:@"Scale calc in:%d, octave: %d, scalenote: %d, base: %d",
    //       note,octave,scalenote,base]);
    
    return base  + (octave * 12) + scalenote;
}


+(int)lochrian:(int)base withNote:(int)note {
    NSArray *scale = LOCHRIAN;
    
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    
    //NSLog([NSString stringWithFormat:@"Scale calc in:%d, octave: %d, scalenote: %d, base: %d",
    //       note,octave,scalenote,base]);
    
    return base  + (octave * 12) + scalenote;
}

+(int)mixoFlatSix:(int)base withNote:(int)note {
    NSArray *scale = MIXOFLATSIX;
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    return base  + (octave * 12) + scalenote;
}

+(int)octatonic:(int)base withNote:(int)note {
    NSArray *scale = OCTATONIC;
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    return base  + (octave * 12) + scalenote;
}

+(int)wholeTone:(int)base withNote:(int)note {
    NSArray *scale = WHOLETONE;
    int octave = note / [scale count];
    int scalenote = [scale[note % [scale count]] intValue];
    return base  + (octave * 12) + scalenote;
}


+(int) noteForScale:(NSString *)scale withBase:(int)base withNote:(int)note {
    if ([scale isEqualToString:@"LOCHRIAN"]) {
        return [self lochrian:base withNote:note];
    }
    if ([scale isEqualToString:@"PHRYGIAN"]) {
        return [self phrygian:base withNote:note];
    }
    if ([scale isEqualToString:@"AEOLIAN"]) {
        return [self aeolian:base withNote:note];
    }
    if ([scale isEqualToString:@"DORIAN"]) {
        return [self dorian:base withNote:note];
    }
    if ([scale isEqualToString:@"MIXOLYDIAN"]) {
        return [self mixolydian:base withNote:note];
    }
    if ([scale isEqualToString:@"MAJOR"]) {
        return [self major:base withNote:note];
    }
    if ([scale isEqualToString:@"LYDIAN"]) {
        return [self lydian:base withNote:note];
    }
    if ([scale isEqualToString:@"LYDIANSHARPFIVE"]) {
        return [self lydianSharpFive:base withNote:note];
    }
    if ([scale isEqualToString:@"MIXOFLATSIX"]) {
        return [self mixoFlatSix:base withNote:note];
    }
    if ([scale isEqualToString:@"OCTATONIC"]) {
        return [self octatonic:base withNote:note];
    }
    if ([scale isEqualToString:@"WHOLETONE"]) {
        return [self wholeTone:base withNote:note];
    }
    
    return [self major:base withNote:note];
}

@end
