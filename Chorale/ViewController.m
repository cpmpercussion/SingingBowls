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
#define ENSEMBLE_STATUS_MODE NO

#import "ViewController.h"
#import "ScaleMaker.h"
#import "SingingBowlSetup.h"
#import "SingingBowlView.h"
#import "MetatoneEnsembleView.h"
#import "SingingBowlComposition.h"
//#import "TestChoraleComposition.h"
//#import "StudyInBowls1.h"
#import "GenerativeSetupComposition.h"

@interface ViewController ()
// Audio
@property (strong,nonatomic) PdAudioController *audioController;
@property (strong, nonatomic) SingingBowlSetup *bowlSetup;
// Network
@property (strong,nonatomic) MetatoneNetworkManager *networkManager;
@property (strong,nonatomic) NSMutableDictionary *metatoneClients;
//UI
@property (weak, nonatomic) IBOutlet SingingBowlView *bowlView;
@property (weak, nonatomic) IBOutlet MetatoneEnsembleView *ensembleView;
@property (nonatomic) CGFloat viewRadius;
@property (weak, nonatomic) IBOutlet UISlider *distortSlider;
@property (weak, nonatomic) IBOutlet UILabel *oscStatusLabel;
@property (weak, nonatomic) IBOutlet UIStepper *compositionStepper;
@property (weak, nonatomic) IBOutlet UILabel *playerStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *gestureStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *ensembleStatusLabel;
// Composition
@property (strong,nonatomic) SingingBowlComposition *composition;
@property (strong, nonatomic) NSDate* timeOfLastNewIdea;
@end

@implementation ViewController
#pragma mark - Setup

- (PdAudioController *) audioController
{
    if (!_audioController) _audioController = [[PdAudioController alloc] init];
    return _audioController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup UI
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"manual_control_mode"]) {
        [self.distortSlider setHidden:NO];
        [self.compositionStepper setHidden:NO];
        [self.oscStatusLabel setHidden:YES];
    } else {
        [self.distortSlider setHidden:YES];
        [self.compositionStepper setHidden:YES];
        [self.oscStatusLabel setHidden:NO];
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
    
    // Setup composition
    //    self.composition = [[TestChoraleComposition alloc] init];
    //    self.composition = [[StudyInBowls1 alloc] init];
    self.composition = [[GenerativeSetupComposition alloc] init];

    [self.compositionStepper setMinimumValue:0];
    [self.compositionStepper setMaximumValue:[self.composition numberOfSetups]];
    [self.compositionStepper setWraps:YES];
    
    
    // Setup singing bowls
    self.bowlSetup = [[SingingBowlSetup alloc] initWithPitches:[NSMutableArray arrayWithArray:[self.composition firstSetup]]];
    self.viewRadius = [self calculateMaximumRadius];
    [self.bowlView drawSetup:self.bowlSetup];
    
    // Setup Network
    self.metatoneClients = [[NSMutableDictionary alloc] init];
    self.networkManager = [[MetatoneNetworkManager alloc] initWithDelegate:self shouldOscLog:YES];
    self.timeOfLastNewIdea = [NSDate date];
    
    // Ensemble Heads Up Display
    if (ENSEMBLE_STATUS_MODE) {
        NSLog(@"Displaying Ensemble Status UI");
        [self.ensembleStatusLabel setHidden:NO];
        [self.playerStatusLabel setHidden:NO];
        [self.gestureStatusLabel setHidden:NO];
        [self.ensembleView setHidden:NO];
    } else {
        NSLog(@"Hiding Ensemble Status UI");
        [self.ensembleStatusLabel setHidden:YES];
        [self.playerStatusLabel setHidden:YES];
        [self.gestureStatusLabel setHidden:YES];
        [self.ensembleView setHidden:YES];
    }
    
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
        CGFloat angle = [sender velocityInView:self.view].y/velHyp;
        [PdBase sendFloat:angle toReceiver:@"sinPanAngle"];
        [self.bowlView changeContinuousColour:angle forRadius:[self calculateDistanceFromCenter:[sender locationInView:self.view]]];
        //NSLog(@"%f",[sender velocityInView:self.view].y/velHyp);
        
        // send distance var to PD.
        CGFloat xTrans = [sender translationInView:self.view].x;
        CGFloat yTrans = [sender translationInView:self.view].y;
        CGFloat trans = sqrt((xTrans * xTrans) + (yTrans * yTrans)) / IPAD_SCREEN_DIAGONAL_LENGTH;
        //NSLog(@"%f",trans);
        [PdBase sendFloat:trans toReceiver:@"panTranslation"];
        [self.bowlView changeContinuousAnimationSpeed:(3*trans) + 0.1];
        
    } else if (([sender state] == UIGestureRecognizerStateEnded) || ([sender state] == UIGestureRecognizerStateCancelled)) { // panended
        [PdBase sendFloat:0 toReceiver:@"sing"];
        [self.bowlView stopAnimatingBowl];
    }
}

