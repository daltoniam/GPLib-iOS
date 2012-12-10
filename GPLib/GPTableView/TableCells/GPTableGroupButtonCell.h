//
//  GPTableGroupButtonCell.h
//  GPLib
//
//  Created by Dalton Cherry on 12/10/12.
//  Copyright (c) 2012 Lightspeed Systems. All rights reserved.
//

#import "GPTableCell.h"

@interface GPTableGroupButtonCell : GPTableCell
{
    UIButton* leftButton;
    UIButton* rightButton;
}

@property(nonatomic,assign)id delegate;

@end
