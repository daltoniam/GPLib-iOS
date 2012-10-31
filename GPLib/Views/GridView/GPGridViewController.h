//
//  GPGridViewController.h
//  GPLib
//
//  Created by Dalton Cherry on 10/31/12.
//  Copyright (c) 2012 Lightspeed Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPGridView.h"
#import "GPModel.h"

@interface GPGridViewController : UIViewController<GPGridViewDelegate,GPModelDelegate>
{
    GPLoadingLabel* loadingLabel;
}


@property(nonatomic,retain)GPGridView* gridView;

@property(nonatomic,retain)GPModel* model;

//shows the loading label.
-(void)showLoadingLabel;

//shows the loading label.
-(void)showLoadingLabel:(GPLoadingLabelStyle)style;

//just a simple way to set the model. You can set the property as well.
-(GPModel*)setupModel;

//change the loading label text. Default is Loading...
-(NSString*)loadingText;

@end
