//
//  ViewController.m
//  Chorale
//
//  Created by Charles Martin on 20/01/2014.
//  Copyright (c) 2014 Charles Martin. All rights reserved.
//

#define TEST_PITCHES @[@36,@39,@43,@47,@51,@58,@62,@76,@80]

#import "ViewController.h"
#import "ScaleMaker.h"
#import "SingingBowlSetup.h"
#import "SingingBowlView.h"
#import "SingingBowlComposition.h"
#import "TestChoraleComposition.h"

@interface ViewController ()
// Audio
@property (strong,nonatomic) PdAudioController *audioController;
@property (strong, nonatomic) SingingBowlSetup *bowlSetup;
// Network
//UI
@property (weak, nonatomic) IBOutlet SingingBowlView *bowlView;
@property (nonatomic) CGFloat viewRadius;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    self.composition = [[TestChoraleComposition alloc] init];
    [self.compositionStepper setMinimumValue:0];
    [self.compositionStepper setMaximumValue:[self.composition numberOfSetups]];
    
    // Setup singing bowls
    //self.bowlSetup = [[SingingBowlSetup alloc] initWithPitches:[NSMutableArray arrayWithArray:TEST_PITCHES]];
    self.bowlSetup = [[SingingBowlSetup alloc] initWithPitches:[NSMutableArray arrayWithArray:[self.composition firstSetup]]];

    self.viewRadius = [self calculateMaximumRadius];
    [self.bowlView drawSetup:self.bowlSetup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) applyNewSetup: (NSArray *) setup {
    // change bowl setup
    self.bowlSetup = [[SingingBowlSetup alloc] initWithPitches:[NSMutableArray arrayWithArray:setup]];
    [self.bowlView drawSetup:self.bowlSetup];
}

#pragma mark - Touch Methods


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    int velocity = 100;
    [PdBase sendNoteOn:1 pitch:[self noteFromPosition:point] velocity:velocity];
}

- (IBAction)panGestureRecognized:(UIPanGestureRecognizer *)sender {
    CGFloat xVelocity = [sender velocityInView:self.view].x;
    CGFloat yVelocity = [sender velocityInView:self.view].y;
    CGFloat velocity = sqrt((xVelocity * xVelocity) + (yVelocity * yVelocity));
    velocity = log(velocity)*10;
    [PdBase sendFloat:velocity toReceiver:@"singlevel" ];
    //velocity = MIN(velocity, 100);
    //NSLog([NSString stringWithFormat:@"Velocity: %f", velocity]);
    
    if ([sender state] == UIGestureRecognizerStateBegan) { // pan began
        [PdBase sendFloat:1 toReceiver:@"sing"];
        [PdBase sendFloat:velocity toReceiver:@"singlevel" ];
        [PdBase sendFloat:(float) [self noteFromPosition:[sender locationInView:self.view]] toReceiver:@"singpitch"];
        //NSLog(@"start singing");
    } else if ([sender state] == UIGestureRecognizerStateChanged) { // pan changed
        //[PdBase sendFloat:velocity toReceiver:@"singlevel" ];
        //NSLog(@"Continue singing");
#pragma TODO choose new pitch
    } else if (([sender state] == UIGestureRecognizerStateEnded) || ([sender state] == UIGestureRecognizerStateCancelled)) { // panended
        [PdBase sendFloat:0 toReceiver:@"sing"];
        //NSLog(@"Stop Singing");
    }
}

- (IBAction)steppedMoved:(UIStepper *)sender {
    int state = (int) sender.value;
    NSArray *newSetup = [self.composition setupForState:state];
    [self applyNewSetup:newSetup];
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
    
    // distance = distance /600
    //nt note = (int) (distance * 35);
    //return [ScaleMaker lydian:36 withNote:note];
}

@end
