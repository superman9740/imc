//
//  IMCBreadcrumbs.h
//  imc
//
//  Created by Andry Rozdolsky on 2/19/13.
//  Copyright (c) 2013 Andry Rozdolsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMCDataSource.h"

@interface IMCBreadcrumbsItem : NSObject

@property IMCDataSource* dataSource;
@property SEL callback;
@property NSString* title;

@end


@protocol IMCBreadcrumbsDelegate

-(void) breadcrumbsItemSelected:(IMCBreadcrumbsItem*)item;

@end


@interface IMCBreadcrumbs : UIView {
    NSMutableArray* breadcrumbs;
    float height;
}

@property id<IMCBreadcrumbsDelegate> delegate;

-(id) initWithRootItem:(IMCBreadcrumbsItem*)item;
-(void) pushBreadcrumbsItem:(IMCBreadcrumbsItem*)item;
-(void) resetBredcrumpsToRoot;

-(float) getHeight;

-(int) lenght;

@end
