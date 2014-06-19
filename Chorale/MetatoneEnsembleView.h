//
//  MetatoneEsembleView.h
//  SingingBowls
//
//  Created by Charles Martin on 17/06/2014.
//  Copyright (c) 2014 Charles Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MetatoneEnsembleView : UIView
@property NSMutableDictionary *metatoneEnsembleAddresses;
@property NSMutableDictionary *ensembleLayers;
@property CALayer *ensembleLayerContainer;

-(void) drawEnsemble:(NSMutableDictionary *)newEnsembleDictionary;

@end
