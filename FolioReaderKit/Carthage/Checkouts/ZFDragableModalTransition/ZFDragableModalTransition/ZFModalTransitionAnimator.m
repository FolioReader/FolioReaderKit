//
//  ZFModalTransitionAnimator.m
//
//  Created by Amornchai Kanokpullwad on 5/10/14.
//  Copyright (c) 2014 zoonref. All rights reserved.
//

#import "ZFModalTransitionAnimator.h"

@interface ZFModalTransitionAnimator ()
@property (nonatomic, weak) UIViewController *modalController;
@property (nonatomic, strong) ZFDetectScrollViewEndGestureRecognizer *gesture;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@property CGFloat panLocationStart;
@property BOOL isDismiss;
@property BOOL isInteractive;
@property CATransform3D tempTransform;
@end

@implementation ZFModalTransitionAnimator

- (instancetype)initWithModalViewController:(UIViewController *)modalViewController
{
    self = [super init];
    if (self) {
        _modalController = modalViewController;
        _direction = ZFModalTransitonDirectionBottom;
        _dragable = NO;
        _bounces = YES;
        _behindViewScale = 0.9f;
        _behindViewAlpha = 1.0f;
        _transitionDuration = 0.8f;

        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)setDragable:(BOOL)dragable
{
    _dragable = dragable;
    if (_dragable) {
        [self removeGestureRecognizerFromModalController];
        self.gesture = [[ZFDetectScrollViewEndGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.gesture.delegate = self;
        [self.modalController.view addGestureRecognizer:self.gesture];
    } else {
        [self removeGestureRecognizerFromModalController];
    }
}

- (void)setContentScrollView:(UIScrollView *)scrollView
{
    // always enable drag if scrollview is set
    if (!self.dragable) {
        self.dragable = YES;
    }
    // and scrollview will work only for bottom mode
    self.direction = ZFModalTransitonDirectionBottom;
    self.gesture.scrollview = scrollView;
}

- (void)setDirection:(ZFModalTransitonDirection)direction
{
    _direction = direction;
    // scrollview will work only for bottom mode
    if (_direction != ZFModalTransitonDirectionBottom) {
        self.gesture.scrollview = nil;
    }
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    // Reset to our default state
    self.isInteractive = NO;
    self.transitionContext = nil;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (self.isInteractive) {
        return;
    }
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *containerView = [transitionContext containerView];

    if (!self.isDismiss) {

        CGRect startRect;

        [containerView addSubview:toViewController.view];

        toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        if (self.direction == ZFModalTransitonDirectionBottom) {
            startRect = CGRectMake(0,
                                   CGRectGetHeight(containerView.frame),
                                   CGRectGetWidth(containerView.bounds),
                                   CGRectGetHeight(containerView.bounds));
        } else if (self.direction == ZFModalTransitonDirectionLeft) {
            startRect = CGRectMake(-CGRectGetWidth(containerView.frame),
                                   0,
                                   CGRectGetWidth(containerView.bounds),
                                   CGRectGetHeight(containerView.bounds));
        } else if (self.direction == ZFModalTransitonDirectionRight) {
            startRect = CGRectMake(CGRectGetWidth(containerView.frame),
                                   0,
                                   CGRectGetWidth(containerView.bounds),
                                   CGRectGetHeight(containerView.bounds));
        }

        CGPoint transformedPoint = CGPointApplyAffineTransform(startRect.origin, toViewController.view.transform);
        toViewController.view.frame = CGRectMake(transformedPoint.x, transformedPoint.y, startRect.size.width, startRect.size.height);

        if (toViewController.modalPresentationStyle == UIModalPresentationCustom) {
            [fromViewController beginAppearanceTransition:NO animated:YES];
        }

        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0.1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             fromViewController.view.transform = CGAffineTransformScale(fromViewController.view.transform, self.behindViewScale, self.behindViewScale);
                             fromViewController.view.alpha = self.behindViewAlpha;

                             toViewController.view.frame = CGRectMake(0,0,
                                                                      CGRectGetWidth(toViewController.view.frame),
                                                                      CGRectGetHeight(toViewController.view.frame));
                         } completion:^(BOOL finished) {
                             if (toViewController.modalPresentationStyle == UIModalPresentationCustom) {
                                 [fromViewController endAppearanceTransition];
                             }
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    } else {

        if (fromViewController.modalPresentationStyle == UIModalPresentationFullScreen) {
            [containerView addSubview:toViewController.view];
        }
        
        [containerView bringSubviewToFront:fromViewController.view];

        if (![self isPriorToIOS8]) {
            toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, self.behindViewScale, self.behindViewScale, 1);
        }

        toViewController.view.alpha = self.behindViewAlpha;

        CGRect endRect;

        if (self.direction == ZFModalTransitonDirectionBottom) {
            endRect = CGRectMake(0,
                                 CGRectGetHeight(fromViewController.view.bounds),
                                 CGRectGetWidth(fromViewController.view.frame),
                                 CGRectGetHeight(fromViewController.view.frame));
        } else if (self.direction == ZFModalTransitonDirectionLeft) {
            endRect = CGRectMake(-CGRectGetWidth(fromViewController.view.bounds),
                                 0,
                                 CGRectGetWidth(fromViewController.view.frame),
                                 CGRectGetHeight(fromViewController.view.frame));
        } else if (self.direction == ZFModalTransitonDirectionRight) {
            endRect = CGRectMake(CGRectGetWidth(fromViewController.view.bounds),
                                 0,
                                 CGRectGetWidth(fromViewController.view.frame),
                                 CGRectGetHeight(fromViewController.view.frame));
        }

        CGPoint transformedPoint = CGPointApplyAffineTransform(endRect.origin, fromViewController.view.transform);
        endRect = CGRectMake(transformedPoint.x, transformedPoint.y, endRect.size.width, endRect.size.height);

        if (fromViewController.modalPresentationStyle == UIModalPresentationCustom) {
            [toViewController beginAppearanceTransition:YES animated:YES];
        }

        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0.1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             CGFloat scaleBack = (1 / self.behindViewScale);
                             toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, scaleBack, scaleBack, 1);
                             toViewController.view.alpha = 1.0f;
                             fromViewController.view.frame = endRect;
                         } completion:^(BOOL finished) {
                             toViewController.view.layer.transform = CATransform3DIdentity;
                             if (fromViewController.modalPresentationStyle == UIModalPresentationCustom) {
                                 [toViewController endAppearanceTransition];
                             }
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    }
}

- (void)removeGestureRecognizerFromModalController
{
    if (self.gesture && [self.modalController.view.gestureRecognizers containsObject:self.gesture]) {
        [self.modalController.view removeGestureRecognizer:self.gesture];
        self.gesture = nil;
    }
}

# pragma mark - Gesture

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    // Location reference
    CGPoint location = [recognizer locationInView:self.modalController.view.window];
    location = CGPointApplyAffineTransform(location, CGAffineTransformInvert(recognizer.view.transform));
    // Velocity reference
    CGPoint velocity = [recognizer velocityInView:[self.modalController.view window]];
    velocity = CGPointApplyAffineTransform(velocity, CGAffineTransformInvert(recognizer.view.transform));

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.isInteractive = YES;
        if (self.direction == ZFModalTransitonDirectionBottom) {
            self.panLocationStart = location.y;
        } else {
            self.panLocationStart = location.x;
        }
        [self.modalController dismissViewControllerAnimated:YES completion:nil];
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat animationRatio = 0;

        if (self.direction == ZFModalTransitonDirectionBottom) {
            animationRatio = (location.y - self.panLocationStart) / (CGRectGetHeight([self.modalController view].bounds));
        } else if (self.direction == ZFModalTransitonDirectionLeft) {
            animationRatio = (self.panLocationStart - location.x) / (CGRectGetWidth([self.modalController view].bounds));
        } else if (self.direction == ZFModalTransitonDirectionRight) {
            animationRatio = (location.x - self.panLocationStart) / (CGRectGetWidth([self.modalController view].bounds));
        }

        [self updateInteractiveTransition:animationRatio];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {

        CGFloat velocityForSelectedDirection;

        if (self.direction == ZFModalTransitonDirectionBottom) {
            velocityForSelectedDirection = velocity.y;
        } else {
            velocityForSelectedDirection = velocity.x;
        }

        if (velocityForSelectedDirection > 100
            && (self.direction == ZFModalTransitonDirectionRight
                || self.direction == ZFModalTransitonDirectionBottom)) {
                [self finishInteractiveTransition];
            } else if (velocityForSelectedDirection < -100 && self.direction == ZFModalTransitonDirectionLeft) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
        self.isInteractive = NO;
    }
}

