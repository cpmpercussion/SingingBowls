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
#define DISPLAYNOTENAME false

@interface SingingBowlView()
@property (strong,nonatomic) CALayer *rimSubLayer;
@property (strong,nonatomic) NSMutableDictionary *continuousEdgeLayers;
@property (strong,nonatomic) NSMutableDictionary *tapEdgeLayers;
@property (weak,nonatomic) SingingBowlSetup* currentSetup;
@property (nonatomic) CGFloat totalRadius;
@end


@implementation SingingBowlView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
//        self.backgroundColor = [UIColor blackColor];
        self.backgroundColor = [UIColor clearColor];

        self.rimColour = [UIColor whiteColor];
        self.textColour = [UIColor whiteColor];
        self.tapColour = [UIColor blueColor];
        self.swirlColour = [UIColor greenColor];
        
        self.rimSubLayer = [[CALayer alloc] init];
        [self.layer addSublayer:self.rimSubLayer];
        self.multipleTouchEnabled = YES;
        self.totalRadius = [self viewRadius];
    }
    return self;
}

-(void) drawSetup:(SingingBowlSetup *) setup
{
    // delete previous setup
    [self.rimSubLayer setSublayers:nil];
    self.continuousEdgeLayers = [NSMutableDictionary dictionary];
    self.tapEdgeLayers = [NSMutableDictionary dictionary];
    self.currentSetup = setup;

    // draw new one
    CGFloat totalRadius = [self viewRadius];
    CGFloat edgeWidth = totalRadius / (CGFloat) [setup numberOfPitches];
    //CGFloat tapEdgeWidth = 0.0;
    
    for (int i = 0; i < [setup numberOfPitches]; i++) {
        // draw the rim.
        CGFloat rimradius = i * edgeWidth;
        int noteNumber = [setup pitchAtIndex:i];
        NSString *note = [SingingBowlSetup noteNameForMidiNumber:noteNumber];
        [self drawBowlRimAtRadius:rimradius withNote:note];
        
        // setup for rim layers:
        CGFloat rimCenter = (i + 0.5) * edgeWidth;
        
        // make continuous rim layer
        CAShapeLayer* continuousLayer = [self makeBowlLayerAtRadius:rimCenter withColour:[NoteColours colourForNote:noteNumber withSaturation:0.6] ofWidth:edgeWidth];
        [self.continuousEdgeLayers setObject:continuousLayer forKey:[NSNumber numberWithInt:noteNumber]];
        
        // make tap rim layer
        CAShapeLayer* tapLayer = [self makeBowlLayerAtRadius:rimCenter withColour:[NoteColours colourForNote:noteNumber withSaturation:1.0] ofWidth:edgeWidth];
        [self.tapEdgeLayers setObject:tapLayer forKey:[NSNumber numberWithInt:noteNumber]];
    }
}

#pragma mark - Drawing

-(void) drawBowlRimAtRadius:(CGFloat) radius withNote:(NSString *) note {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [[self makeCircleAtLocation:self.center radius:radius] CGPath];
    shapeLayer.strokeColor = [self.rimColour CGColor];
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 3.0;
    
    [self.rimSubLayer addSublayer:shapeLayer];
    [self.rimLayers addObject:shapeLayer];
    
    if (DISPLAYNOTENAME) {
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

- (CAShapeLayer*) makeBowlLayerAtRadius:(CGFloat) radius withColour:(UIColor *)colour ofWidth:(CGFloat)width {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [[self makeCircleAtLocation:self.center radius:radius] CGPath];
    shapeLayer.strokeColor = [colour CGColor];
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = width;
    shapeLayer.hidden = YES;
    [self.rimSubLayer addSublayer:shapeLayer];
    return shapeLayer;
}



-(void) animateBowlAtRadius:(CGFloat)radius {
    CGFloat fracRadius = [self fractionOfTotalRadiusFromRadius:radius];
    int note = [self.currentSetup pitchAtRadius:fracRadius];
    CAShapeLayer *layer = [self.tapEdgeLayers objectForKey:
                           [NSNumber numberWithInt:note]];
    [CATransaction setAnimationDuration:2.0];
    layer.hidden = NO;
    [CATransaction setCompletionBlock:^{
        [CATransaction setAnimationDuration:1.0];
        layer.hidden = YES;
        [CATransaction setCompletionBlock:^{
            [CATransaction setAnimationDuration:3.0];
        }];
    }];
}

-(void) continuouslyAnimateBowlAtRadius:(CGFloat) radius{
    CAShapeLayer *layer = [self.continuousEdgeLayers objectForKey:
                           [NSNumber numberWithInt:[self.currentSetup pitchAtRadius:
                            [self fractionOfTotalRadiusFromRadius:radius]]]];
    CGFloat width = layer.lineWidth;
    layer.hidden = NO;
    
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    pulse.fromValue = [NSNumber numberWithDouble:width * 0.90];
    pulse.toValue = [NSNumber numberWithDouble:width * 1.10];
    pulse.duration = 0.15;
    pulse.autoreverses = YES;
    pulse.repeatCount = HUGE_VALF;
    
    [layer addAnimation:pulse forKey:@"pulseAnimation"];

}



-(void) stopAnimatingBowl {
    for (CALayer *n in [self.continuousEdgeLayers objectEnumerator]) {
        n.hidden = YES;
        //n.speed = 1.0;
    }
}

-(void) changeBowlVolumeTo:(CGFloat) level {
    for (CALayer *n in [self.continuousEdgeLayers objectEnumerator]) {
        n.opacity = level;
    }
}

-(void) changeContinuousAnimationSpeed:(CGFloat) speed {
    CGFloat newSpeed = speed;
    //if (speed > 1) newSpeed = 1;
    if (speed < 0) newSpeed = 0;
//    NSLog(@"New Speed: %f", newSpeed);
    for (CALayer *layer in [self.continuousEdgeLayers objectEnumerator]) {
        layer.timeOffset = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
        layer.beginTime = CACurrentMediaTime();
        layer.speed = newSpeed;
    }
}

-(void) changeContinuousColour:(CGFloat) amount forRadius:(CGFloat)radius {
//    NSLog(@"New Colour Bend: %f", amount);
    CGFloat newSaturation = 0.6 + (amount * 0.1);
    int noteNumber = [self.currentSetup pitchAtRadius: [self fractionOfTotalRadiusFromRadius:radius]];
    CAShapeLayer *layer = [self.continuousEdgeLayers objectForKey: [NSNumber numberWithInt:noteNumber]];
    layer.strokeColor = [[NoteColours colourFornote:noteNumber withSaturation:newSaturation andBend:amount] CGColor];
}

#pragma mark - Touch
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    for (UITouch * touch in [touches objectEnumerator]) {
        [self animateBowlAtRadius:[self calculateDistanceFromCenter:[touch locationInView:self]]];
    }
}

#pragma mark - Util
-(CGFloat)calculateDistanceFromCenter:(CGPoint)touchPoint {
    CGFloat xDist = (touchPoint.x - self.center.x);
    CGFloat yDist = (touchPoint.y - self.center.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

-(CGFloat) viewRadius {
    return sqrt((self.center.x * self.center.x)+(self.center.y * self.center.y));
}

-(CGFloat)fractionOfTotalRadiusFromRadius:(CGFloat)radius {
    return radius / self.totalRadius;
}
@end
