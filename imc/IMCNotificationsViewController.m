//
//  IMCNotificationsViewController.m
//  imc
//
//  Created by Andry Rozdolsky on 3/10/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCNotificationsViewController.h"


@implementation IMCNotificationsItemCell



@end

@interface IMCNotificationsViewController ()



@end

@implementation IMCNotificationsViewController

-(id) initWithUpdateProvider:(IMCUpdatesProvider*)p {

    self = [super init];
    
    if (self) {
        provider = p;
    }
    
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"M/d/YY"];
    NSString *dateString = [dateFormat stringFromDate:date];
    _dateLabel.text = [NSString stringWithFormat:@"(as of %@)", dateString];
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [provider updatesCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IMCUpdateMessage* message = [provider getUpdateMessageAtIndex:[indexPath row]];
    
    IMCNotificationsItemCell *catCell = (IMCNotificationsItemCell *)
    [tableView dequeueReusableCellWithIdentifier:@"IMCNotificationsItemCell"];
    if (catCell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"IMCNotificationsTableCell" owner:self options:nil];
        catCell = tmpNotificationsCell;
        tmpNotificationsCell = nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d"];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    NSString *dateStr = [dateFormatter stringFromDate:[message messageDate]];
    

    NSDateFormatter *monthDayFormatter = [[NSDateFormatter alloc] init];
    [monthDayFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [monthDayFormatter setDateFormat:@"d"];
    int date_day = [[monthDayFormatter stringFromDate:[message messageDate]] intValue];
    NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
    NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
    NSString *suffix = [suffixes objectAtIndex:date_day];
    dateStr = [dateStr stringByAppendingString:suffix];

    [[catCell messageDate] setText:dateStr];
    [[catCell messageTitle] setText:[message messageTitle]];
    [[catCell messageText] setText:[message messageText]];
    
    int rowWidth;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        rowWidth = 878;
    } else {
        rowWidth = 237;
    }
    
    CGSize sTitle = [[message messageTitle] sizeWithFont:[UIFont boldSystemFontOfSize:19.f]
                                       constrainedToSize:CGSizeMake(rowWidth,10000)];
    
    CGSize sText = [[message messageText] sizeWithFont:[UIFont systemFontOfSize:16.f]
                                     constrainedToSize:CGSizeMake(rowWidth,10000)];
    
    CGRect r = [[catCell messageTitle] frame];
    r.size.height = sTitle.height;
    [[catCell messageTitle] setFrame:r];
    
    r = [[catCell messageText] frame];
    r.size.height = sText.height;
    r.origin.y = sTitle.height + 54;
    [[catCell messageText] setFrame:r];
    

        
      //  [[catCell headerText] setText: [menuItem headerText]];
    
    
    return catCell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IMCUpdateMessage* message = [provider getUpdateMessageAtIndex:[indexPath row]];
    
    int rowWidth;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        rowWidth = 878;
    } else {
        rowWidth = 237;
    }
    
    CGSize sTitle = [[message messageTitle] sizeWithFont:[UIFont boldSystemFontOfSize:19.f]
                                 constrainedToSize:CGSizeMake(rowWidth,10000)];
    
    CGSize sText = [[message messageText] sizeWithFont:[UIFont systemFontOfSize:16.f]
                      constrainedToSize:CGSizeMake(rowWidth,10000)];
    
    
    return 92 + sTitle.height + sText.height;
}


-(IBAction)closePopup {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
