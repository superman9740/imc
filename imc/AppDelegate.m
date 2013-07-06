//
//  AppDelegate.m
//  imc
//
//  Created by Andry Rozdolsky on 2/19/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "IMCImagePreviewView.h"

#import "UIImageView+actualImageFrame.h"
#import "ViewController_iPhone.h"
#import "IMCScriptPreview.h"
#import "IMCBRowserViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNetworkChange:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    
    
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideo:)
                                                 name:VIDEO_PREVIEW_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPhoto:)
                                                 name:IMAGE_PREVIEW_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showScript:)
                                                 name:SCRIPT_PREVIEW_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBrawser:)
                                                 name:HTML_PREVIEW_NOTIFICATION object:nil];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEneteredFullscreen:) name:MPMoviePlayerDidEnterFullscreenNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitedFullscreen:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitedFullscreen:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ViewController_iPhone alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    
    bPlayerFullScreen = NO;
    
    [self.window makeKeyAndVisible];

    [self handleNetworkChange:nil];
    

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void) playVideo:(NSNotification*) notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary* dict = [notification userInfo];
        NSString* videoUrlString = [dict objectForKey:@"videoUrlString"];
        UIImageView* thumbnailImageView = [dict objectForKey:@"thumbnailImageView"];
        
        [player.view removeFromSuperview];
        
        
        NSURL *url = [NSURL URLWithString:videoUrlString];
        player = [[MPMoviePlayerController alloc] initWithContentURL:url];
//        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        
        [player.view setFrame:[self.viewController.view
                               convertRect:[thumbnailImageView actualImageFrame]
                               fromView:thumbnailImageView]];
        
//        [self.viewController presentViewController:player animated:YES completion:nil];
        
        //UIImageView *imageView=[[UIImageView alloc]initWithImage:[thumbnailImageView image]];
        
        //[player.backgroundView addSubview:imageView];
        
        [self.viewController.view addSubview:player.view];
        
        bPlayerFullScreen = YES;
        
        [player setFullscreen:YES animated:YES];
        //imageView.frame=self.viewController.view.bounds;
        
        [player play];
        
    });
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;      
    } else {
        if (bPlayerFullScreen) {
            return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
        }
        
        return UIInterfaceOrientationMaskPortrait;
    }
}

-(void) didEneteredFullscreen:(NSNotification*)notification {
    bPlayerFullScreen = YES;
}

-(void) willExitedFullscreen:(NSNotification*)notification {
    bPlayerFullScreen = NO;
}

- (void)exitedFullscreen:(NSNotification*)notification {
    [player.view removeFromSuperview];
    [player stop];
    player = nil;
}

- (void)playbackFinished:(NSNotification*)notification {

    [player setFullscreen:NO animated:YES];
}

-(void) showPhoto:(NSNotification*) notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        NSDictionary* dict = [notification userInfo];
        NSArray* imageViews = [dict objectForKey:@"thumbnailImageViews"];
        int index = [[dict objectForKey:@"activeImageIndex"] intValue];
        
        CGSize size = self.viewController.view.bounds.size;
        
        IMCImagePreviewView* imagePreview = [[IMCImagePreviewView alloc]
                                             initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        
        [self.viewController.view addSubview:imagePreview];
        [imagePreview appearWithImageContainers:imageViews activeImageIndex:index];
    });
    
}

-(void) showScript:(NSNotification*) notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary* dict = [notification userInfo];
        NSArray* scriptsArray = [dict objectForKey:@"scripArray"];
        int index = [[dict objectForKey:@"activeScriptIndex"] intValue];
        
        
        IMCScriptPreview* scriptPreview = [[IMCScriptPreview alloc]
                                             initWithFrame:self.viewController.view.bounds];
        
        [self.viewController.view addSubview:scriptPreview];
        [scriptPreview appearWithScriptsTexts:scriptsArray activeScriptIndex:index];
    });
    
}


-(void) showBrawser:(NSNotification*) notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary* dict = [notification userInfo];
        NSString* url = [dict objectForKey:@"url"];
        
        
        IMCBRowserViewController* browserPreview = [[IMCBRowserViewController alloc] initWithNibName:@"IMCBRowserViewController" bundle:nil];;

        [browserPreview appearWithUrl:url];
        [self.viewController presentViewController:browserPreview animated:YES completion:nil];
    });
    
}



-(void) handleNetworkChange:(NSNotification*)notice {
    NetworkStatus ns = [reachability currentReachabilityStatus];
    
    if (ns == ReachableViaWiFi || ns == ReachableViaWWAN) {
        
        [noNetworkCoverView removeFromSuperview];
        [noNetworkMessageBox removeFromSuperview];
        noNetworkCoverView = nil;
        noNetworkMessageBox = nil;
        [self.viewController performSelector:@selector(startUp)];
        
    } else {
        noNetworkCoverView = [[UIView alloc] initWithFrame:[self.window bounds]];
        [self.window addSubview:noNetworkCoverView];
        [noNetworkCoverView setBackgroundColor:[UIColor blackColor]];
        [noNetworkCoverView setAlpha:0.6f];
        
        noNetworkMessageBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 306, 124)];
        noNetworkMessageBox.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -3.14/2);
        [noNetworkMessageBox setBackgroundColor:[UIColor blackColor]];
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 20, 272, 21)];
        [noNetworkMessageBox addSubview:titleLabel];
        [titleLabel setText:@"No internet connection available!"];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:17.f]];

        UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 56, 269, 48)];
        [noNetworkMessageBox addSubview:textLabel];
        [textLabel setText:@"You need access to 3G or WI-FI network to use this app."];
        [textLabel setTextColor:[UIColor whiteColor]];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setFont:[UIFont systemFontOfSize:16.f]];
        [textLabel setNumberOfLines:0];
        
        [self.window addSubview:noNetworkMessageBox];
        
        [noNetworkMessageBox setCenter:CGPointMake(self.window.bounds.size.width/2, self.window.bounds.size.height/2)];

    }
}

@end
