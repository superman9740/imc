//
//  ViewController.m
//  imc
//
//  Created by Andry Rozdolsky on 2/19/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//


#import "ViewController.h"
#import "IMCContentLoader.h"
#import <QuartzCore/QuartzCore.h>

#import "IMCContactsViewController.h"
#import "IMCNotificationsViewController.h"

#import "IMCScreenDataSource.h"

#import "IMCAutoLoadableImageView.h"

#import "IMCUserSession.h"
#import "IMCGradientImageView.h"

#import "globalDefines.h"


@interface ViewController ()

@end

@implementation ViewController

@synthesize loginView;

@synthesize loginField;
@synthesize passwordField;

@synthesize progressIndicatorCntrl;

@synthesize container1;
@synthesize container2;
@synthesize container3;
@synthesize container4;



-(void) showLoginView {
    
    loginBtn.backgroundColor = IMC_COKE_RED_COLOR;
//    loginBtn.layer.borderColor = [UIColor blackColor].CGColor;
//    loginBtn.layer.borderWidth = 1.f;
    loginBtn.layer.cornerRadius = 10.0f;
    
    [remeberMeSwitch setOnTintColor: IMC_COKE_RED_COLOR];
    
    [self.view addSubview:loginView];
    
    [loginView setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    [loginView setTransform:CGAffineTransformMakeScale(0.85f, 0.85f)];
    
    [UIView animateWithDuration:0.15f animations:^{
            [loginView setTransform:CGAffineTransformMakeScale(1.f, 1.f)];
    }];
    
    [buttonsPanel setHidden:YES];
    
    [loginField setDelegate:self];
    [passwordField setDelegate:self];
    
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


-(void) hideLoginView {
    
    [loginView removeFromSuperview];
}


-(void) setInitialContainerLayout {
    CGRect rect = CGRectMake(17, 100, 0, 0);
    [container1 setFrame:rect];
    [container2 setFrame:rect];
    [container3 setFrame:rect];
    [container4 setFrame:rect];
}

-(void) setMenuContainerLayout {
    [buttonsPanel setHidden:NO];
    [self clearAllContainers];
    [UIView animateWithDuration:0.35 animations:^{

        CGRect rect = CGRectMake(17, 100, 240, 600);
        [container1 setFrame:rect];
        rect.origin.x += 250;
        [container2 setFrame:rect];
        rect.origin.x += 250;
        [container3 setFrame:rect];
        rect.origin.x += 250;
        [container4 setFrame:rect];
    } completion:^(BOOL finished) {
        [self setupMainMenu];
    }];
}

-(void) setSubMenuContainerLayout {
    [self clearAllContainers];
    
    [UIView animateWithDuration:0.35 animations:^{

        CGRect rect = CGRectMake(17, 100, 990, 120);
        [container1 setFrame:rect];
        rect = CGRectMake(17, 230, 0, 0);
        [container2 setFrame:rect];
        rect = CGRectMake(17, 230, 320, 470);
        [container3 setFrame:rect];
        rect = CGRectMake(767, 100, 0, 0);
        [container4 setFrame:rect];
    } completion:^(BOOL finished) {
        [self setupSubMenu];
    }];

    
}

-(void) setItemDetailsContainerLayout {
    [self clearAllContainers];

    [UIView animateWithDuration:0.35 animations:^{

        CGRect rect = CGRectMake(17, 100, 990, 120);
        [container1 setFrame:rect];
        rect = CGRectMake(17, 230, 320, 470);
        [container2 setFrame:rect];
        rect = CGRectMake(347, 230, 990-347+17, 470);
        [container3 setFrame:rect];
        rect = CGRectMake(767, 100, 0, 0);
        [container4 setFrame:rect];
    } completion:^(BOOL finished) {
        [self setupDetailsScreen];
    }];

}


-(void) breadcrumbsItemSelected:(IMCBreadcrumbsItem*)item {
    if (item.dataSource) {
        activeSubmenuDataSource = item.dataSource;
    }
    [self performSelector:item.callback];
}



- (void)viewDidLoad
{
    noNetworkCoverView = nil;
    currentLongMenuImage = nil;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setInitialContainerLayout];
    //[self showProgressIndicator];
    [buttonsPanel setHidden:YES];

}





-(void) startUp {
    [self view]; //Force view loading
    [self setInitialContainerLayout];
    [self showProgressIndicator];
    
    [buttonsPanel setHidden:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([[IMCContentLoader instance] tryAutoLogin]) {
            [self signInWorker];
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showLoginView];
                [progressIndicatorCntrl removeFromSuperview];
            });
        }
    });
}

