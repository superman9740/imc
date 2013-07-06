//
//  IMCCardDataSource.h
//  imc
//
//  Created by Andry Rozdolsky on 2/20/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import "IMCDataSource.h"
#import "IMCBaseCard.h"

@interface IMCCardDataSource : IMCDataSource {
    NSArray* cards;
}

-(id)initWithMenuItems:(NSArray*)items;
-(IMCBaseCard*) getCardViewForItem:(int)itemIndex;


@end
