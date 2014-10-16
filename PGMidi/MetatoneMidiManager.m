//
//  MetatoneMidiManager.m
//  SnowMusic
//
//  Created by Charles Martin on 16/10/2014.
//  Copyright (c) 2014 Charles Martin Percussion. All rights reserved.
//

#import "MetatoneMidiManager.h"

@implementation MetatoneMidiManager

- (MetatoneMidiManager *) init {
    self = [super init];
    [self setupMidi];
    return self;
}

- (void) setupMidi {
    self.midi = [[PGMidi alloc] init];
    self.midi.networkEnabled = YES;
}

#pragma mark Midi
-(void) attachToAllExistingSources
{
    for (PGMidiSource *source in self.midi.sources)
    {
        [source addDelegate:self];
    }
}

-(void) setMidi:(PGMidi*)m {
    _midi = m;
    self.midi.delegate = self;
    [self attachToAllExistingSources];
    NSLog(@"MIDI: Setting up.");
}

-(void) midi:(PGMidi*)midi sourceAdded:(PGMidiSource *)source {
    [source addDelegate:self];
    NSLog(@"Midi Source Added");
}

-(void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source {
    NSLog(@"Midi Source Removed");
}

-(void) midi:(PGMidi*)midi destinationAdded:(PGMidiDestination *)destination{}

-(void) midi:(PGMidi*)midi destinationRemoved:(PGMidiDestination *)destination {}


-(void) midiSource:(PGMidiSource *)input midiReceived:(const MIDIPacketList *)packetList
{
    const MIDIPacket *packet = &packetList->packet[0];
    for (int i = 0; i < packetList->numPackets; ++i) {
        if ((packet->length == 3) && ((packet->data[0] & 0xf0) == 0x90) && (packet->data[2] != 0)) {
            [PdBase sendNoteOn:1 pitch:packet->data[1] velocity:packet->data[2]];
        }
        packet = MIDIPacketNext(packet);
    }
}
@end