-(void) setupMainMenu {
    
    IMCMainContentProvider* provider= [[IMCUserSession currentSession] rootContentProvider];
    rootDataSource = [provider getRootMenuDataSource];
    
    if (mainMenuCategoriesCount > 0) {
        [self setupContainer:container1 withMenuForDataSource:cat1DataSource
                    andTitle:[rootDataSource titleForItem:0]];
    }
    
    if (mainMenuCategoriesCount > 1) {
        [self setupContainer:container2 withMenuForDataSource:cat2DataSource
                    andTitle:[rootDataSource titleForItem:1]];
    }
    
    if (mainMenuCategoriesCount > 2) {
        [self setupContainer:container3 withMenuForDataSource:cat3DataSource
                    andTitle:[rootDataSource titleForItem:2]];
    }
    
    if (mainMenuCategoriesCount > 3) {
        [self setupContainer:container4 withMenuForDataSource:cat4DataSource
                    andTitle:[rootDataSource titleForItem:3]];
    }

}

-(void) setupSubMenu{
    
    [container1 addSubview:breadCrumbs];
    breadCrumbs.frame = CGRectMake(10, 0, 900, 40);
    
    IMCAutoLoadableImageView* imageView = [[IMCAutoLoadableImageView alloc]
                                           initWithFrame:CGRectMake(10, 40, 965, 70)];
    [container1 addSubview:imageView];
    NSString* imageName = [NSString stringWithFormat:@"%@_long.jpg", currentLongMenuImage];
    [imageView loadFromURL:[[IMCContentLoader instance] getMenuitemResourceSubPathForName:imageName]];

    [self setupContainer:container3 withMenuForDataSource:activeSubmenuDataSource
                andTitle:nil];
    
    
}

