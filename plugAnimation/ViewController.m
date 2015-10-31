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

@end

@implementation ViewController

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
    NSLog(@"current time = %.6f", CACurrentMediaTime());
    for (NSString *key in self.socketView.layer.animationKeys) {
        CABasicAnimation *animation = (CABasicAnimation *)[self.socketView.layer animationForKey:key];
        NSLog(@"%@ %.6f %.6f", animation.keyPath, animation.beginTime, animation.timeOffset);
    }
}

@end