#pragma mark -

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    if (![self isPriorToIOS8]) {
        toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, self.behindViewScale, self.behindViewScale, 1);
    }

    self.tempTransform = toViewController.view.layer.transform;

    toViewController.view.alpha = self.behindViewAlpha;
    
    if (fromViewController.modalPresentationStyle == UIModalPresentationFullScreen) {
        [[transitionContext containerView] addSubview:toViewController.view];
    }
    [[transitionContext containerView] bringSubviewToFront:fromViewController.view];
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
    if (!self.bounces && percentComplete < 0) {
        percentComplete = 0;
    }

    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CATransform3D transform = CATransform3DMakeScale(
                                                     1 + (((1 / self.behindViewScale) - 1) * percentComplete),
                                                     1 + (((1 / self.behindViewScale) - 1) * percentComplete), 1);
    toViewController.view.layer.transform = CATransform3DConcat(self.tempTransform, transform);

    toViewController.view.alpha = self.behindViewAlpha + ((1 - self.behindViewAlpha) * percentComplete);

    CGRect updateRect;
    if (self.direction == ZFModalTransitonDirectionBottom) {
        updateRect = CGRectMake(0,
                                (CGRectGetHeight(fromViewController.view.bounds) * percentComplete),
                                CGRectGetWidth(fromViewController.view.frame),
                                CGRectGetHeight(fromViewController.view.frame));
    } else if (self.direction == ZFModalTransitonDirectionLeft) {
        updateRect = CGRectMake(-(CGRectGetWidth(fromViewController.view.bounds) * percentComplete),
                                0,
                                CGRectGetWidth(fromViewController.view.frame),
                                CGRectGetHeight(fromViewController.view.frame));
    } else if (self.direction == ZFModalTransitonDirectionRight) {
        updateRect = CGRectMake(CGRectGetWidth(fromViewController.view.bounds) * percentComplete,
                                0,
                                CGRectGetWidth(fromViewController.view.frame),
                                CGRectGetHeight(fromViewController.view.frame));
    }

    // reset to zero if x and y has unexpected value to prevent crash
    if (isnan(updateRect.origin.x) || isinf(updateRect.origin.x)) {
        updateRect.origin.x = 0;
    }
    if (isnan(updateRect.origin.y) || isinf(updateRect.origin.y)) {
        updateRect.origin.y = 0;
    }

    CGPoint transformedPoint = CGPointApplyAffineTransform(updateRect.origin, fromViewController.view.transform);
    updateRect = CGRectMake(transformedPoint.x, transformedPoint.y, updateRect.size.width, updateRect.size.height);

    fromViewController.view.frame = updateRect;
}

