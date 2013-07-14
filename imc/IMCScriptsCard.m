//
//  IMCScriptsCard.m
//  imc
//
//  Created by Andry Rozdolsky on 4/4/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCScriptsCard.h"
#import "XMLReader.h"
#import "globalDefines.h"

@implementation IMCScriptsCard


-(id) initWithCardDictionary:(NSDictionary*)dictionary {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        scripts = [NSMutableArray array];
        scriptTexts = [NSMutableArray array];
        headerItemIds = [NSMutableSet set];
        subheaderItems = [[NSMutableDictionary alloc] initWithCapacity:10];
        subheaderItemIDs = [[NSMutableArray alloc] initWithCapacity:10];
        
        NSArray* items = [dictionary xmlGetAllChildNodes:@"item"];
        int subHeaderCounter = 0;
        NSString* currentSubHeaderStr;
        for (NSDictionary* itemDict in items) {
            if ([[itemDict xmlGetNodeAttribute:@"kind"] isEqualToString:@"script"]) {
                
                NSString* group = [itemDict xmlGetNodeAttribute:@"group"];
                
                if ([group length]) {
                    [headerItemIds addObject:[NSNumber numberWithInt:[scripts count]]];
                    [scripts addObject:itemDict];
                    [scriptTexts addObject:group];
                }
                
                
                [scripts addObject:itemDict];
                //subgroup
                NSString* subgroup = [itemDict xmlGetNodeAttribute:@"subgroup"];
                subgroup = [subgroup stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if (![subgroup length]) {
                    subgroup = @"";
                } else
                {
                    
                   
                }
                
                if([subgroup isEqualToString:currentSubHeaderStr])
                {
                    
                }
                else
                {
                    currentSubHeaderStr = subgroup;
                    [subheaderItemIDs addObject:[NSNumber numberWithInt:subHeaderCounter]];
                    subHeaderCounter++;
                    
                    
                }
                NSString* text = [[itemDict xmlGetLastChildNode:@"text"] xmlGetNodeText];
                text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if (![text length]) {
                    text = @"N/A";
                } else {
                    text = [NSString stringWithFormat:@"[%@]\n\n%@",
                            [itemDict xmlGetNodeAttribute:@"code"],text];
                }
                
                [scriptTexts addObject:text];
                
            }

        }
        
        scriptsTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        
        [scriptsTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:scriptsTable];
        [scriptsTable setDataSource:self];
        [scriptsTable setDelegate:self];
        
        UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 280, 20)];
        
        [title setText:[dictionary xmlGetNodeAttribute:@"approved"]];
        
        [title setFont:[UIFont systemFontOfSize:15.f]];
        
        [self addSubview:title];
        
        
    }
    
    return self;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return subheaderItemIDs.count;
    
}
-(int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count = scripts.count;
    return count;
}


-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"scriptsCell"];
    
    if ([headerItemIds containsObject:[NSNumber numberWithInt:[indexPath row]]])
    {
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        
        NSString* groupName = [scriptTexts objectAtIndex: [indexPath row]];
        
        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 400, 22)];
        
        [lbl setFont:[UIFont systemFontOfSize:16.f]];
        
        [lbl setText: groupName];
        [lbl setNumberOfLines:0];
        
        [cell addSubview:lbl];
        
    }
    else if ([subheaderItemIDs containsObject:[NSNumber numberWithInt:[indexPath row]]])
    {
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        
        NSString* subgroupName = [scriptTexts objectAtIndex: [indexPath row]];
        
        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 400, 22)];
        
        [lbl setFont:[UIFont systemFontOfSize:16.f]];
        
        [lbl setText: subgroupName];
        [lbl setNumberOfLines:0];
        
        [cell addSubview:lbl];
        
    }
  else
  {
        NSDictionary* item = [scripts objectAtIndex: [indexPath row]];
        
        NSString* length = [item xmlGetNodeAttribute:@"length"];
        NSString* code = [item xmlGetNodeAttribute:@"code"];
      
        
        UIFont *boldFont = [UIFont systemFontOfSize:16.f];
        UIFont *regularFont = [UIFont systemFontOfSize:12.f];
        UIColor *foregroundColor = IMC_RED_COLOR;
        
        // Create the attributes
        
        NSString* labelText = [NSString stringWithFormat:@"/%@ (%@)", length, code];
        
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               boldFont, NSFontAttributeName,
                               foregroundColor, NSForegroundColorAttributeName, nil];
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                  regularFont, NSFontAttributeName,
                                  foregroundColor,NSForegroundColorAttributeName, nil];
        const NSRange range = NSMakeRange([length length]+2,[code length]+2);
        
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        
        
        // Create the attributed string (text + attributes)
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:labelText
                                               attributes:attrs];
        [attributedText setAttributes:subAttrs range:range];
        
        // Set it in our UILabel and we are done!
        [[cell textLabel] setAttributedText:attributedText];

   }
   
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![headerItemIds containsObject:[NSNumber numberWithInt:[indexPath row]]]) {
        NSDictionary* paramsDict = [NSDictionary dictionaryWithObjects:@[scriptTexts,
                                    [NSNumber numberWithInt:[indexPath row]]]
                                                               forKeys:@[@"scripArray", @"activeScriptIndex"]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SCRIPT_PREVIEW_NOTIFICATION object:nil userInfo:paramsDict];
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.f;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    NSString* tempStr = @"subheader";
    
    return tempStr;
    

}




-(void) layoutSubviews {
    
    [scriptsTable setFrame:CGRectMake(10, 50, self.bounds.size.width-20, self.bounds.size.height-60)];
    
    [super layoutSubviews];
}


@end
