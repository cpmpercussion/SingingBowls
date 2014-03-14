//
//  ViewController.m
//  Chorale
//
//  Created by Charles Martin on 20/01/2014.
//  Copyright (c) 2014 Charles Martin. All rights reserved.
//

#define TEST_PITCHES @[@36,@39,@43,@47,@51,@58,@62,@76,@80]

#define METATONE_NEWSECTION_MESSAGE @"NEWSECTION"
#define METATONE_NEWIDEA_MESSAGE @"new_idea"

#define IPAD_SCREEN_DIAGONAL_LENGTH 1280

#import "ViewController.h"
#import "ScaleMaker.h"
#import "SingingBowlSetup.h"
#import "SingingBowlView.h"
#import "SingingBowlComposition.h"
//#import "TestChoraleComposition.h"
#import "StudyInBowls1.h"

@interface ViewController ()
// Audio
@property (strong,nonatomic) PdAudioController *audioController;
@property (strong, nonatomic) SingingBowlSetup *bowlSetup;
// Network
@property (strong,nonatomic) MetatoneNetworkManager *networkManager;
//UI
@property (weak, nonatomic) IBOutlet SingingBowlView *bowlView;
@property (nonatomic) CGFloat viewRadius;
@property (weak, nonatomic) IBOutlet UISlider *distortSlider;
@property (weak, nonatomic) IBOutlet UIStepper *compositionStepper;
// Composition
@property (strong,nonatomic) SingingBowlComposition *composition;
@end

@implementation ViewController
#pragma mark - Setup

- (PdAudioController *) audioController
{
    if (!_audioController) _audioController = [[PdAudioController alloc] init];
    return _audioController;
}

//-(void) receiveList:(NSArray *)list fromSource:(NSString *)source {
//    NSLog([list description]);
//}
//
//-(void) receiveFloat:(float)received fromSource:(NSString *)source {
//    NSLog([NSString stringWithFormat:@"Sing Volume: %f",received]);
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup UI
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"manual_control_mode"]) {
        [self.distortSlider setHidden:NO];
        [self.compositionStepper setHidden:NO];
    } else {
        [self.distortSlider setHidden:YES];
        [self.compositionStepper setHidden:YES];
    }
    
    // Setup Pd
    if([self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:NO mixingEnabled:YES] != PdAudioOK) {
        NSLog(@"failed to initialise audioController");
    } else {
        NSLog(@"audioController initialised.");
    }
    
    
    
    [PdBase openFile:@"SoundScraper.pd" path:[[NSBundle mainBundle] bundlePath]];
    [self.audioController setActive:YES];
    [self.audioController print];
    [PdBase setDelegate:self];
    
    [PdBase subscribe:@"singvolume"];
    
    // Setup composition
//    self.composition = [[TestChoraleComposition alloc] init];
    self.composition = [[StudyInBowls1 alloc] init];

    [self.compositionStepper setMinimumValue:0];
    [self.compositionStepper setMaximumValue:[self.composition numberOfSetups]];
    [self.compositionStepper setWraps:YES];
    
    // Setup singing bowls
    self.bowlSetup = [[SingingBowlSetup alloc] initWithPitches:[NSMutableArray arrayWithArray:[self.composition firstSetup]]];

    self.viewRadius = [self calculateMaximumRadius];
    [self.bowlView drawSetup:self.bowlSetup];
    
    // Setup Network
    self.networkManager = [[MetatoneNetworkManager alloc] initWithDelegate:self shouldOscLog:YES];
}

- (void) applyNewSetup: (NSArray *) setup {
    self.bowlSetup = [[SingingBowlSetup alloc] initWithPitches:[NSMutableArray arrayWithArray:setup]];
    [self.bowlView drawSetup:self.bowlSetup];
}

#pragma mark - Touch Methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch * touch in [touches objectEnumerator]) {
        CGPoint point = [touch locationInView:self.view];
        int velocity = 100;
        [PdBase sendNoteOn:1 pitch:[self noteFromPosition:point] velocity:velocity];
        [self.networkManager sendMessageWithTouch:point Velocity:0.0];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in [touches objectEnumerator]) {
        CGFloat xVelocity = [touch locationInView:self.view].x - [touch previousLocationInView:self.view].x;
        CGFloat yVelocity = [touch locationInView:self.view].y - [touch previousLocationInView:self.view].y;
        CGFloat velocity = sqrt((xVelocity * xVelocity) + (yVelocity * yVelocity));
        [self.networkManager sendMessageWithTouch:[touch locationInView:self.view] Velocity:velocity];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in [touches objectEnumerator]) {
        [self.networkManager sendMessageTouchEnded];
    }
}

