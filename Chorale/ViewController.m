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

@interface ViewController ()
// Audio
@property (strong,nonatomic) PdAudioController *audioController;
@property (strong, nonatomic) SingingBowlSetup *bowlSetup;
// Network
//UI
@property (weak, nonatomic) IBOutlet SingingBowlView *bowlView;

@property (nonatomic) CGFloat viewRadius;
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
    
    // Setup singing bowls
    self.bowlSetup = [[SingingBowlSetup alloc] initWithPitches:[NSMutableArray arrayWithArray:TEST_PITCHES]];
    self.viewRadius = [self calculateMaximumRadius];
    [self.bowlView drawSetup:self.bowlSetup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Touch Methods


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    int velocity = 100;

    [PdBase sendNoteOn:1 pitch:[self noteFromPosition:point] velocity:velocity];
    //NSLog(@"touch note");
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
    //NSLog([NSString stringWithFormat:@"%f",radius]);
    
    int note = [self.bowlSetup pitchAtRadius:radius];
    //NSLog([NSString stringWithFormat:@"Note: %d",note]);
    
    return note;
    
    // distance = distance /600
    //nt note = (int) (distance * 35);
    //return [ScaleMaker lydian:36 withNote:note];
}

@end