-(void) setupDetailsScreen {
    
    [container1 addSubview:breadCrumbs];
    breadCrumbs.frame = CGRectMake(10, 0, 900, 40);
    
    IMCAutoLoadableImageView* imageView = [[IMCAutoLoadableImageView alloc]
                                           initWithFrame:CGRectMake(10, 40, 965, 70)];
    [container1 addSubview:imageView];
    NSString* imageName = [NSString stringWithFormat:@"%@_long.jpg", currentLongMenuImage];
    [imageView loadFromURL:[[IMCContentLoader instance] getMenuitemResourceSubPathForName:imageName]];
    
    [progressIndicatorCntrl setCenter:CGPointMake(container3.frame.origin.x + container3.bounds.size.width/2,
                                             container3.frame.origin.y +container3.bounds.size.height/2)];
    [self.view addSubview:progressIndicatorCntrl];
    
    CGRect rect = container2.bounds;
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(3, 8, rect.size.width-6, rect.size.height-16) style:UITableViewStylePlain];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setDataSource:activeSubmenuDataSource];
    [tableView setDelegate:self];
    [tableView setContentInset:UIEdgeInsetsMake(5, 0, 5, 0)];
    
    [container2 addSubview:tableView];
    
    IMCGradientImageView* btmImageView = [[IMCGradientImageView alloc] initWithFrame:CGRectMake(0, rect.size.height-23, container2.frame.size.width-10, 15)];
    
    IMCNoCornerView* ncv = (IMCNoCornerView*)container2;
    [btmImageView createGradientWithColor:[ncv visibleBackgroundColor] bFadeToTop:YES];
    
    [container2 addSubview:btmImageView];
    
    IMCGradientImageView* topImageView = [[IMCGradientImageView alloc] initWithFrame:CGRectMake(0, 8, container2.frame.size.width-10, 15)];
    
    [topImageView createGradientWithColor:[ncv visibleBackgroundColor] bFadeToTop:NO];
    
    [container2 addSubview:topImageView];

    
    [container3 addSubview:accordeonView];
    [accordeonView setFrame:CGRectMake(20, 20, container3.frame.size.width-40,
                                       container3.frame.size.height-40)];
    
    [accordeonView setAlpha:0.f];
    [tableView setAlpha:0.f];
    
    __weak IMCDataSource* weakRefToDS = activeSubmenuDataSource;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL bDataLoaded = [weakRefToDS loadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bDataLoaded) {
                [tableView reloadData];
                
                NSIndexPath* p = [(IMCScreenDataSource*)activeSubmenuDataSource pathForFirstCardSetElement];
                if (p) {
                    [tableView selectRowAtIndexPath:p
                                           animated:NO scrollPosition:UITableViewScrollPositionNone];
                    IMCDataSource* child = [weakRefToDS getChildDataSourceForItem:[p row]];
                    

                    [accordeonView setDataSource:(IMCCardDataSource*)child];
                    
                } else {
                    [accordeonView setAlpha:0];
                }
                
                [UIView animateWithDuration:0.2f animations:^{
                    [accordeonView setAlpha:1.f];
                    [tableView setAlpha:1.f];
                    //if ([activeSubmenuDataSource count]) {
                    //}
                 
                }];
                
                

            }
            [progressIndicatorCntrl removeFromSuperview];
        });
    });

    
}


-(void) clearAllContainers {
    [self clearView:container1];
    [self clearView:container2];
    [self clearView:container3];
    [self clearView:container4];
}


-(void) clearView:(UIView*)view {
    for (UIView* v in [view subviews]) {
        [v removeFromSuperview];
    }
}

