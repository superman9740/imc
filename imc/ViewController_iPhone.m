//
//  ViewController_iPhone.m
//  imc
//
//  Created by Andry Rozdolsky on 3/30/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "ViewController_iPhone.h"
#import "IMCContentLoader.h"
#import "IMCUpdatesProvider.h"
#import "IMCScreenDataSource.h"

#import "IMCUserSession.h"

#import "IMCContactsViewController.h"
#import "IMCNotificationsViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "globalDefines.h"



@interface ViewController_iPhone ()

@end

@implementation ViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) startUp {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([[IMCContentLoader instance] tryAutoLogin]) {
            [self signInWorker];
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showLoginView];
                //[progressIndicatorCntrl removeFromSuperview];
            });
        }
    });

}

-(void) showLoginView {
    
    loginBtn.backgroundColor = IMC_COKE_RED_COLOR;
    //    loginBtn.layer.borderColor = [UIColor blackColor].CGColor;
    //    loginBtn.layer.borderWidth = 1.f;
    loginBtn.layer.cornerRadius = 10.0f;
    
    [rememberMeSwitch setOnTintColor: IMC_COKE_RED_COLOR];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardDidShowNotification object:nil];

    
    [passwordForm setCenter:CGPointMake(self.view.bounds.size.width/2,
                                        self.view.bounds.size.height/2)];

    
    if (![passwordForm superview]) {
        
        if ([contentView superview]) {
            [UIView transitionFromView:contentView toView:passwordForm duration:0.5f options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
                
            }];

        } else {
        
            [[self view] addSubview:passwordForm];
        }
    }
    
    [loginProgressIndicator setHidden:YES];
    [passwordForm setUserInteractionEnabled:YES];
    [loginField setAlpha:1.f];
    [passwordField setAlpha:1.f];
    [loginBtn setAlpha:1.f];
    
    [loginField setDelegate:self];
    [passwordField setDelegate:self];


}

-(void)onKeyboardHide:(NSNotification *)notification
{
    [self.view setFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, self.view.frame.size.height)];

}

-(void)onKeyboardShow:(NSNotification *)notification
{
    [self.view setFrame:CGRectMake(0, -100, self.view.frame.size.width, self.view.frame.size.height)];

}

-(void) hideLoginView {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == loginField) {
        [textField resignFirstResponder];
        [passwordField becomeFirstResponder];
    } else {
        [passwordField resignFirstResponder];
        [self performLogin:nil];
    }
    return YES;
}

-(IBAction)performLogin:(id)sender {
    
    //[self hideLoginView];
    
    NSString* name = [loginField text];
    NSString* pass = [passwordField text];
    
    //[progressIndicator setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    
    [loginProgressIndicator setHidden:NO];
    [passwordForm setUserInteractionEnabled:NO];
    [loginField setAlpha:0.6f];
    [passwordField setAlpha:0.6f];
    [loginBtn setAlpha:0.6f];
    
    BOOL bRemeberMe = [rememberMeSwitch isOn];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL bSuccess = [[IMCContentLoader instance] setCredentialsWithName:name andPassword:pass rememberMe:bRemeberMe];
        if (!bSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showLoginView];
                [loginProgressIndicator setHidden:YES];
            });
        } else {
            [self signInWorker];
        }
        
    });
    
}

-(void) signInWorker {
    NSData* xmlData = [[IMCContentLoader instance] getMainXML];
    [[IMCUserSession currentSession] createContentProviderWithXML:xmlData];
    
    updatesProvider = [[IMCUpdatesProvider alloc] init];
    [updatesProvider loadData];
    
    [self performSelectorOnMainThread:@selector(finishLogin) withObject:nil waitUntilDone:NO];
    
}


