//
//  IMCScreenDataSource.m
//  imc
//
//  Created by Andry Rozdolsky on 2/20/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCScreenDataSource.h"
#import "IMCCardDataSource.h"
#import "XMLReader.h"
#import "IMCContentLoader.h"
#import "globalDefines.h"

@implementation IMCScreenTableViewCell

@synthesize isHeader;


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (!isHeader) {
        if (selected) {
            [self.textLabel setTextColor:[UIColor blackColor]];
        } else {
            [self.textLabel setTextColor:IMC_COKE_RED_COLOR];
        }
    }

}

@end




@implementation IMCScreenMenuItem

@synthesize itemType;
@synthesize name;

@end



@implementation IMCScreenMenuItemCardSet


@synthesize cards;

@end



@implementation IMCScreenMenuItemKitGroup


@synthesize children;
@synthesize expanded;

@end


@implementation IMCScreenDataSource

@synthesize sourceFileName = _sourceFileName;



-(id) initWithFileName:(NSString*)fileName {
    self = [super init];
    
    if (self) {
        _sourceFileName = fileName;
    }
    
    return self;
}




-(BOOL) loadData {
    
    NSData* data = [[IMCContentLoader instance] getToolkitXML:_sourceFileName];
    
    if ([data length] == 0) {
        return NO;
    }
    
    NSError *parseError = nil;
    NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:data error:&parseError];
    
    if (parseError) {
        return NO;
    }
    
    NSDictionary *config = [xmlDictionary xmlGetLastChildNode:@"data"];
    
    allMenuItems = [self prepareMenuItemsList:[[config xmlGetLastChildNode:@"screens"] xmlGetAllChildNodes:@"screen"]];
    
    [self buildDiplayedMenuItemList];
    
    return YES;

}




-(NSArray*) prepareMenuItemsList:(NSArray*)plainXmlMenuItemList  {
    
    NSMutableArray* tmpArray = [NSMutableArray array];
    
    NSMutableArray* currentItemsArray = tmpArray;
    
    NSString* curKitName = nil;
    NSString* curGroupName = nil;
    NSString* curZone = nil;

    
    
    for (NSDictionary* dict in plainXmlMenuItemList) {
        
        NSString* kitgroup = [dict xmlGetNodeAttribute:@"kit_group"];
        if(![kitgroup isEqualToString:curKitName] && kitgroup) {
            IMCScreenMenuItemKitGroup* itm = [[IMCScreenMenuItemKitGroup alloc] init];
            [itm setName:kitgroup];
            [itm setItemType:IMC_SMIT_KIT_GROUP];
            
            currentItemsArray = [NSMutableArray array];
            
            [itm setChildren:currentItemsArray];
            [itm setExpanded:NO];
            
            [tmpArray addObject:itm];
            
            curKitName = kitgroup;
        }
        
        
        NSString* group = [dict xmlGetNodeAttribute:@"group"];
        if(![group isEqualToString:curGroupName] && group) {
            IMCScreenMenuItem* itm = [[IMCScreenMenuItem alloc] init];
            [itm setName:group];
            [itm setItemType:IMC_SMIT_GROUP_TITLE];
            [currentItemsArray addObject:itm];
            
            curGroupName = group;
        }
        
        NSString* zone = [dict xmlGetNodeAttribute:@"zone"];
        if (zone && ![zone isEqualToString:curZone]) {
            IMCScreenMenuItem* itm = [[IMCScreenMenuItem alloc] init];
            [itm setName:zone];
            [itm setItemType:IMC_SMIT_ZONE];
            [currentItemsArray addObject:itm];
            
            curZone = zone;
            
        }
        
        IMCScreenMenuItemCardSet* itm = [[IMCScreenMenuItemCardSet alloc] init];
        [itm setName:[dict xmlGetNodeAttribute:@"title"]];
        [itm setCards:[dict xmlGetAllChildNodes:@"card"]];
        [itm setItemType:IMC_SMIT_CARD_SET];
        [currentItemsArray addObject:itm];
    }
    
    return tmpArray;
}




