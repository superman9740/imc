//
//  MenuDataSource.m
//  imc
//
//  Created by Andry Rozdolsky on 2/19/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCMenuDataSource.h"
#import "XMLReader.h"
#import "IMCScreenDataSource.h"
#import "IMCContentLoader.h"

#import "QuartzCore/CALayer.h"

#import "globalDefines.h"

static NSString *CellIdentifier = @"IMCMenuTableViewCell";
static NSString *CellNib = @"CategoryTableCell";


@implementation IMCMenuTableViewCell

@synthesize bgImage;
@synthesize higlightedBgImage;
@synthesize label;

- (NSString *) reuseIdentifier {
    return CellIdentifier;
}

@end



@implementation IMCMenuDataSource

-(id) initWithMenuItems:(NSArray*)menuItemsArray useCategoryMode:(BOOL)categoryMode{
    
    self = [super init];
    
    if (self) {
        bCategoryMode = categoryMode;
        menuItems = menuItemsArray;
        
//        for (int i = [menuItems count]-1; i>=0; i--) {
//            
//            NSDictionary* menuItem = [menuItems objectAtIndex:i];
//
//            if ([menuItem xmlGetNodeAttribute:@""]) {
//                i = 0;
//            }
//        }
        
    }
    
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    
    NSDictionary* menuItem = [menuItems objectAtIndex:[indexPath row]];
    
    if (bCategoryMode) {
        
        IMCMenuTableViewCell *catCell = (IMCMenuTableViewCell *)[tableView
                                                              dequeueReusableCellWithIdentifier:CellIdentifier];
        if (catCell == nil) {
            [[NSBundle mainBundle] loadNibNamed:CellNib owner:self options:nil];
            catCell = tmpCategoryCell;
            tmpCategoryCell = nil;
        }
                
        catCell.label.layer.shadowColor = [UIColor blackColor].CGColor;
        catCell.label.layer.shadowOffset = CGSizeMake(5, 5);
        catCell.label.layer.shadowOpacity = 1;
        catCell.label.layer.shadowRadius = 4.0;
        catCell.label.clipsToBounds = NO;
        
        NSString* text = [menuItem xmlGetNodeAttribute:@"id"];
        
        text = [[text uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
                
        BOOL isDisabled = [[menuItem xmlGetNodeAttribute:@"disabled"] isEqualToString:@"true"];
        
        if ([text sizeWithFont:[[catCell label] font]].width> 195) {
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                text = [text stringByReplacingOccurrencesOfString:@"&" withString:@"&\n"];
            }

            
            catCell.label.numberOfLines = 2;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [catCell.label setFrame:CGRectMake(catCell.label.frame.origin.x, 58-27,
                                               195, 27*2)];
                
            }
        } else {
            catCell.label.numberOfLines = 1;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [catCell.label setFrame:CGRectMake(catCell.label.frame.origin.x, 58,
                                               195, 27)];
            }
        }
        
        [catCell.label setText: text];

        
        if (isDisabled) {
            [catCell.bgImage setAlpha:0.4f];
            [catCell.label setAlpha:0.5f];
        } else {
            [catCell.bgImage setAlpha:1.f];
            [catCell.label setAlpha:1.f];
        }
        
        [[catCell bgImage] setImage:nil];
        
        __weak IMCMenuTableViewCell* weakCell = catCell;
        
        [[catCell bgImage] setBackgroundColor:IMC_COKE_RED_COLOR];
        NSString* picName = [menuItem xmlGetNodeAttribute:@"image"];
        
        BOOL bIsCategory = [[menuItem xmlGetNodeAttribute:@"level"] isEqualToString:@"category"];
        
        if (![picName length] || bIsCategory) {
            picName = [self getImageNameForFirstChildOfItemWithIndex:[indexPath row]];
        }
        
        picName = [NSString stringWithFormat:@"%@_up.jpg",picName];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSData* picData = [[IMCContentLoader instance] getMenuitemResourceCached:picName];
            UIImage* pic = [UIImage imageWithData:picData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[weakCell bgImage] setImage:pic];
            });
        });
        
        cell = catCell;
    } else {
        cell = (UITableViewCell *)[tableView
                                        dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"cell"];
        }
        NSString* name = [menuItem xmlGetNodeAttribute:@"id"];
        [cell.textLabel setText: [NSString stringWithFormat:@"/ %@", name]];
        [cell.textLabel setTextColor:IMC_COKE_RED_COLOR];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    

    
    return cell;
}

-(int) count {
    return [menuItems count];
}

-(NSString*) titleForItem:(int)itemIndex {
    NSDictionary* menuItem = [menuItems objectAtIndex:itemIndex];
    return [menuItem xmlGetNodeAttribute:@"id"];

}

-(NSString*) imageNameForItem:(int) itemIndex {
    NSDictionary* menuItem = [menuItems objectAtIndex:itemIndex];
    return [menuItem xmlGetNodeAttribute:@"image"];
}

-(BOOL) isDisabledRow:(int)itemIndex {
    
    NSDictionary* menuItem = [menuItems objectAtIndex:itemIndex];
    return [[menuItem xmlGetNodeAttribute:@"disabled"] isEqualToString:@"true"];
}


-(IMCDataSource*) getDirectChildDataSourceForItem:(int)itemIndex {
    IMCDataSource* res = nil;
    
    NSDictionary* menuItem = [menuItems objectAtIndex:itemIndex];
    
    if (![self isToolkitItem:itemIndex]) {
        NSArray* subItems = [menuItem xmlGetAllChildNodes:@"layer"];
        BOOL bIsCategory = [[menuItem xmlGetNodeAttribute:@"level"] isEqualToString:@"category"];
        res = [[IMCMenuDataSource alloc] initWithMenuItems:subItems useCategoryMode:bIsCategory];
    }
    
    return res;
}

-(IMCDataSource*) getChildDataSourceForItem:(int)itemIndex {
    IMCDataSource* res = nil;

    NSDictionary* menuItem = [menuItems objectAtIndex:itemIndex];
    
    if (![self isToolkitItem:itemIndex]) {
        NSArray* subItems = [menuItem xmlGetAllChildNodes:@"layer"];
        BOOL bIsCategory = [[menuItem xmlGetNodeAttribute:@"level"] isEqualToString:@"category"];
        res = [[IMCMenuDataSource alloc] initWithMenuItems:subItems useCategoryMode:bIsCategory];
        if ([res count] == 1) {
            return [res getChildDataSourceForItem:0];
        }
    } else {
        NSString* name = [menuItem xmlGetNodeAttribute:@"file"];
        res = [[IMCScreenDataSource alloc] initWithFileName:name];
    }
    
    return res;
}

-(NSString*) getImageNameForFirstChildOfItemWithIndex:(int)index {
    
    NSString* imageName = nil;
    
    if (![self isToolkitItem:index]) {
        NSDictionary* menuItem = [menuItems objectAtIndex:index];
        NSArray* subItems = [menuItem xmlGetAllChildNodes:@"layer"];
        if ([subItems count]) {
            imageName = [[subItems objectAtIndex:0] xmlGetNodeAttribute:@"image"];
        }
    }
    
    return imageName;
}

-(BOOL) isToolkitItem:(int)itemIndex {
    NSDictionary* menuItem = [menuItems objectAtIndex:itemIndex];
    NSString* level = [menuItem xmlGetNodeAttribute:@"level"];
    return [[level lowercaseString] isEqualToString:@"toolkit"];
}

-(BOOL) bCategoryMode {
    return bCategoryMode;
}



@end
