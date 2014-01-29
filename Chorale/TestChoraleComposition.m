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
    //self.contents = @[@[@36,@37,@38],@[@36,@39,@43,@47,@51,@58,@62,@76,@80],@[@60],@[@63,@84],@[@40,@37,@38,@39]];
    self.contents = @[@[@34],
                      @[@34, @58],
                      @[@34, @36, @58],
                      @[@34, @36, @46, @58],
                      @[@34, @36, @46, @48, @50],
                      @[@34, @36, @43, @46, @48, @50],
                      @[@34, @36, @38, @43, @46, @48, @50],
                      @[@34, @36, @38, @43, @46, @48, @50, @53],
                      @[@34, @36, @38, @41, @43, @46, @48, @50, @53, @55],
                      @[@32, @33, @35, @40, @42, @44, @45, @47, @52, @54],
                      @[@32, @33, @35, @42, @44, @45, @47, @54],
                      @[@32, @33, @42, @44, @45, @54],
                      @[@32, @42, @44, @54],
                      @[@32, @42],
                      @[@32]];
    return self;
}

//-(NSArray *) contents {
//    if (!_contents) {
//        
//    }
//    return _contents
//}


@end
