//
//  IMCScriptsCard.h
//  imc
//
//  Created by Andry Rozdolsky on 4/4/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMCScriptsCard : UIView<UITableViewDelegate, UITableViewDataSource> {
    
    
    NSMutableArray* scripts;
    UITableView* scriptsTable;
    
    NSMutableArray* scriptTexts;
    NSMutableSet* headerItemIds;
    NSMutableDictionary* subheaderItems;
    NSMutableArray* subheaderItemIDs;
    
}

-(id) initWithCardDictionary:(NSDictionary*)dictionary;


@end
