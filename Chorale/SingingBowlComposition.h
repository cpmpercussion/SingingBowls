//
//  SingingBowlComposition.h
//  Chorale
//
//  Created by Charles Martin on 28/01/2014.
//  Copyright (c) 2014 Charles Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingingBowlComposition : NSObject

@property (strong,nonatomic) NSArray *contents;
- (NSArray *) firstSetup;
- (NSArray *) previousSetup;
- (NSArray *) nextSetup;
- (NSArray *) setupForState: (int) state;
- (int) numberOfSetups;

@end
