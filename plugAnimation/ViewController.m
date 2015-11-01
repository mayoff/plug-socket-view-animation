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
        self.plugView.layer.anchorPoint = CGPointZero;
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
        [UIView animateWithDuration:5 animations:^{
            self.socketWidthConstraint.constant = 160;
            self.socketHeightConstraint.constant = 160;
            [self.view layoutIfNeeded];
        }];
    }

    static NSString *animationDescription(CABasicAnimation *animation) {
        return [NSString stringWithFormat:@"%p from=%@ to=%@ by=%@ keyPath=%@ additive=%d cumulative=%d valueFunction=%@ timingFunction=%@ delegate=%@ removedOnCompletion=%d beginTime=%.6f duration=%.2f speed=%.2f timeOffset=%.2f repeatCount=%.2f repeatDuration=%.2f autoreverses=%d fillMode=%@", animation, animation.fromValue, animation.toValue, animation.byValue, animation.keyPath, animation.additive, animation.cumulative, animation.valueFunction, animation.timingFunction, animation.delegate, animation.removedOnCompletion, animation.beginTime, animation.duration, animation.speed, animation.timeOffset, animation.repeatCount, animation.repeatDuration, animation.autoreverses, animation.fillMode];
    }

    - (IBAction)checkWasTapped:(id)sender {
        //    NSLog(@"%@", self.view.recursiveDescription);
        CFTimeInterval now = CACurrentMediaTime();
        printf("\n\ntime %.6f %.6f %.6f\n", now, [self.view.layer convertTime:now fromLayer:nil], [self.socketView.layer convertTime:now fromLayer:nil]);
        for (NSString *key in self.socketView.layer.animationKeys) {
            CABasicAnimation *animation = (CABasicAnimation *)[self.socketView.layer animationForKey:key];
            printf("%s %s\n", key.UTF8String, animationDescription(animation).UTF8String);
        }
    }

    - (IBAction)plugWasTapped:(id)sender {
        if (self.plugView.superview) {
            [self.plugView removeFromSuperview];
            return;
        }
        
        self.plugView.frame = self.socketView.bounds;
        [self.socketView addSubview:self.plugView];
        
        for (NSString *key in self.socketView.layer.animationKeys) {
            CAAnimation *rawAnimation = [self.socketView.layer animationForKey:key];
            if (![rawAnimation isKindOfClass:[CABasicAnimation class]]) {
                continue;
            }
            
            CABasicAnimation *animation = (CABasicAnimation *)rawAnimation;
            if ([animation.keyPath isEqualToString:@"bounds.size"]) {
                [self.plugView.layer addAnimation:animation forKey:key];
            }
        }
    }

    @end
