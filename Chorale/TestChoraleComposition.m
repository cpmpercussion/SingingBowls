//
//  TestChoraleComposition.m
//  Chorale
//
//  Created by Charles Martin on 28/01/2014.
//  Copyright (c) 2014 Charles Martin. All rights reserved.
//

#import "TestChoraleComposition.h"

@implementation TestChoraleComposition

- (TestChoraleComposition *) init {
    self = [super init];
    self.contents = @[@[@36,@37,@38],@[@36,@39,@43,@47,@51,@58,@62,@76,@80],@[@60],@[@63,@84],@[@40,@37,@38,@39]];
    return self;
}

//-(NSArray *) contents {
//    if (!_contents) {
//        
//    }
//    return _contents
//}


@end
