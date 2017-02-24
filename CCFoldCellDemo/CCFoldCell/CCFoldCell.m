//
//  CCFoldingCell.m
//  CCFoldCellDemo
//
//  Created by eHome on 17/2/23.
//  Copyright © 2017年 Bref. All rights reserved.
//

#import "CCFoldCell.h"
#import "UIView+Snapshot.h"

IB_DESIGNABLE
@implementation CCFoldCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self commonInit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)commonInit
{
    [self configureDefaultState];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.containerView.layer.cornerRadius = self.foregroundView.layer.cornerRadius;
    self.containerView.layer.masksToBounds = YES;
}

- (void)configureDefaultState
{
    NSLayoutConstraint *foregroundViewTop = self.foregroundViewTop;
    NSLayoutConstraint *containerViewTop = self.containerViewTop;
    
    NSAssert(foregroundViewTop != nil, @"set foregroundViewTop constraint outlets");
    NSAssert(containerViewTop != nil, @"set containerViewTop constraint outlaets");

    containerViewTop.constant = foregroundViewTop.constant;
    self.containerView.alpha = 0;
    
    NSMutableArray<NSLayoutConstraint *> *filterArray = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.foregroundView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight && constraint.secondItem == nil) {
            [filterArray addObject:constraint];
        }
    }
    
    CGFloat height = filterArray.firstObject.constant;
    
    if (height) {
        self.foregroundView.layer.anchorPoint = CGPointMake(0.5, 1);
        self.foregroundViewTop.constant += height / 2;
    }
    self.foregroundView.layer.transform = [self.foregroundView rotateTransform3d];
    
    [self createAnimationView];
    [self.contentView bringSubviewToFront:self.foregroundView];
}

- (void)createAnimationView
{
    self.animationView = [[UIView alloc] initWithFrame:self.containerView.frame];
    
    self.animationView.layer.cornerRadius = self.foregroundView.layer.cornerRadius;
    self.animationView.backgroundColor = [UIColor clearColor];
    self.animationView.translatesAutoresizingMaskIntoConstraints = NO;
    self.animationView.alpha = 0;
    
    UIView *animationView = self.animationView;
    
    if (!animationView) return;
    
    [self.contentView addSubview:animationView];
    
    NSMutableArray<NSLayoutConstraint *> *newConstraints = [NSMutableArray array];
    
    for (NSLayoutConstraint *constraint in self.contentView.constraints) {
        UIView *item = constraint.firstItem;
        UIView *secondItem = constraint.secondItem;
        if (item == self.containerView) {
            NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:animationView
                                                                             attribute:constraint.firstAttribute
                                                                             relatedBy:constraint.relation
                                                                                toItem:constraint.secondItem
                                                                             attribute:constraint.secondAttribute
                                                                            multiplier:constraint.multiplier
                                                                              constant:constraint.constant];
            
            [newConstraints addObject:newConstraint];
        }else if (secondItem == self.containerView)
        {
            NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:constraint.firstItem
                                                                             attribute:constraint.firstAttribute
                                                                             relatedBy:constraint.relation
                                                                                toItem:animationView
                                                                             attribute:constraint.secondAttribute
                                                                            multiplier:constraint.multiplier
                                                                              constant:constraint.constant];
            [newConstraints addObject:newConstraint];
        }
    }
    
    [self.contentView addConstraints:newConstraints];
    
    for (NSLayoutConstraint *constraint in self.containerView.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:animationView
                                                                             attribute:constraint.firstAttribute
                                                                             relatedBy:constraint.relation
                                                                                toItem:nil
                                                                             attribute:constraint.secondAttribute
                                                                            multiplier:constraint.multiplier
                                                                              constant:constraint.constant];
            [animationView addConstraint:newConstraint];
        }
    }
}