- (IBAction)panGestureRecognized:(UIPanGestureRecognizer *)sender {
    CGFloat xVelocity = [sender velocityInView:self.view].x;
    CGFloat yVelocity = [sender velocityInView:self.view].y;
    CGFloat velHyp = sqrt((xVelocity * xVelocity) + (yVelocity * yVelocity));
    CGFloat velocity = log(velHyp)*20;
    [PdBase sendFloat:velocity toReceiver:@"singlevel" ];
    [self.bowlView changeBowlVolumeTo:velocity / 200];
    
    if ([sender state] == UIGestureRecognizerStateBegan) { // pan began
        [PdBase sendFloat:1 toReceiver:@"sing"];
        [PdBase sendFloat:velocity toReceiver:@"singlevel" ];
        [PdBase sendFloat:(float) [self noteFromPosition:[sender locationInView:self.view]] toReceiver:@"singpitch"];
        
        [self.bowlView continuouslyAnimateBowlAtRadius:[self calculateDistanceFromCenter:[sender locationInView:self.view]]];
        
    } else if ([sender state] == UIGestureRecognizerStateChanged) { // pan changed
        [PdBase sendFloat:velocity toReceiver:@"singlevel" ];
        
        // send angle message to PD.
        [PdBase sendFloat:[sender velocityInView:self.view].y/velHyp toReceiver:@"sinPanAngle"];
        //NSLog(@"%f",[sender velocityInView:self.view].y/velHyp);
        
        // send distance var to PD.
        CGFloat xTrans = [sender translationInView:self.view].x;
        CGFloat yTrans = [sender translationInView:self.view].y;
        CGFloat trans = sqrt((xTrans * xTrans) + (yTrans * yTrans)) / IPAD_SCREEN_DIAGONAL_LENGTH;
        //NSLog(@"%f",trans);
        [PdBase sendFloat:trans toReceiver:@"panTranslation"];
        
    } else if (([sender state] == UIGestureRecognizerStateEnded) || ([sender state] == UIGestureRecognizerStateCancelled)) { // panended
        [PdBase sendFloat:0 toReceiver:@"sing"];
        [self.bowlView stopAnimatingBowl];
    }
}

- (IBAction)steppedMoved:(UIStepper *)sender {
    int state = (int) sender.value;
    NSArray *newSetup = [self.composition setupForState:state];
    [self applyNewSetup:newSetup];
}
- (IBAction)sliderMoved:(UISlider *)sender {
    [self setDistortion:[sender value]];
}

-(void)setDistortion:(float)level {
    [PdBase sendFloat:level toReceiver:@"distortlevel"];
}


#pragma mark - Utils
-(CGFloat)calculateMaximumRadius {
    CGFloat xDist = (self.view.center.x);
    CGFloat yDist = (self.view.center.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}


-(CGFloat)calculateDistanceFromCenter:(CGPoint)touchPoint {
    CGFloat xDist = (touchPoint.x - self.view.center.x);
    CGFloat yDist = (touchPoint.y - self.view.center.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

-(int)noteFromPosition:(CGPoint) point
{
    CGFloat distance = [self calculateDistanceFromCenter:point];
    CGFloat radius = distance/self.viewRadius;
    int note = [self.bowlSetup pitchAtRadius:radius];
    return note;
}

#pragma mark - Metatone Network Methods
-(void)searchingForLoggingServer {
    
}

-(void)stoppedSearchingForLoggingServer {
    
}

-(void)loggingServerFoundWithAddress:(NSString *)address andPort:(int)port andHostname:(NSString *)hostname {
    
}

-(void)didReceiveMetatoneMessageFrom:(NSString *)device withName:(NSString *)name andState:(NSString *)state {
    //NSLog([NSString stringWithFormat:@"METATONE: Received app message from:%@ with state:%@",device,state]);
}

-(void)didReceiveEnsembleEvent:(NSString *)event forDevice:(NSString *)device withMeasure:(NSNumber *)measure {
    NSLog(@"New Idea");
    if ([event isEqualToString:METATONE_NEWIDEA_MESSAGE]) {
        NSArray *newSetup = [self.composition nextSetup];
        [self applyNewSetup:newSetup];
        //[self.compositionStepper setValue:(self.compositionStepper.value + 1)];
    }
    NSLog(@"EnsembleEvent: %@",event);
}

-(void)didReceiveGestureMessageFor:(NSString *)device withClass:(NSString *)class {
    NSLog(@"Gesture: %@",class);
}

-(void)didReceiveEnsembleState:(NSString *)state withSpread:(NSNumber *)spread withRatio:(NSNumber*) ratio{
    NSLog(@"Ensemble State: %@",state);
    if ([state isEqualToString:@"divergence"] && [spread floatValue] < 10.0 && [spread floatValue] > -10.0) {
        [self.distortSlider setValue:[spread floatValue] animated:YES];
        [self setDistortion:[spread floatValue]];
    }
}

@end
