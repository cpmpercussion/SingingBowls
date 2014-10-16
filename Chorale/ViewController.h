//
//  ViewController.h
//  Chorale
//
//  Created by Charles Martin on 20/01/2014.
//  Copyright (c) 2014 Charles Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdAudioController.h"
#import "PdBase.h"
#import "MetatoneNetworkManager.h"
#import "MetatoneMidiManager.h"

@interface ViewController : UIViewController <PdReceiverDelegate,MetatoneNetworkManagerDelegate>

@property (strong, nonatomic) MetatoneMidiManager* midiManager;

@end