- (void)addImageItemsToAnimationView
{
    self.containerView.alpha = 1;
    CGSize containerSize = self.containerView.bounds.size;
    CGSize foregroundSize = self.foregroundView.bounds.size;
    
    //添加第一张图片
    UIImage *image = [self.containerView takeSnapshotWithFrame:CGRectMake(0, 0, containerSize.width, foregroundSize.height)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, containerSize.width, foregroundSize.height);
    
    imageView.tag = 0;
    imageView.layer.cornerRadius = self.foregroundView.layer.cornerRadius;
    
    if(self.animationView)
      [self.animationView addSubview:imageView];
    
    //添加第二张图片
    image = [self.containerView takeSnapshotWithFrame:CGRectMake(0, foregroundSize.height, containerSize.width, foregroundSize.height)];
    
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.frame = CGRectMake(0, 0, containerSize.width, foregroundSize.height);
    CCRotatedView *rotatedView = [[CCRotatedView alloc] initWithFrame:CGRectMake(0, foregroundSize.height, containerSize.width, foregroundSize.height)];
    rotatedView.tag = 1;
    rotatedView.alpha = 0;
    rotatedView.layer.anchorPoint = CGPointMake(0.5, 0);
    rotatedView.layer.transform = [rotatedView rotateTransform3d];
    
    [rotatedView addSubview:imageView];
    
    if (self.animationView)
        [self.animationView addSubview:rotatedView];
    
    rotatedView.frame = CGRectMake(imageView.frame.origin.x, foregroundSize.height, containerSize.width, foregroundSize.height);
    
    CGFloat itemHeight = (containerSize.height - 2 * foregroundSize.height) / (self.itemCount - 2.f);
    
    if (self.itemCount == 2) {
        NSAssert(containerSize.height - 2 * foregroundSize.height != 0, @"contanerView.height too high");
    }else
    {
        NSAssert(containerSize.height - 2 * foregroundSize.height >= itemHeight, @"contanerView.height too high");
    }
    
    CGFloat yPositon = 2 * foregroundSize.height;
    NSInteger tag = 2;
    
    for (NSInteger i = 2; i < self.itemCount; i ++) {
        image = [self.containerView takeSnapshotWithFrame:CGRectMake(0, yPositon, containerSize.width, itemHeight)];
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.frame = CGRectMake(0, 0, containerSize.width, itemHeight);
        CCRotatedView *otherRotatedView = [[CCRotatedView alloc] initWithFrame:CGRectMake(0, yPositon, containerSize.width, itemHeight)];
        otherRotatedView.alpha = 0;
        [otherRotatedView addSubview:imageView];
        otherRotatedView.layer.anchorPoint = CGPointMake(0.5, 0);
        otherRotatedView.layer.transform = [otherRotatedView rotateTransform3d];
        otherRotatedView.frame = CGRectMake(0, yPositon, otherRotatedView.bounds.size.width, itemHeight);
        otherRotatedView.tag = tag;

        if (self.animationView)
            [self.animationView addSubview:otherRotatedView];
        
        
        yPositon += itemHeight;
        tag += 1;
    }
    
    self.containerView.alpha = 0;
    
    UIView *animationView = self.animationView;
    if (animationView) {
        CCRotatedView *previusView;
        NSArray *sortArray = [animationView.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView *  _Nonnull obj1, UIView *  _Nonnull obj2) {
            if (obj1.tag < obj2.tag) {
                return NSOrderedAscending;
            }else if (obj1.tag == obj2.tag)
            {
                return NSOrderedSame;
            }else
            {
                return NSOrderedDescending;
            }
        }];
        
        
        for (CCRotatedView *container in sortArray) {
            if (![container isKindOfClass:[CCRotatedView class]]) {
                continue;
            }
            NSLog(@"%ld",container.tag);
            if (container.tag > 0 && container.tag < animationView.subviews.count) {
                if (previusView) {
                    [previusView addBackViewWithHeight:container.bounds.size.height color:self.backViewColor];
                }
                previusView = container;

            }
        }
        
    }
    
    self.animationItemViews = [self createAnimationItemView];
}