- (IBAction)steppedMoved:(UIStepper *)sender {
    int state = (int) sender.value;
    NSArray *newSetup = [self.composition setupForState:state];
    [self applyNewSetup:newSetup];
    [PdBase sendFloat:(float) arc4random_uniform(6) toReceiver:@"changesound"];
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
    [self.oscStatusLabel setText:@"searching for classifier 😒"];
}

-(void)stoppedSearchingForLoggingServer {
    [self.oscStatusLabel setText:@"classifier not found! 😰"];
}

-(void)metatoneClientFoundWithAddress:(NSString *)address andPort:(int)port andHostname:(NSString *)hostname {
    [self.metatoneClients setObject:address forKey:hostname];
    NSString *clientNames = @"";
    for (NSString* name in [self.metatoneClients keyEnumerator]) {
        clientNames = [clientNames stringByAppendingString:name];
        clientNames = [clientNames stringByAppendingString:@"\n"];
    }
    [self.playerStatusLabel setText:clientNames];
    [self.ensembleView drawEnsemble:self.metatoneClients];
}

-(void)metatoneClientRemovedwithAddress:(NSString *)address andPort:(int)port andHostname:(NSString *)hostname {}

-(void)loggingServerFoundWithAddress:(NSString *)address andPort:(int)port andHostname:(NSString *)hostname {
    [self.oscStatusLabel setText:[NSString stringWithFormat:@"connected to %@ 👍", hostname]];
    // cancel manual mode.
    [self.distortSlider setHidden:YES];
    [self.compositionStepper setHidden:YES];
    [self.oscStatusLabel setHidden:NO];
}

-(void)didReceiveMetatoneMessageFrom:(NSString *)device withName:(NSString *)name andState:(NSString *)state {
    //NSLog([NSString stringWithFormat:@"METATONE: Received app message from:%@ with state:%@",device,state]);
}

-(void)didReceiveEnsembleEvent:(NSString *)event forDevice:(NSString *)device withMeasure:(NSNumber *)measure {
    NSLog(@"EnsembleEvent: %@ \n",event);
    if ([event isEqualToString:METATONE_NEWIDEA_MESSAGE] && ([self.timeOfLastNewIdea timeIntervalSinceNow] < -10.0)) {
        NSArray *newSetup = [self.composition nextSetup];
        [self applyNewSetup:newSetup];
        //[self.compositionStepper setValue:(self.compositionStepper.value + 1)];
        self.timeOfLastNewIdea = [NSDate date];
    } else {
        NSLog(@"Ensemble Event Received: Too soon after last event!");
    }
}

-(void)didReceiveGestureMessageFor:(NSString *)device withClass:(NSString *)class {
    NSLog(@"Gesture: %@",class);
    [self.gestureStatusLabel setText:class];
}

-(void)didReceiveEnsembleState:(NSString *)state withSpread:(NSNumber *)spread withRatio:(NSNumber*) ratio{
    NSLog(@"Ensemble State: %@",state);
    [self.ensembleStatusLabel setText:state];
    if ([state isEqualToString:@"divergence"] && [spread floatValue] < 10.0 && [spread floatValue] > -10.0) {
        float newDistort = [spread floatValue];
        [self.distortSlider setValue:newDistort animated:YES];
        [self setDistortion:newDistort];
        NSLog(@"Distortion Reduced to %f",newDistort);
    } else {
        float oldDistort = [self.distortSlider value];
        float newDistort = oldDistort * 0.5;
        if (newDistort <= 1 && newDistort >= 0) {
            [self.distortSlider setValue:newDistort animated:YES];
            [self setDistortion:newDistort];
            NSLog(@"Distortion Reduced to %f",newDistort);
        }
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
