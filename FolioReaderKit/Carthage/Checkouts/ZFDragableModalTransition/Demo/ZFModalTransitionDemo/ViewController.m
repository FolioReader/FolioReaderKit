//
//  ViewController.m
//  ZFModalTransitionDemo
//
//  Created by Amornchai Kanokpullwad on 6/4/14.
//  Copyright (c) 2014 zoonref. All rights reserved.
//

#import "ViewController.h"
#import "ModalViewController.h"
#import "ZFModalTransitionAnimator.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *dragableSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *scrollViewSwitch;
@property (nonatomic, strong) ZFModalTransitionAnimator *animator;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(UIButton *)sender
{
    ModalViewController *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ModalViewController"];
    modalVC.isShowingScrollView = self.scrollViewSwitch.isOn;
    modalVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:modalVC];
    self.animator.dragable = self.dragableSwitch.isOn;
    self.animator.bounces = NO;
    self.animator.behindViewAlpha = 0.5f;
    self.animator.behindViewScale = 0.5f;
    self.animator.transitionDuration = 0.7f;
    
    if (self.scrollViewSwitch.isOn) {
        [self.animator setContentScrollView:modalVC.scrollView];
    }
    
    NSString *title = [sender titleForState:UIControlStateNormal];
    if ([title isEqualToString:@"Left"]) {
        self.animator.direction = ZFModalTransitonDirectionLeft;
    } else if ([title isEqualToString:@"Right"]) {
        self.animator.direction = ZFModalTransitonDirectionRight;
    } else {
        self.animator.direction = ZFModalTransitonDirectionBottom;
    }
    
    modalVC.transitioningDelegate = self.animator;
    [self presentViewController:modalVC animated:YES completion:nil];
}

@end
