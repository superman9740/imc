//
//  IMCContactsViewController.h
//  imc
//
//  Created by Andry Rozdolsky on 3/10/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMCContactListItem : NSObject {
    
}

@property (readonly) BOOL isHeader;

@property (readonly) NSString* headerText;

@property (readonly) NSString* contactName;
@property (readonly) NSString* contactGroup;
@property (readonly) NSString* contactPhone;
@property (readonly) NSString* contactEmail;

-(id) initHeaderItemWithText:(NSString*)text;
-(id) initContactItemWithName:(NSString*)name andGroup:(NSString*)group
                     andPhone:(NSString*)phone andEmail:(NSString*)email;

@end



@interface IMCContactsHeaderCell : UITableViewCell

@property IBOutlet UILabel* headerText;

@end



@interface IMCContactsItemCell : UITableViewCell

@property IBOutlet UILabel* name;
@property IBOutlet UILabel* group;
@property IBOutlet UILabel* phone;
@property IBOutlet UILabel* email;

-(IBAction)sendEmail;



@end


@interface IMCContactsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView* contactsTable;
    IBOutlet IMCContactsHeaderCell* tmpHeaderCell;
    IBOutlet IMCContactsItemCell* tmpItemCell;
    
    NSArray* items;
}

-(id)initWithContactItems:(NSArray*)items;

-(IBAction)closePopup;

@end