-(void) finishLogin {
    
    //[self.view addSubview:contentView];
    
    [contentView setFrame:CGRectMake(8, 92, self.view.frame.size.width-16, self.view.frame.size.height-98)];
    
    if ([passwordForm superview]) {
        [UIView transitionFromView:passwordForm toView:contentView duration:0.5f options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            
        }];

    } else {
        [[self view] addSubview:contentView];
    }
    
    bottomShadowImageView = [[IMCGradientImageView alloc] initWithFrame:CGRectMake(0, 5, contentView.frame.size.width, 15)];
    
    [bottomShadowImageView createGradientWithColor:[contentView backgroundColor] bFadeToTop:NO];
    
    [contentView addSubview:bottomShadowImageView];
    
    
    topShadowImageView = [[IMCGradientImageView alloc] initWithFrame:CGRectMake(0, contentView.frame.size.height-20, contentView.frame.size.width, 15)];
    
    [topShadowImageView createGradientWithColor:[contentView backgroundColor] bFadeToTop:YES];
    
    [contentView addSubview:topShadowImageView];
    
    
    currentDataSource = [[[IMCUserSession currentSession] rootContentProvider] getRootMenuDataSource];
    
    
    
    IMCBreadcrumbsItem* item = [[IMCBreadcrumbsItem alloc] init];
    item.title = @"Home";
    item.dataSource = nil;
    
    breadCrumbs = [[IMCBreadcrumbs alloc] initWithRootItem:item];
    breadCrumbs.delegate = self;
    
    [self repostionBreadCrumps];
    
    [self.view addSubview:breadCrumbs];
    
    //[breadCrumbs setHidden:YES];
    
    [self presentNewTableViewAnimated:NO withAnimationDrectionFromLeft:NO];
        
    accordeonView = [[IMCAccordeonView alloc] initWithFrame:CGRectZero andHorizontalOrientation:NO];
}



-(void) hideMenuPopup {
    if ([menuPopup superview]) {
        
        [UIView animateWithDuration:0.3f animations:^{
            [menuPopup setFrame:CGRectMake(0, 52, self.view.bounds.size.width, 0)];
            [menuPopupBgButton setAlpha:0.f];
        } completion:^(BOOL finished) {
            [menuPopup removeFromSuperview];
            [menuPopupBgButton removeFromSuperview];
        }];
    }
}


