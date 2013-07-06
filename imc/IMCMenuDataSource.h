//
//  MenuDataSource.h
//  imc
//
//  Created by Andry Rozdolsky on 2/19/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMCDataSource.h"


@interface IMCMenuTableViewCell : UITableViewCell {
    
}

@property IBOutlet UIImageView* bgImage;
@property IBOutlet UIImageView* higlightedBgImage;

@property IBOutlet UILabel* label;

@end


@interface IMCMenuDataSource : IMCDataSource {
    NSArray* menuItems;
    BOOL bCategoryMode;
    
    IBOutlet IMCMenuTableViewCell* tmpCategoryCell;
}

-(NSString*) imageNameForItem:(int) itemIndex;

-(id) initWithMenuItems:(NSArray*)menuItemsArray useCategoryMode:(BOOL)bCategoryMode;

-(BOOL) isToolkitItem:(int)itemIndex;
-(BOOL) bCategoryMode;

-(BOOL) isDisabledRow:(int)itemIndex;
-(IMCDataSource*) getDirectChildDataSourceForItem:(int)itemIndex;

@end
