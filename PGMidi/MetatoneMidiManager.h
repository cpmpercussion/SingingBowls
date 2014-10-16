//
//  MetatoneMidiManager.h
//  SnowMusic
//
//  Created by Charles Martin on 16/10/2014.
//  Copyright (c) 2014 Charles Martin Percussion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGMidi.h"
#import "PGArc.h"
#import "PDBase.h"


@interface MetatoneMidiManager : NSObject <PGMidiDelegate, PGMidiSourceDelegate>

@property (strong, nonatomic) PGMidi *midi;

-(void) setupMidi;

@end