-(BOOL)reloadCardForClickOnRow:(int)ind tableView:(UITableView*)tableView {
    IMCScreenMenuItem* menuItem = [displayedMenuItems objectAtIndex:ind];
    
    if ([menuItem itemType] == IMC_SMIT_KIT_GROUP) {
        NSIndexPath* selectedIndex = [tableView indexPathForSelectedRow];
        NSObject* selectedItem = [displayedMenuItems objectAtIndex:[selectedIndex row]];
        IMCScreenMenuItemKitGroup* kit = (IMCScreenMenuItemKitGroup*)menuItem;
        [kit setExpanded:![kit expanded]];
        [self buildDiplayedMenuItemList];
        [tableView reloadData];
        
        int newSelectedIndex = [displayedMenuItems indexOfObject:selectedItem];
        
        if (newSelectedIndex != NSNotFound) {
            [tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:newSelectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    return [menuItem itemType] == IMC_SMIT_CARD_SET;
}




-(void) buildDiplayedMenuItemList {
    NSMutableArray* tmpArray = [NSMutableArray array];
    for (IMCScreenMenuItem* itm in allMenuItems) {
        
        [tmpArray addObject:itm];
        
        if ([itm itemType] == IMC_SMIT_KIT_GROUP) {
            IMCScreenMenuItemKitGroup* kitGrpup = (IMCScreenMenuItemKitGroup*)itm;
            
            if ([kitGrpup expanded]) {
                [tmpArray addObjectsFromArray:[kitGrpup children]];
            }
        }
        
    }
    displayedMenuItems = tmpArray;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [displayedMenuItems count];
}



-(NSString*) titleForItem:(int)itemIndex {
    IMCScreenMenuItem* menuItem = [displayedMenuItems objectAtIndex:itemIndex];
    return [menuItem name];
}



-(NSIndexPath*) pathForFirstCardSetElement {
    
    int i =0;
    for (; i < [displayedMenuItems count]; i++) {
        if ([displayedMenuItems[i] itemType] == IMC_SMIT_CARD_SET) {
            break;
        }
    }
    
    return (i < [displayedMenuItems count])?[NSIndexPath indexPathForItem:i inSection:0]:nil;
    
}

-(CGFloat) setUpTextLabel:(UILabel*)labl forItem:(IMCScreenMenuItem*)menuItem {
    
    labl.numberOfLines = 0;
    
    CGSize labelSize = CGSizeMake(289, 100000);
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        labelSize.width = 264;
    }
    
    NSString* text;
    if ([menuItem itemType] == IMC_SMIT_KIT_GROUP) {
        IMCScreenMenuItemKitGroup* kit = (IMCScreenMenuItemKitGroup*)menuItem;
        if ([kit expanded]) {
            text = [NSString stringWithFormat:@"^ %@", [menuItem name]];
        } else {
            text = [NSString stringWithFormat:@"> %@", [menuItem name]];
        }
        
        [labl setText: text];
        [labl setFont:[UIFont fontWithName:IMC_MEDIUM_FONT_NAME size:16.f]];
        
    } else if ([menuItem itemType] == IMC_SMIT_GROUP_TITLE) {
        
        labelSize.width = 260;
        
        text = [NSString stringWithFormat:@"%@", [[menuItem name] uppercaseString]];
                
        [labl setText: text];
        
        [labl setBackgroundColor:[UIColor clearColor]];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [labl setFont:[UIFont fontWithName:IMC_THIN_FONT_NAME size:19.f]];
        } else {
            [labl setFont:[UIFont fontWithName:IMC_THIN_FONT_NAME size:17.f]];
        }
        
        [labl setTextColor:IMC_GRAY_COLOR];
        
    } else if ([menuItem itemType] == IMC_SMIT_ZONE) {
        
        text = [NSString stringWithFormat:@"ZONE %@", [menuItem name]];
        [labl setText: text];
        [labl setFont:[UIFont fontWithName:IMC_BOLD_FONT_NAME size:12.f]];
        [labl setTextColor:IMC_GRAY_COLOR];
        
    } else {
        
        text = [NSString stringWithFormat:@"/ %@", [menuItem name]];
        [labl setText: text];
        [labl setFont:[UIFont fontWithName:IMC_MEDIUM_FONT_NAME size:16.f]];

    }
    
    CGSize actualSize = [text sizeWithFont:[labl font] constrainedToSize:labelSize];
    
    CGRect frame =  [labl frame];
    frame.size = actualSize;
    [labl setFrame:frame];
    
    return actualSize.height;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    IMCScreenTableViewCell *cell = [[IMCScreenTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"screenTableCell"];
    

    
    IMCScreenMenuItem* menuItem = [displayedMenuItems objectAtIndex:[indexPath row]];
    NSString* text;
    
    if ([menuItem itemType] == IMC_SMIT_KIT_GROUP) {
        
        [self setUpTextLabel:cell.textLabel forItem:menuItem];
        
        [cell setIsHeader:NO];
        
    } else if ([menuItem itemType] == IMC_SMIT_GROUP_TITLE) {
        
        text = [NSString stringWithFormat:@"%@", [[menuItem name] uppercaseString]];
        
        UILabel* textlabel = [[UILabel alloc] initWithFrame:CGRectMake(9.f, 10.f, 260.f, 25.f)];
        
        [self setUpTextLabel:textlabel forItem:menuItem];

        [cell addSubview:textlabel];
        [cell setIsHeader:YES];
        
    } else if ([menuItem itemType] == IMC_SMIT_ZONE) {
        
        [self setUpTextLabel:cell.textLabel forItem:menuItem];
        [cell setIsHeader:YES];
        
    } else {
        
        [self setUpTextLabel:cell.textLabel forItem:menuItem];
        [cell setIsHeader:NO];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}



-(CGFloat) heightOfItemWithIndex:(int)index {
    
    
    
    IMCScreenMenuItem* menuItem = [displayedMenuItems objectAtIndex:index];
    
    
    CGFloat f = [self setUpTextLabel:[[UILabel alloc] init]  forItem:menuItem];
    
    CGFloat heigth = 7.f + f;
    
    switch ([menuItem itemType]) {
            
        case IMC_SMIT_GROUP_TITLE:
            heigth = 8.f+f;
            break;
            
        case IMC_SMIT_ZONE:
            heigth = 12.f + f;
            break;
            
        default:
            break;
    }
    
    return heigth;
}


-(IMCDataSource*) getChildDataSourceForItem:(int)itemIndex {
    
    IMCScreenMenuItem* menuItem = [displayedMenuItems objectAtIndex:itemIndex];
    
    if ([menuItem itemType] == IMC_SMIT_CARD_SET) {
        IMCScreenMenuItemCardSet* menuItemCS = (IMCScreenMenuItemCardSet*)menuItem;
        NSArray* subItems = [menuItemCS cards];
        return [[IMCCardDataSource alloc] initWithMenuItems:subItems];
    }

    return nil;
}



@end
