//
//  SingingBowlComposition.m
//  Chorale
//
//  Created by Charles Martin on 28/01/2014.
//  Copyright (c) 2014 Charles Martin. All rights reserved.
//

#import "SingingBowlComposition.h"

@interface SingingBowlComposition()
@property int index;
@end

@implementation SingingBowlComposition

- (NSArray *) firstSetup {
    self.index = 0;
    return [self.contents objectAtIndex:self.index];
}
- (NSArray *) previousSetup {
    if (self.index > 0) {
        self.index--;
    }
    return [self.contents objectAtIndex:self.index];
}
- (NSArray *) nextSetup {
    if (self.index + 1 < [self.contents count]) {
        self.index++;
    }
    return [self.contents objectAtIndex:self.index];
}

- (NSArray *) setupForState:(int)state {
    if (state < 0 ) return nil;
    
    if (state <0) {
        self.index = 0;
    } else if (state < [self.contents count]) {
        self.index = state;
    } else {
        self.index = [self.contents count] - 1;
    }
    return [self.contents objectAtIndex:self.index];
}

- (int) numberOfSetups {
    return [self.contents count];
}

@end