-(IBAction)menuPopupTriggered {
    if ([menuPopup superview]) {
        
        [self hideMenuPopup];
        
    } else {
        
        if ([contentView superview]) {
                    
            menuPopupBgButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [menuPopupBgButton setFrame:CGRectMake(0, 52, self.view.bounds.size.width,
                                                   self.view.bounds.size.height)];
            [menuPopupBgButton setBackgroundColor:[UIColor blackColor]];
            
            [menuPopupBgButton setAlpha:0.f];
            [[self view] addSubview:menuPopupBgButton];
            
            [menuPopupBgButton addTarget:self action:@selector(hideMenuPopup)
                        forControlEvents:UIControlEventTouchDown];
            
            [[self view ] addSubview:menuPopup];
            [menuPopup setFrame:CGRectMake(0, 52, self.view.bounds.size.width, 0)];
            [UIView animateWithDuration:0.3f animations:^{
                [menuPopup setFrame:CGRectMake(0, 52, self.view.bounds.size.width, 172)];
                [menuPopupBgButton setAlpha:0.6f];
            }];
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) breadcrumbsItemSelected:(IMCBreadcrumbsItem*)item {

    IMCDataSource* tmpDataSource = currentDataSource;
    if (item.dataSource == nil) {
        currentDataSource = [[[IMCUserSession currentSession] rootContentProvider] getRootMenuDataSource];
        [breadCrumbs resetBredcrumpsToRoot];
        
    } else {
        currentDataSource = item.dataSource;
    }

    if ([accordeonView superview]) {
        [self popAccordeonView];
    }
    
    [self repostionBreadCrumps];
    
        
    UITableView* tabl = [self presentNewTableViewAnimated:YES withAnimationDrectionFromLeft:YES];
    
    

}

-(void) repostionBreadCrumps {
    [breadCrumbs setFrame:CGRectMake(5, 56, 310, [breadCrumbs getHeight])];
    
    [contentView setFrame:CGRectMake(8, 48 + [breadCrumbs getHeight], self.view.frame.size.width-16, self.view.frame.size.height-54 - [breadCrumbs getHeight])];
    
}

-(UITableView*) presentNewTableViewAnimated:(BOOL)bAnimated withAnimationDrectionFromLeft:(BOOL)bFromLeft {
    
    CGRect tableFrame;
    if ([currentDataSource isKindOfClass:[IMCScreenDataSource class]]) {
        tableFrame = CGRectInset(contentView.bounds, 10, 5);
    } else {
        tableFrame = CGRectInset(contentView.bounds, 0, 5);
    }

    
    UITableView*  newTableView = [[UITableView alloc] initWithFrame:tableFrame
                                                              style:UITableViewStylePlain];
    [newTableView setBackgroundColor:[UIColor clearColor]];
    [newTableView setSeparatorColor:[UIColor clearColor]];
    [contentView addSubview:newTableView];
    [newTableView setDelegate:self];
    [newTableView setDataSource:currentDataSource];
    if ([currentDataSource isKindOfClass:[IMCScreenDataSource class]]) {
        [newTableView setContentInset:UIEdgeInsetsMake(15, 0, 15, 0)];

    } else {
        [newTableView setContentInset:UIEdgeInsetsMake(10, 0, 10, 0)];

    }


    [newTableView setScrollIndicatorInsets:UIEdgeInsetsMake(8, 0, 8, 0)];
    
    [contentView bringSubviewToFront:topShadowImageView];
    
    [topShadowImageView setFrame:CGRectMake(0, contentView.frame.size.height-20, contentView.frame.size.width, 15)];
    [contentView bringSubviewToFront:bottomShadowImageView];

    
    if (!bAnimated) {
        [tableView removeFromSuperview];
        tableView = newTableView;
    } else {
    
        [contentView setClipsToBounds:YES];
        
        int offset = contentView.bounds.size.width;
        
        if (bFromLeft) {
            offset = -offset;
        }
        
        [newTableView setFrame:CGRectOffset(tableFrame, offset, 0)];
        [activityIndicator setFrame:CGRectOffset(contentView.bounds, offset, 0)];
        
        [UIView animateWithDuration:0.3 animations:^{
            [newTableView setFrame:tableFrame];
            [tableView setFrame:CGRectOffset(CGRectInset(contentView.bounds, 0, 5), -offset, 0)];
            [activityIndicator setFrame:contentView.bounds];
        } completion:^(BOOL finished) {
            [tableView removeFromSuperview];
            tableView = newTableView;
            
        }];
    }
    
    return newTableView;

}

-(void) presentAccordeonView {
    
    [contentView addSubview:accordeonView];

    [contentView setClipsToBounds:YES];
    
    int offset = contentView.bounds.size.width;
    
    
    [accordeonView setFrame:CGRectInset(CGRectOffset(contentView.bounds, offset, 0), 8, 8)];
    
    [UIView animateWithDuration:0.3 animations:^{
        [accordeonView setFrame: CGRectInset(contentView.bounds, 8, 8) ];
        [tableView setFrame:CGRectOffset(contentView.bounds, -offset, 0)];
    } completion:^(BOOL finished) {
        [tableView removeFromSuperview];
        
    }];
}

-(void) popAccordeonView {
    
    int offset = contentView.bounds.size.width;
    
    [UIView animateWithDuration:0.3 animations:^{
        [accordeonView setFrame:CGRectInset(CGRectOffset(contentView.bounds, offset, 0), 8, 8)];
    } completion:^(BOOL finished) {
        [accordeonView removeFromSuperview];
        
    }];
    
    
}


-(BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    IMCMenuDataSource* ds = [tableView dataSource];
    if ([ds isKindOfClass:[IMCScreenDataSource class]]) {
        IMCScreenDataSource* screenDS = (IMCScreenDataSource*)ds;
        return [screenDS reloadCardForClickOnRow:[indexPath row] tableView:tableView];
    }
    return YES;
}


- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IMCMenuDataSource* ds = [tableView dataSource];
    
    
    if ([ds isKindOfClass:[IMCMenuDataSource class]]) {
        
        if ([ds isDisabledRow:[indexPath row]]) {
            return;
        }
        
        [tableView setHidden:NO];
        IMCDataSource* tmpDs = currentDataSource;
        currentDataSource = [ds getChildDataSourceForItem:[indexPath row]];
        
        IMCBreadcrumbsItem* item = [[IMCBreadcrumbsItem alloc] init];
        item.title = [ds titleForItem:[indexPath row]];
        item.dataSource = currentDataSource;
        [breadCrumbs pushBreadcrumbsItem:item];

        [self repostionBreadCrumps];

        
        if ([ds isToolkitItem:[indexPath row]]) {
            
            [activityIndicator setHidden:NO];
            
             UITableView* tableViewWeakRef = [self presentNewTableViewAnimated:YES withAnimationDrectionFromLeft:NO];
                                    
            IMCMenuDataSource* dsStrongRef = currentDataSource;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [dsStrongRef loadData];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([tableViewWeakRef superview]) {
                        [tableViewWeakRef reloadData];
                    }
                    [activityIndicator setHidden:YES];
                    
                });
                
            });
            

        } else {
            [self presentNewTableViewAnimated:YES withAnimationDrectionFromLeft:NO];
            

        }
        
        
    } else {
        
        IMCBreadcrumbsItem* item = [[IMCBreadcrumbsItem alloc] init];
        item.title = [ds titleForItem:[indexPath row]];
        item.dataSource = currentDataSource;
        [breadCrumbs pushBreadcrumbsItem:item];

        
        [self repostionBreadCrumps];


        [self presentAccordeonView];
        [accordeonView setDataSource:[ds getChildDataSourceForItem:[indexPath row]]];
        
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMCMenuDataSource* ds = [tableView dataSource];
    if ([ds isKindOfClass:[IMCMenuDataSource class]]) {
        return 76.f;
    } else if ([ds isKindOfClass:[IMCScreenDataSource class]]) {
        return [(IMCScreenDataSource*)ds heightOfItemWithIndex:[indexPath row]];
    }
    
    return 44.f;
}


