//
//  MetatoneEsembleView.m
//  SingingBowls
//
//  Created by Charles Martin on 17/06/2014.
//  Copyright (c) 2014 Charles Martin. All rights reserved.
//

#import "MetatoneEnsembleView.h"

@implementation MetatoneEnsembleView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Init code.
        self.backgroundColor = [UIColor clearColor];
        self.ensembleLayerContainer = [[CALayer alloc] init];
        self.ensembleLayers = [[NSMutableDictionary alloc] init];
        [self.layer addSublayer:self.ensembleLayerContainer];
        
        NSLog(@"Center is: %f, %f", self.center.x, self.center.y);
    }
    return self;
}

-(void) drawEnsemble:(NSMutableDictionary *)newEnsembleDictionary {
    self.metatoneEnsembleAddresses = [newEnsembleDictionary copy];
    // draw the new ensemble
    [self updateEnsembleDrawing];
}

-(void) updateEnsembleDrawing {
    [self.ensembleLayerContainer setSublayers:nil];
    self.ensembleLayers = [[NSMutableDictionary alloc] init];

    for (NSString *hostname in [self.metatoneEnsembleAddresses keyEnumerator]) {
        CGPoint location = CGPointMake(self.center.x - 350 + arc4random_uniform(350), 50);
//        (self.center.y, self.center.x - 5 + arc4random_uniform(10));
        NSLog(@"Drawing Player for: %@ at location: %f, %f", hostname, location.x, location.y);
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [[self makeCircleAtLocation:location radius:30] CGPath];
        shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
        shapeLayer.fillColor = [[UIColor blueColor] CGColor];
        shapeLayer.lineWidth = 2.0;
        
        [self.ensembleLayerContainer addSublayer:shapeLayer];
        [self.ensembleLayers setObject:shapeLayer forKey:hostname];
    }
}


- (UIBezierPath *)makeCircleAtLocation:(CGPoint)location radius:(CGFloat)radius
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:location
                    radius:radius
                startAngle:0.0
                  endAngle:M_PI * 2.0
                 clockwise:YES];
    return path;
}


//-(void) drawBowlRimAtRadius:(CGFloat) radius withNote:(NSString *) note {
//    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
//    shapeLayer.path = [[self makeCircleAtLocation:self.center radius:radius] CGPath];
//    shapeLayer.strokeColor = [self.rimColour CGColor];
//    shapeLayer.fillColor = nil;
//    shapeLayer.lineWidth = 3.0;
//
//    [self.rimSubLayer addSublayer:shapeLayer];
//    [self.rimLayers addObject:shapeLayer];
//
//    if (DISPLAYNOTENAME) {
//        CATextLayer *noteTextLayer = [CATextLayer layer];
//        CGFloat diagonaldistance = radius / ROOTTWO;
//
//        noteTextLayer.string = note;
//        [noteTextLayer setFont:@"HelveticaNeue"];
//        noteTextLayer.fontSize = 20.f;
//        noteTextLayer.alignmentMode = kCAAlignmentCenter;
//        noteTextLayer.frame = CGRectMake(self.center.x + diagonaldistance, self.center.y + diagonaldistance,25.f,25.f);
//
//        [self.rimSubLayer addSublayer:noteTextLayer];
//        [self.rimLayers addObject:noteTextLayer];
//    }
//}




@end