- (void)removeImageItemsFromAnimationView
{
    UIView *animationView = self.animationView;
    
    if (animationView)
        [animationView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
}

- (NSMutableArray<CCRotatedView *> *)createAnimationItemView
{
    UIView *animationView = self.animationView;
    
    NSAssert(animationView != nil, @"animationView is nil");
    
    NSMutableArray<CCRotatedView *> *items = [NSMutableArray array];
    [items addObject:self.foregroundView];
    
    NSMutableArray<CCRotatedView *> *rotatedViews = [NSMutableArray array];

    NSMutableArray<CCRotatedView *> *fileterArray = [NSMutableArray array];
    for (UIView *view in animationView.subviews) {
        if ([view isKindOfClass:[CCRotatedView class]]) {
            CCRotatedView *rotatedView = (CCRotatedView *)view;
            [fileterArray addObject:rotatedView];
        }
    }
    
    NSArray *sortArray = [fileterArray sortedArrayUsingComparator:^NSComparisonResult(UIView *  _Nonnull obj1, UIView *  _Nonnull obj2) {
        if (obj1.tag < obj2.tag) {
            return NSOrderedAscending;
        }else if (obj1.tag == obj2.tag)
        {
            return NSOrderedSame;
        }else
        {
            return NSOrderedDescending;
        }
    }];
    
    
    
    for (CCRotatedView *itemView in sortArray) {
        [rotatedViews addObject:itemView];
        CCRotatedView *backView = itemView.backView;
        if (backView) {
            [rotatedViews addObject:backView];
        }
    }
    
    [items addObjectsFromArray:rotatedViews];
    return items;
}

- (void)configureAnimationItemsWithAnimationType:(AnimationType)animationType
{
    NSArray *animationViewSubViews = self.animationView.subviews;
    
    NSAssert(animationViewSubViews != nil, @"animationViewSubView is nil");
    
    NSMutableArray *animationSubRotatedViews = [NSMutableArray array];
    
    for (UIView *view in animationViewSubViews) {
        if ([view isKindOfClass:[CCRotatedView class]]) {
            [animationSubRotatedViews addObject:view];
        }
    }
    
    if (animationType == AnimationTypeOpen) {
        for (UIView *view in animationSubRotatedViews) {
            view.alpha = 0;
        }
    }else
    {
        for (CCRotatedView *view in animationSubRotatedViews) {
            view.alpha = 1;
            view.backView.alpha = 0;
        }
    }
}


- (void)selectedAnimationByIsSelected:(BOOL)isSelected animated:(BOOL)animated completion:(void(^)())completion
{
    if (isSelected) {
        if (animated) {
            self.containerView.alpha = 0;
            [self openAnimationWithCompletion:completion];
        }else
        {
            self.foregroundView.alpha = 0;
            self.containerView.alpha = 1;
        }
    }else
    {
        if (animated) {
            [self closeAnimationWithCompletion:completion];
        }else
        {
            self.foregroundView.alpha = 1;
            self.containerView.alpha = 0;
        }
    }
}

- (BOOL)isAnimating
{
    return self.animationView.alpha == 1 ? YES : NO;
}

- (NSTimeInterval)animationDurationWithItemIndex:(NSInteger)itemIndex animationType:(AnimationType)type
{
    NSAssert(NO, @"added this method to cell");
    return 0;
}

- (NSMutableArray<NSNumber *> *)durationSequenceWithType:(AnimationType)type
{
    NSMutableArray *durations = [NSMutableArray array];
    
    for (int index = 0; index < self.itemCount - 1; index ++) {
        NSTimeInterval duration = [self animationDurationWithItemIndex:index animationType:type];
        [durations addObject:@(duration / 2)];
        [durations addObject:@(duration / 2)];
    }
    return durations;
}

- (void)openAnimationWithCompletion:(void(^)())completion
{
    [self removeImageItemsFromAnimationView];
    [self addImageItemsToAnimationView];
    
    UIView *animationView = self.animationView;
    if (!animationView) return;
    
    animationView.alpha = 1;
    self.containerView.alpha = 0;
    
    NSMutableArray<NSNumber *> *durations = [self durationSequenceWithType:AnimationTypeOpen];
    
    NSTimeInterval delay = 0;
    NSString *timing = kCAMediaTimingFunctionEaseIn;
    CGFloat from = 0.f;
    CGFloat to = -M_PI / 2;
    BOOL hidden = YES;
    
    NSMutableArray *animationItemViews = self.animationItemViews;
    if (!animationItemViews) { return; }

    for (int index = 0; index < animationItemViews.count; index ++) {
        CCRotatedView *animatedView = animationItemViews[index];
        
        [animatedView foldingAnimationWithTimingFunctionString:timing from:from to:to duration:durations[index].doubleValue delay:delay hidden:hidden];
        
        from = from == 0.f ? M_PI / 2 : 0.f;
        to = to == 0.f ? - M_PI / 2 : 0.f;
        timing = timing == kCAMediaTimingFunctionEaseIn ? kCAMediaTimingFunctionEaseOut : kCAMediaTimingFunctionEaseIn;
        hidden = !hidden;
        delay += durations[index].doubleValue;
    }
    
    NSMutableArray *tagZeroArray = [NSMutableArray array];
    for (UIView *view in animationView.subviews) {
        if (view.tag == 0) {
            [tagZeroArray addObject:view];
        }
    }
    
    UIView *firstItemView = tagZeroArray.firstObject;
    
    firstItemView.layer.masksToBounds = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(durations[0].doubleValue * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        firstItemView.layer.cornerRadius = 0;
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.animationView.alpha = 0;
        self.containerView.alpha = 1;
        
        if (completion) completion();
    });
}