-(IBAction)showHelp {
    
    if ([accordeonView superview]) {
        [self popAccordeonView];
    }
    
    IMCMainContentProvider* provider= [[IMCUserSession currentSession] rootContentProvider];
    
    IMCMenuDataSource* ds = [provider getHelpMenuDataSource];
    currentDataSource = [ds getDirectChildDataSourceForItem:0];
    
    IMCBreadcrumbsItem* item = nil;
    
    item = [[IMCBreadcrumbsItem alloc] init];
    item.title = [ds titleForItem:0];
    [breadCrumbs resetBredcrumpsToRoot];

    item.callback = @selector(setMenuContainerLayout);
    item.dataSource = nil;
    
    [breadCrumbs pushBreadcrumbsItem:item];
    
        
    
    item = [[IMCBreadcrumbsItem alloc] init];
    item.title = [currentDataSource titleForItem:0];
    
    currentDataSource = [currentDataSource getChildDataSourceForItem:0];
    
    item.dataSource = currentDataSource;


    
    [breadCrumbs pushBreadcrumbsItem:item];
    

    
    [activityIndicator setHidden:NO];
    
    UITableView* tableViewWeakRef = [self presentNewTableViewAnimated:YES withAnimationDrectionFromLeft:NO];
    
    IMCMenuDataSource* dsStrongRef = currentDataSource;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [dsStrongRef loadData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([tableViewWeakRef superview]) {
                [tableViewWeakRef reloadData];
            }
            [activityIndicator setHidden:YES];
            
        });
        
    });
    
    [self repostionBreadCrumps];

    [self hideMenuPopup];
    
}

-(IBAction)showContacts:(id)sender {
    IMCMainContentProvider* provider= [[IMCUserSession currentSession] rootContentProvider];
    IMCContactsViewController* cntrl = [[IMCContactsViewController alloc]
                                        initWithContactItems:[provider getContacts]];
    [self presentViewController:cntrl animated:YES completion:^{
        
    }];
    
        [self hideMenuPopup];
    
}

-(IBAction)showNotifications:(id)sender {
    IMCNotificationsViewController* cntrl = [[IMCNotificationsViewController alloc]
                                             initWithUpdateProvider:updatesProvider];
    [self presentViewController:cntrl animated:YES completion:^{
        
    }];
    
        [self hideMenuPopup];

}

-(IBAction)logout:(id)sender {
    
    [passwordField setText:@""];
    [loginField setText:@""];
    
    [self hideMenuPopup];
    [breadCrumbs removeFromSuperview];
    
    for (UIView* v in contentView.subviews) {
        if (v != activityIndicator) {
            [v removeFromSuperview];
        }
    }
    
    [[IMCUserSession currentSession] clear];
    
    [[IMCContentLoader instance] logOut];
        
    [self showLoginView];

}



@end
