//
//  ViewController.m
//  plugAnimation
//
//  Created by Rob Mayoff on 10/31/15.
//  Copyright © 2015 Rob Mayoff. All rights reserved.
//

#import "ViewController.h"

@interface UIView (recursiveDescription)
- (NSString *)recursiveDescription;
@end

@interface ViewController ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *socketWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *socketHeightConstraint;
@property (strong, nonatomic) IBOutlet UIView *socketView;
@property (strong, nonatomic) IBOutlet UIImageView *plugView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.plugView.translatesAutoresizingMaskIntoConstraints = YES;
    self.plugView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
//    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)displayLinkDidFire:(CADisplayLink *)link {
    if (self.socketView.layer.presentationLayer) {
        NSLog(@"%@", self.socketView.layer.presentationLayer);
    }
}

- (IBAction)bigButtonWasTapped:(id)sender {
    [UIView animateWithDuration:10 animations:^{
        self.socketWidthConstraint.constant = 320;
        self.socketHeightConstraint.constant = 320;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)smallButtonWasTapped:(id)sender {
    [UIView animateWithDuration:10 animations:^{
        self.socketWidthConstraint.constant = 160;
        self.socketHeightConstraint.constant = 160;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)checkWasTapped:(id)sender {
//    NSLog(@"%@", self.view.recursiveDescription);
    CFTimeInterval now = CACurrentMediaTime();
    NSLog(@"time %.6f %.6f %.6f", now, [self.view.layer convertTime:now fromLayer:nil], [self.socketView.layer convertTime:now fromLayer:nil]);
    for (NSString *key in self.socketView.layer.animationKeys) {
        CABasicAnimation *animation = (CABasicAnimation *)[self.socketView.layer animationForKey:key];
        NSLog(@"%@ %.6f %.6f", animation.keyPath, animation.beginTime, animation.timeOffset);
        animation.beginTime -= 2;
    }
}

- (IBAction)plugWasTapped:(id)sender {
    if (self.plugView.superview) {
        [self.plugView removeFromSuperview];
        return;
    }
    
    self.plugView.frame = self.socketView.bounds;
    [self.socketView addSubview:self.plugView];
    
    CABasicAnimation *animation = (CABasicAnimation *)[self.socketView.layer animationForKey:@"bounds.size"];
    [self.plugView.layer addAnimation:animation forKey:animation.keyPath];
    CGSize originalSize = [animation.fromValue CGSizeValue];
    CGSize newSize = [animation.toValue CGSizeValue];
    
    animation = [(CABasicAnimation *)[self.socketView.layer animationForKey:@"position"] copy];
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(originalSize.width / 2, originalSize.height / 2)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(newSize.width / 2, newSize.height / 2)];
    [self.plugView.layer addAnimation:animation forKey:animation.keyPath];
}

@end