- (void)closeAnimationWithCompletion:(void(^)())completion
{
    [self removeImageItemsFromAnimationView];
    [self addImageItemsToAnimationView];
    
    NSMutableArray *animationItemViews = self.animationItemViews;
    NSAssert(animationItemViews != nil, @"animationItemViews is nil");
    
    self.animationView.alpha = 1;
    self.containerView.alpha = 0;
    
    NSArray<NSNumber *> *durations = [[[self durationSequenceWithType:AnimationTypeClose] reverseObjectEnumerator] allObjects];
    
    NSTimeInterval delay = 0;
    NSString *timing = kCAMediaTimingFunctionEaseIn;
    CGFloat from = 0.f;
    CGFloat to = M_PI / 2;
    BOOL hidden = YES;
    
    [self configureAnimationItemsWithAnimationType:AnimationTypeClose];
    
    NSAssert(durations.count >= animationItemViews.count, @"wrong override func animationDuration(itemIndex:NSInteger, type:AnimationType)-> NSTimeInterval");
    
    for (int index = 0; index < animationItemViews.count; index ++) {
        CCRotatedView *animatedView = [[animationItemViews reverseObjectEnumerator] allObjects][index];
        
        [animatedView foldingAnimationWithTimingFunctionString:timing from:from to:to duration:durations[index].doubleValue delay:delay hidden:hidden];
        
        to = to == 0.f ? M_PI / 2 : 0.f;
        from = from == 0.f ? -M_PI / 2 : 0.f;
        timing = timing == kCAMediaTimingFunctionEaseIn ? kCAMediaTimingFunctionEaseOut : kCAMediaTimingFunctionEaseIn;
        hidden = !hidden;
        delay += durations[index].doubleValue;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.animationView.alpha = 0;
        if (completion) completion();
    });
    
    NSMutableArray *tagZeroArray = [NSMutableArray array];
    for (UIView *view in self.animationView.subviews) {
        if (view.tag == 0) {
            [tagZeroArray addObject:view];
        }
    }
    
    UIView *firstItemView = tagZeroArray.firstObject;
    
    firstItemView.layer.cornerRadius = 0;
    firstItemView.layer.masksToBounds = YES;
    
    NSNumber *durationNumberFirst = durations.firstObject;
    if (durationNumberFirst) {
        NSTimeInterval durationFirst = durationNumberFirst.doubleValue;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((delay - durationFirst * 2) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            firstItemView.layer.cornerRadius = self.foregroundView.layer.cornerRadius;
            [firstItemView setNeedsDisplay];
            [firstItemView setNeedsLayout];
        });
    }
}

@end
