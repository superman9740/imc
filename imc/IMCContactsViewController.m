//
//  IMCContactsViewController.m
//  imc
//
//  Created by Andry Rozdolsky on 3/10/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCContactsViewController.h"
#import "XMLReader.h"

@implementation IMCContactListItem

@synthesize isHeader = _isHeader;

@synthesize headerText = _headerText;

@synthesize contactName = _contactName;
@synthesize contactGroup = _contactGroup;
@synthesize contactPhone = _contactPhone;
@synthesize contactEmail = _contactEmail;

-(id) initHeaderItemWithText:(NSString*)text {
    self = [super init];
    if (self) {
        _isHeader = YES;
        _headerText = text;
    }
    
    return self;
}


-(id) initContactItemWithName:(NSString*)name andGroup:(NSString*)group
                     andPhone:(NSString*)phone andEmail:(NSString*)email {
    self = [super init];
    if (self) {
        _isHeader = NO;
        _contactName = name;
        _contactGroup = group;
        _contactPhone = phone;
        _contactEmail = email;
    }
    
    return self;

    
}

@end




@implementation IMCContactsHeaderCell

@synthesize headerText;

@end




@implementation IMCContactsItemCell

@synthesize name;
@synthesize group;
@synthesize phone;
@synthesize email;

-(IBAction)sendEmail {
    if ([[email text] length]) {
        NSString* urlStr = [NSString stringWithFormat:@"mailto:%@", [email text]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];

    }
}

@end




@implementation IMCContactsViewController

- (id)initWithContactItems:(NSArray*)cItems
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        NSMutableDictionary* itemsByCategory = [NSMutableDictionary dictionary];
        NSMutableArray* categoriesInOrder = [NSMutableArray array];
        
        for (NSDictionary* newItemDict in cItems) {
            
            NSString* category = [newItemDict xmlGetNodeAttribute:@"category"];
            
            if (!category ||
                [[[newItemDict xmlGetNodeAttribute: @"hidden"] lowercaseString] isEqual:@"true"]){
                continue;
            }
            
            
            NSMutableArray* categoryItems = [itemsByCategory objectForKey:category];
            if (!categoryItems) {
                categoryItems = [NSMutableArray array];
                [itemsByCategory setObject:categoryItems forKey:category];
                [categoriesInOrder addObject:category];
            }
            
            [categoryItems addObject:newItemDict];
            
        }
        
        NSMutableArray* tmpItems = [NSMutableArray array];
        
        for (NSString* key in categoriesInOrder) {
            [tmpItems addObject:[[IMCContactListItem alloc]initHeaderItemWithText:key]];
            
            for (NSDictionary * itemDict in itemsByCategory[key]) {
                
                NSString* name = [itemDict xmlGetNodeAttribute:@"name"];
                NSString* group = [itemDict xmlGetNodeAttribute:@"group"];
                NSString* phone = [itemDict xmlGetNodeAttribute:@"phone"];
                NSString* email = [[itemDict xmlGetNodeAttribute:@"email"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

                
                [tmpItems addObject:[[IMCContactListItem alloc]initContactItemWithName:name
                                                                              andGroup:group
                                                                              andPhone:phone
                                                                              andEmail:email]];
            }
        }
        
        items = tmpItems;
    }
    return self;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    int height;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        height = 50;
    } else {
        height = 100;
    }
    
    
    IMCContactListItem* menuItem = [items objectAtIndex:[indexPath row]];
    
    if ([menuItem isHeader]) {
        height = 70;
    }
    
    return height;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    
    IMCContactListItem* menuItem = [items objectAtIndex:[indexPath row]];
    
    if ([menuItem isHeader]) {
        
        IMCContactsHeaderCell *catCell = (IMCContactsHeaderCell *)
        [tableView dequeueReusableCellWithIdentifier:@"IMCContactHeaderTableCell"];
        if (catCell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"IMCContactHeaderTableCell" owner:self options:nil];
            catCell = tmpHeaderCell;
            tmpHeaderCell = nil;
        }
        
        NSMutableString *str = [[NSMutableString alloc] initWithString:[menuItem headerText]];
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                                      @"<font.*?>" options:0 error:nil];
        [regex replaceMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@" "];
        
        NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:
                                      @"</font>" options:0 error:nil];
        [regex2 replaceMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@" "];
        
        [[catCell headerText] setText: str];
        
        
        cell = catCell;
    } else {
        IMCContactsItemCell *catCell = (IMCContactsItemCell *)
        [tableView dequeueReusableCellWithIdentifier:@"IMCContactsItemTableCell"];
        if (catCell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"IMCContactItemTableCell" owner:self options:nil];
            catCell = tmpItemCell;
            tmpItemCell = nil;
        }
        
        [[catCell name] setText: [menuItem contactName]];
        [[catCell group] setText: [menuItem contactGroup]];
        [[catCell phone] setText: [menuItem contactPhone]];
        [catCell.phone setUserInteractionEnabled:YES];
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLinkClick:)];
        [catCell.phone addGestureRecognizer:tapGesture];
        
            
        
      //  NSString* tempStr = [NSString stringWithFormat:@"<!DOCTYPE html><html><body><a href=\"tel://%@\" style=\"color: red;\">%@</a>",menuItem.contactPhone, menuItem.contactPhone];
        
     //   [[catCell phone] loadHTMLString:tempStr baseURL:nil];
        
        [[catCell email] setText: [menuItem contactEmail]];
        
        cell = catCell;
    }
    
    
    
    return cell;
}
-(IBAction)handleLinkClick:(id)sender
{
    UIGestureRecognizer* gesture = (UIGestureRecognizer*)sender;
    LabelWithLinks* label = (LabelWithLinks*)gesture.view;

    NSString* alertStr = [NSString stringWithFormat:@"Call phone number %@?", label.text];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Call Number" message:alertStr delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    // optional - add more buttons:
    [alert addButtonWithTitle:@"Call"];
    [alert show];

}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString* url = [NSString stringWithFormat:@"tel://%@",alertView.message];
        url = [url stringByReplacingOccurrencesOfString:@"Call phone number " withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"(" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@")" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"?" withString:@""];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        

    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)closePopup {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
