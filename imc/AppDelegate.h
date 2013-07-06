//
//  AppDelegate.h
//  imc
//
//  Created by Andry Rozdolsky on 2/19/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "globalDefines.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Reachability.h"

@class ViewController; 
@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    
    MPMoviePlayerController *player;
    
    Reachability* reachability;
    
    BOOL bPlayerFullScreen;
    
    
    UIView* noNetworkCoverView;
    UIView* noNetworkMessageBox;
}


@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;

@end
