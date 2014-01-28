//
//  SingingBowlView.m
//  Chorale
//
//  Created by Charles Martin on 22/01/2014.
//  Copyright (c) 2014 Charles Martin. All rights reserved.
//

#import "SingingBowlView.h"
#import "ScaleMaker.h"

#define CENTER_X 512
#define CENTER_Y 384
#define ROOTTWO 1.41421356237

@interface SingingBowlView()
@property (strong,nonatomic) CALayer *rimSubLayer;
@end


@implementation SingingBowlView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        self.rimColour = [UIColor whiteColor];
        self.rimSubLayer = [[CALayer alloc] init];
        self.textColour = [UIColor whiteColor];
        [self.layer addSublayer:self.rimSubLayer];
    }
    return self;
}

-(void) drawSetup:(SingingBowlSetup *) setup
{
    // delete previous setup
    [self.rimSubLayer setSublayers:nil];
    // draw new one
    CGFloat totalRadius = [self viewRadius];
    for (int i = 0; i < [setup numberOfPitches]; i++) {
        CGFloat radius = i * totalRadius / (CGFloat) [setup numberOfPitches];
        int n = [setup pitchAtIndex:i];
        NSString *note = [SingingBowlSetup noteNameForMidiNumber:n];
        [self drawBowlRimAtRadius:radius withNote:note];
        //NSLog([NSString stringWithFormat:@"Drawing Bowl at radius: %f with pitch %d and name %@", radius,n,note]);
    }
}

-(void) drawBowlRimAtRadius:(CGFloat) radius withNote:(NSString *) note {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [[self makeCircleAtLocation:self.center radius:radius] CGPath];
    shapeLayer.strokeColor = [self.rimColour CGColor];
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 3.0;
    
    [self.rimSubLayer addSublayer:shapeLayer];
    [self.rimLayers addObject:shapeLayer];
    
    CATextLayer *noteTextLayer = [CATextLayer layer];
    CGFloat diagonaldistance = radius / ROOTTWO;
    
    noteTextLayer.string = note;
    [noteTextLayer setFont:@"HelveticaNeue"];
    noteTextLayer.fontSize = 20.f;
    noteTextLayer.alignmentMode = kCAAlignmentCenter;
    noteTextLayer.frame = CGRectMake(self.center.x + diagonaldistance, self.center.y + diagonaldistance,25.f,25.f);
    
    [self.rimSubLayer addSublayer:noteTextLayer];
    [self.rimLayers addObject:noteTextLayer];
    
}

-(CGFloat) viewRadius {
    return sqrt((self.center.x * self.center.x)+(self.center.y * self.center.y));
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

@end
