//
//  CCRotatedView.h
//  CCFoldCellDemo
//
//  Created by eHome on 17/2/23.
//  Copyright © 2017年 Bref. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCRotatedView : UIView

@property (nonatomic, assign) BOOL hiddenAfterAnimation;
@property (nonatomic, strong) CCRotatedView *backView;

- (void)addBackViewWithHeight:(CGFloat)height color:(UIColor *)color;

- (void)foldingAnimationWithTimingFunctionString:(NSString *)timing from:(CGFloat)from to:(CGFloat)to duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay hidden:(BOOL)hidden;

- (CATransform3D)rotateTransform3d;


@end