-(void) setupContainer:(UIView*)container withMenuForDataSource:(IMCDataSource*)ds
              andTitle:(NSString*)title {
    CGRect rect = container.frame;
    rect.origin = CGPointMake(0, 40);
    rect.size.height -= 58;
    UITableView* tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setDataSource:ds];
    [tableView setDelegate:self];
    [container addSubview:tableView];
    
    IMCGradientImageView* imageView = [[IMCGradientImageView alloc] initWithFrame:CGRectMake(0, 40+rect.size.height-15, container.frame.size.width-10, 15)];
    
    IMCNoCornerView* ncv = (IMCNoCornerView*)container;
    [imageView createGradientWithColor:[ncv visibleBackgroundColor] bFadeToTop:YES];
    
    [container addSubview:imageView];
    
    IMCGradientImageView* topImageView = [[IMCGradientImageView alloc] initWithFrame:CGRectMake(0, 40, container.frame.size.width-10, 15)];
    
    [topImageView createGradientWithColor:[ncv visibleBackgroundColor] bFadeToTop:NO];
    
    [container addSubview:topImageView];
    
    [tableView setContentInset:UIEdgeInsetsMake(8, 0, 8, 0)];
    
    if (title) {
        UILabel* titleLabel = [[UILabel alloc]
                               initWithFrame:CGRectMake(10, 0, rect.size.width-20, 45)];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:22.f]];
        [titleLabel setText:[@"/" stringByAppendingString:title]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [container addSubview:titleLabel];
        CGSize size = [[titleLabel text] sizeWithFont:[titleLabel font]];
        
        UILabel* itemCountLabel = [[UILabel alloc]
                                   initWithFrame:CGRectMake(size.width + 18, 0,
                                                            rect.size.width-20-size.width, 45)];
        [itemCountLabel setFont:[UIFont boldSystemFontOfSize:18.f]];
        [itemCountLabel setText:[NSString stringWithFormat:@"(%d)", [ds count]]];
        [itemCountLabel setBackgroundColor:[UIColor clearColor]];
        [itemCountLabel setTextColor:[UIColor grayColor]];
        [container addSubview:itemCountLabel];
    }
    
    [tableView setAlpha:0];
    [UIView animateWithDuration:0.3f animations:^{
    [tableView setAlpha:1];
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IMCMenuDataSource* ds = [tableView dataSource];
    if ([ds isKindOfClass:[IMCMenuDataSource class]]) {
        
        if ([ds isDisabledRow:[indexPath row]]) {
            return;
        }
        
        //currentLongMenuImage = nil;
        
        activeSubmenuDataSource = [ds getChildDataSourceForItem:[indexPath row]];
    
        IMCBreadcrumbsItem* item = nil;
        
        if (ds == cat1DataSource) {
            item = [[IMCBreadcrumbsItem alloc] init];
            item.title = [rootDataSource titleForItem:0];
        } else if (ds == cat2DataSource) {
            item = [[IMCBreadcrumbsItem alloc] init];
            item.title = [rootDataSource titleForItem:1];
        } else if (ds == cat3DataSource) {
            item = [[IMCBreadcrumbsItem alloc] init];
            item.title = [rootDataSource titleForItem:2];
        } else if (ds == cat4DataSource) {
            item = [[IMCBreadcrumbsItem alloc] init];
            item.title = [rootDataSource titleForItem:3];
        }
        
        if (item) {
            
            [breadCrumbs resetBredcrumpsToRoot];
            
            currentLongMenuImage = [ds imageNameForItem:[indexPath row]];
            
            item.callback = @selector(setMenuContainerLayout);
            item.dataSource = nil;
            
            [breadCrumbs pushBreadcrumbsItem:item];
        }
        


        
        item = [[IMCBreadcrumbsItem alloc] init];
        item.title = [ds titleForItem:[indexPath row]];

        if (![ds isToolkitItem:[indexPath row]]) {
            item.callback = @selector(setSubMenuContainerLayout);
            item.dataSource = activeSubmenuDataSource;
            [self setSubMenuContainerLayout];
        } else {
            [self setItemDetailsContainerLayout];
        
            
        }
        [breadCrumbs pushBreadcrumbsItem:item];
    } else {
        
        
        [accordeonView setDataSource:[ds getChildDataSourceForItem:[indexPath row]]];
        [accordeonView setAlpha:0.];
        [UIView animateWithDuration:0.2f animations:^{
            [accordeonView setAlpha:1.f];
        }];

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMCMenuDataSource* ds = [tableView dataSource];
    if ([ds isKindOfClass:[IMCMenuDataSource class]]) {
        if ([ds bCategoryMode]) {
            return 94.f;
        };
    } else if ([ds isKindOfClass:[IMCScreenDataSource class]]) {
        
        return [(IMCScreenDataSource*)ds heightOfItemWithIndex:[indexPath row]];
    }
    
    return 44.f;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showProgressIndicator {
    [progressIndicatorCntrl setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    
    [self.view addSubview: progressIndicatorCntrl];

}


-(IBAction)performLogin:(id)sender {
    
    NSString* name = [loginField text];
    NSString* pass = [passwordField text];

    [self showProgressIndicator];

    [self hideLoginView];
    
    BOOL bRemeberMe = [remeberMeSwitch isOn];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL bSuccess = [[IMCContentLoader instance] setCredentialsWithName:name andPassword:pass  rememberMe:bRemeberMe];        
        if (!bSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showLoginView];
                [progressIndicatorCntrl removeFromSuperview];
            });
        } else {
            [self signInWorker];
        }
        
    });
    
}

-(void) signInWorker{
    NSData* xmlData = [[IMCContentLoader instance] getMainXML];
    [[IMCUserSession currentSession] createContentProviderWithXML:xmlData];
    
    updatesProvider = [[IMCUpdatesProvider alloc] init];
    [updatesProvider loadData];
    
    [self performSelectorOnMainThread:@selector(finishLogin) withObject:nil waitUntilDone:NO];

}


