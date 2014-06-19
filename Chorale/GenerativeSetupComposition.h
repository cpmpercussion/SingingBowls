//
//  GenerativeSetupComposition.h
//  SingingBowls
//
//  Created by Charles Martin on 19/06/2014.
//  Copyright (c) 2014 Charles Martin. All rights reserved.
//

#import "SingingBowlComposition.h"

@interface GenerativeSetupComposition : SingingBowlComposition
@property (strong,nonatomic) NSArray *contents;

@property (strong,nonatomic) NSArray *rootNotes;
@property (strong,nonatomic) NSArray *scales;

@end
