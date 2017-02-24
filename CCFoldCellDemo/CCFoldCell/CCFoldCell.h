//
//  CCFoldingCell.h
//  CCFoldCellDemo
//
//  Created by eHome on 17/2/23.
//  Copyright © 2017年 Bref. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCRotatedView.h"

typedef NS_ENUM(NSInteger,AnimationType) {
AnimationTypeOpen,
AnimationTypeClose
};

@interface CCFoldCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *containerViewTop;

@property (nonatomic, weak) IBOutlet CCRotatedView *foregroundView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *foregroundViewTop;

@property (nonatomic, strong) UIView *animationView;
@property (nonatomic, assign) IBInspectable NSInteger itemCount;
@property (nonatomic, strong) IBInspectable UIColor *backViewColor;

@property (nonatomic, strong) NSMutableArray<CCRotatedView *> *animationItemViews;

- (BOOL)isAnimating;

- (NSTimeInterval)animationDurationWithItemIndex:(NSInteger)itemIndex animationType:(AnimationType)type;

- (void)selectedAnimationByIsSelected:(BOOL)isSelected animated:(BOOL)animated completion:(void(^)())completion;


@end
