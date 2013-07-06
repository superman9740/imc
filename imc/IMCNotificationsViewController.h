//
//  IMCNotificationsViewController.h
//  imc
//
//  Created by Andry Rozdolsky on 3/10/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMCUpdatesProvider.h"

@interface IMCNotificationsItemCell : UITableViewCell

@property IBOutlet UILabel* messageDate;
@property IBOutlet UILabel* messageTitle;
@property IBOutlet UILabel* messageText;

@end


@interface IMCNotificationsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    UITableView* notificationsTable;
    
    IBOutlet IMCNotificationsItemCell* tmpNotificationsCell;
    IMCUpdatesProvider* provider;
}

-(id) initWithUpdateProvider:(IMCUpdatesProvider*)p;
-(IBAction)closePopup;

@end