- (void)finishInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    CGRect endRect;

    if (self.direction == ZFModalTransitonDirectionBottom) {
        endRect = CGRectMake(0,
                             CGRectGetHeight(fromViewController.view.bounds),
                             CGRectGetWidth(fromViewController.view.frame),
                             CGRectGetHeight(fromViewController.view.frame));
    } else if (self.direction == ZFModalTransitonDirectionLeft) {
        endRect = CGRectMake(-CGRectGetWidth(fromViewController.view.bounds),
                             0,
                             CGRectGetWidth(fromViewController.view.frame),
                             CGRectGetHeight(fromViewController.view.frame));
    } else if (self.direction == ZFModalTransitonDirectionRight) {
        endRect = CGRectMake(CGRectGetWidth(fromViewController.view.bounds),
                             0,
                             CGRectGetWidth(fromViewController.view.frame),
                             CGRectGetHeight(fromViewController.view.frame));
    }

    CGPoint transformedPoint = CGPointApplyAffineTransform(endRect.origin, fromViewController.view.transform);
    endRect = CGRectMake(transformedPoint.x, transformedPoint.y, endRect.size.width, endRect.size.height);

    if (fromViewController.modalPresentationStyle == UIModalPresentationCustom) {
        [toViewController beginAppearanceTransition:YES animated:YES];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGFloat scaleBack = (1 / self.behindViewScale);
                         toViewController.view.layer.transform = CATransform3DScale(self.tempTransform, scaleBack, scaleBack, 1);
                         toViewController.view.alpha = 1.0f;
                         fromViewController.view.frame = endRect;
                     } completion:^(BOOL finished) {
                         if (fromViewController.modalPresentationStyle == UIModalPresentationCustom) {
                             [toViewController endAppearanceTransition];
                         }
                         [transitionContext completeTransition:YES];
                     }];
}

