//
//  IMCScreenDataSource.h
//  imc
//
//  Created by Andry Rozdolsky on 2/20/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMCDataSource.h"


@interface IMCScreenTableViewCell : UITableViewCell

@property BOOL isHeader;

@end


typedef enum {
    IMC_SMIT_CARD_SET,
    IMC_SMIT_GROUP_TITLE,
    IMC_SMIT_KIT_GROUP,
    IMC_SMIT_ZONE
} IMCScreenMenuItemType;

@interface IMCScreenMenuItem : NSObject

@property IMCScreenMenuItemType itemType;
@property NSString* name;

@end

@interface IMCScreenMenuItemCardSet : IMCScreenMenuItem


@property NSArray* cards;

@end

@interface IMCScreenMenuItemKitGroup : IMCScreenMenuItem


@property NSArray* children;
@property BOOL expanded;

@end



@interface IMCScreenDataSource : IMCDataSource{
    NSArray* displayedMenuItems;
    NSArray* allMenuItems;
}

@property (readonly) NSString* sourceFileName;

-(id) initWithFileName:(NSString*)fileName;
-(BOOL)reloadCardForClickOnRow:(int)ind tableView:(UITableView*)tableView;

-(CGFloat) heightOfItemWithIndex:(int)index;

-(NSIndexPath*) pathForFirstCardSetElement;

@end
