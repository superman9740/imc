//
//  ViewController_iPhone.h
//  imc
//
//  Created by Andry Rozdolsky on 3/30/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMCMainContentProvider.h"
#import "IMCBreadcrumbs.h"
#import "IMCAccordeonView.h"
#import "IMCUpdatesProvider.h"

#import "IMCGradientImageView.h"


@interface ViewController_iPhone : UIViewController<UITableViewDelegate, IMCBreadcrumbsDelegate, UITextFieldDelegate> {
    
    IBOutlet UIView* passwordForm;
    IBOutlet UIView* menuPopup;
    IBOutlet UISwitch* rememberMeSwitch;
    
    UIButton* menuPopupBgButton;
    
    IBOutlet UITextField* loginField;
    IBOutlet UITextField* passwordField;
    IBOutlet UIButton* loginBtn;
    
    IBOutlet UIActivityIndicatorView* loginProgressIndicator;
    IBOutlet UIActivityIndicatorView* activityIndicator;
    
    IMCGradientImageView* bottomShadowImageView;
    IMCGradientImageView* topShadowImageView;

    IMCGradientImageView* leftShadowImageView;
    IMCGradientImageView* rightShadowImageView;

    
    IMCBreadcrumbs* breadCrumbs;
    IMCAccordeonView* accordeonView;
    
    UITableView* tableView;
    
    IMCMenuDataSource* currentDataSource;
    IMCUpdatesProvider* updatesProvider;
    
    
    IBOutlet UIView* contentView;
}

@end