- (void)cancelInteractiveTransition
{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    [transitionContext cancelInteractiveTransition];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         toViewController.view.layer.transform = self.tempTransform;
                         toViewController.view.alpha = self.behindViewAlpha;

                         fromViewController.view.frame = CGRectMake(0,0,
                                                                    CGRectGetWidth(fromViewController.view.frame),
                                                                    CGRectGetHeight(fromViewController.view.frame));
                     } completion:^(BOOL finished) {
                         [transitionContext completeTransition:NO];
                         if (fromViewController.modalPresentationStyle == UIModalPresentationFullScreen) {
                             [toViewController.view removeFromSuperview];
                         }
                     }];
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.isDismiss = NO;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.isDismiss = YES;
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    // Return nil if we are not interactive
    if (self.isInteractive && self.dragable) {
        self.isDismiss = YES;
        return self;
    }

    return nil;
}

#pragma mark - Gesture Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (self.direction == ZFModalTransitonDirectionBottom) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (self.direction == ZFModalTransitonDirectionBottom) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.gestureRecognizerToFailPan && otherGestureRecognizer && self.gestureRecognizerToFailPan == otherGestureRecognizer) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Utils

- (BOOL)isPriorToIOS8
{
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"8.0" options: NSNumericSearch];
    if (order == NSOrderedSame || order == NSOrderedDescending) {
        // OS version >= 8.0
        return YES;
    }
    return NO;
}

#pragma mark - Orientation

- (void)orientationChanged:(NSNotification *)notification
{
    UIViewController *backViewController = self.modalController.presentingViewController;
    backViewController.view.transform = CGAffineTransformIdentity;
    backViewController.view.frame = self.modalController.view.bounds;
    backViewController.view.transform = CGAffineTransformScale(backViewController.view.transform, self.behindViewScale, self.behindViewScale);
}

@end

// Gesture Class Implement
@interface ZFDetectScrollViewEndGestureRecognizer ()
@property (nonatomic, strong) NSNumber *isFail;
@end

@implementation ZFDetectScrollViewEndGestureRecognizer

- (void)reset
{
    [super reset];
    self.isFail = nil;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];

    if (!self.scrollview) {
        return;
    }

    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint velocity = [self velocityInView:self.view];
    CGPoint nowPoint = [touches.anyObject locationInView:self.view];
    CGPoint prevPoint = [touches.anyObject previousLocationInView:self.view];

    if (self.isFail) {
        if (self.isFail.boolValue) {
            self.state = UIGestureRecognizerStateFailed;
        }
        return;
    }

    CGFloat topVerticalOffset = -self.scrollview.contentInset.top;

    if ((fabs(velocity.x) < fabs(velocity.y)) && (nowPoint.y > prevPoint.y) && (self.scrollview.contentOffset.y <= topVerticalOffset)) {
        self.isFail = @NO;
    } else if (self.scrollview.contentOffset.y >= topVerticalOffset) {
        self.state = UIGestureRecognizerStateFailed;
        self.isFail = @YES;
    } else {
        self.isFail = @NO;
    }
}

@end
