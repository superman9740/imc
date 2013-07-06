//
//  ViewController.h
//  imc
//
//  Created by Andry Rozdolsky on 2/19/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "IMCMainContentProvider.h"
#import "IMCBreadcrumbs.h"
#import "IMCAccordeonView.h"
#import "IMCUpdatesProvider.h"

@interface ViewController : UIViewController<UITableViewDelegate, IMCBreadcrumbsDelegate, UITextFieldDelegate> {

    NSMutableArray* currentDatasourcesRetainArray;
    
    IMCMenuDataSource* rootDataSource;
    
    IMCMenuDataSource* cat1DataSource;
    IMCMenuDataSource* cat2DataSource;
    IMCMenuDataSource* cat3DataSource;
    IMCMenuDataSource* cat4DataSource;
    
    IMCDataSource* activeSubmenuDataSource;
    
    int mainMenuCategoriesCount;
    
    IMCBreadcrumbs* breadCrumbs;
    IMCAccordeonView* accordeonView;
    
    IBOutlet UIButton* loginBtn;
    
    IMCUpdatesProvider* updatesProvider;
    
    IBOutlet UIView* buttonsPanel;
    
    NSString* currentLongMenuImage;
    
    UIView* noNetworkCoverView;
    
    IBOutlet UIView* noNetworkMessageBox;
    
    IBOutlet UISwitch* remeberMeSwitch;
    
}

@property IBOutlet UIView* progressIndicatorCntrl;

@property IBOutlet UIView* loginView;

@property IBOutlet UITextField* loginField;
@property IBOutlet UITextField* passwordField;

@property IBOutlet UIView* container1;
@property IBOutlet UIView* container2;
@property IBOutlet UIView* container3;
@property IBOutlet UIView* container4;

-(void) startUp;

-(void) setMenuContainerLayout;
-(void) setSubMenuContainerLayout;
-(void) setItemDetailsContainerLayout;

-(IBAction)performLogin:(id)sender;


-(IBAction)showHelpScreen;
-(IBAction)showContactsScreen;
-(IBAction)showNotificationsScreen;
-(IBAction)logout;

@end