-(void) finishLogin {
    
    [progressIndicatorCntrl removeFromSuperview];
    
    IMCMainContentProvider* provider= [[IMCUserSession currentSession] rootContentProvider];
    IMCMenuDataSource* dataSource = [provider getRootMenuDataSource];
    
    mainMenuCategoriesCount = [dataSource count];
    if (mainMenuCategoriesCount > 0) {
        cat1DataSource = (IMCMenuDataSource*)[dataSource getChildDataSourceForItem:0];
    }
    
    if (mainMenuCategoriesCount > 1) {
        cat2DataSource = (IMCMenuDataSource*)[dataSource getChildDataSourceForItem:1];
    }
    
    if (mainMenuCategoriesCount > 2) {
        cat3DataSource = (IMCMenuDataSource*)[dataSource getChildDataSourceForItem:2];
    }
    
    if (mainMenuCategoriesCount > 3) {
        cat4DataSource = (IMCMenuDataSource*)[dataSource getChildDataSourceForItem:3];
    }
    
    [self setMenuContainerLayout];
    
    IMCBreadcrumbsItem* item = [[IMCBreadcrumbsItem alloc] init];
    item.title = @"Home";
    item.callback = @selector(setMenuContainerLayout);
    item.dataSource = nil;
    
    breadCrumbs = [[IMCBreadcrumbs alloc] initWithRootItem:item];
    
    breadCrumbs.delegate = self;
    
    breadCrumbs.frame = CGRectMake(10, 0, 900, 40);
    
    accordeonView = [[IMCAccordeonView alloc] initWithFrame:CGRectZero andHorizontalOrientation:YES];
}


-(IBAction)showHelpScreen {
    IMCMainContentProvider* provider= [[IMCUserSession currentSession] rootContentProvider];
    
    IMCMenuDataSource* ds = [provider getHelpMenuDataSource];
    activeSubmenuDataSource = [ds getDirectChildDataSourceForItem:0];
    
    IMCBreadcrumbsItem* item = nil;
    
    item = [[IMCBreadcrumbsItem alloc] init];
    item.title = [ds titleForItem:0];
    [breadCrumbs resetBredcrumpsToRoot];
    currentLongMenuImage = [(IMCMenuDataSource*)activeSubmenuDataSource imageNameForItem:0];
    item.callback = @selector(setMenuContainerLayout);
    item.dataSource = nil;
    
    [breadCrumbs pushBreadcrumbsItem:item];
    
    
    
    item = [[IMCBreadcrumbsItem alloc] init];
    item.title = [activeSubmenuDataSource titleForItem:0];

    [self setItemDetailsContainerLayout];
    
    [breadCrumbs pushBreadcrumbsItem:item];
    
    activeSubmenuDataSource = [activeSubmenuDataSource getChildDataSourceForItem:0];
    
}


-(IBAction)showContactsScreen {
    IMCMainContentProvider* provider= [[IMCUserSession currentSession] rootContentProvider];
    IMCContactsViewController* cntrl = [[IMCContactsViewController alloc]
                                        initWithContactItems:[provider getContacts]];
    [self presentViewController:cntrl animated:YES completion:^{
        
    }];
    
}

-(IBAction)showNotificationsScreen {
    IMCNotificationsViewController* cntrl = [[IMCNotificationsViewController alloc]
                                             initWithUpdateProvider:updatesProvider];
    [self presentViewController:cntrl animated:YES completion:^{
        
    }];
}

-(IBAction)logout {
    
    [passwordField setText:@""];
    [loginField setText:@""];
    
    rootDataSource = nil;
    [[IMCUserSession currentSession] clear];
    
    [[IMCContentLoader instance] logOut];
    
    [self setInitialContainerLayout];
    
    [self showLoginView];
    

}



@end
