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

@interface ViewController : UIViewController <PdReceiverDelegate,MetatoneNetworkManagerDelegate>


@end
