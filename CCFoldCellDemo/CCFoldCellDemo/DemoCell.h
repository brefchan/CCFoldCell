//
//  DemoCell.h
//  CCFoldCellDemo
//
//  Created by eHome on 17/2/23.
//  Copyright © 2017年 Bref. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCFoldCell.h"

@interface DemoCell : CCFoldCell

@property (nonatomic, weak) IBOutlet UILabel *closeNumberLabel;

@property (nonatomic, weak) IBOutlet UILabel *openNumberLabel;

- (void)setNumber:(NSInteger)number;

@end
