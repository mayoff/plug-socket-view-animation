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
    @property (strong, nonatomic) IBOutlet UIView *socketView;
    @property (strong, nonatomic) IBOutlet UIView *plugView;
    @property (strong, nonatomic) IBOutlet UIImageView *placeholderView;

    @end

    @implementation ViewController

    - (void)viewDidLoad {
        [super viewDidLoad];
        
        self.plugView.translatesAutoresizingMaskIntoConstraints = YES;
        self.plugView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.plugView.layer.anchorPoint = CGPointZero;

        self.placeholderView.translatesAutoresizingMaskIntoConstraints = YES;
        self.placeholderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.placeholderView.layer.anchorPoint = CGPointZero;
    }

    - (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
        NSLog(@"duration = %.6f", duration);
    }

    - (IBAction)bigButtonWasTapped:(id)sender {
        [UIView animateWithDuration:10 animations:^{
            self.socketWidthConstraint.constant = 320;
            [self.view layoutIfNeeded];
        }];
    }

    - (IBAction)smallButtonWasTapped:(id)sender {
        [UIView animateWithDuration:5 animations:^{
            self.socketWidthConstraint.constant = 160;
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

    - (IBAction)delayWasTapped:(id)sender {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self plugWasTapped:nil];
        });
    }

    - (IBAction)plugWasTapped:(id)sender {
        if (self.plugView.superview || self.placeholderView.superview) {
            [self.plugView removeFromSuperview];
            [self.placeholderView removeFromSuperview];
            return;
        }

        if (![self socketViewHasSizeAnimation]) {
            self.plugView.frame = self.socketView.bounds;
            [self.socketView addSubview:self.plugView];
            return;
        }

        CGSize endSize = self.socketView.bounds.size;
        self.placeholderView.frame = self.socketView.bounds;
        self.placeholderView.image = [self imageOfView:self.plugView atSize:endSize];
        [self.socketView addSubview:self.placeholderView];

        [CATransaction begin]; {
            [CATransaction setCompletionBlock:^{
                [self replacePlaceholderViewWithPlugView];
            }];
            [self copySizeAnimationsFromSocketToPlaceholder];
        } [CATransaction commit];
    }

    - (BOOL)socketViewHasSizeAnimation {
        for (NSString *key in self.socketView.layer.animationKeys) {
            CAAnimation *rawAnimation = [self.socketView.layer animationForKey:key];
            if ([rawAnimation isKindOfClass:[CAPropertyAnimation class]]) {
                CAPropertyAnimation *animation = (CAPropertyAnimation *)rawAnimation;
                if ([animation.keyPath isEqualToString:@"bounds.size"]) {
                    return YES;
                }
            }
        }
        return NO;
    }

    - (void)copySizeAnimationsFromSocketToPlaceholder {
        for (NSString *key in self.socketView.layer.animationKeys) {
            CAAnimation *rawAnimation = [self.socketView.layer animationForKey:key];
            if ([rawAnimation isKindOfClass:[CAPropertyAnimation class]]) {
                CAPropertyAnimation *animation = (CAPropertyAnimation *)rawAnimation;
                if ([animation.keyPath isEqualToString:@"bounds.size"]) {
                    [self.placeholderView.layer addAnimation:animation forKey:key];
                }
            }
        }
    }

    - (void)replacePlaceholderViewWithPlugView {
        if (self.placeholderView.superview && [self.placeholderView.layer animationForKey:@"contents"] == nil) {
            [self.placeholderView removeFromSuperview];
            self.plugView.frame = self.socketView.bounds;
            [self.socketView addSubview:self.plugView];
        }
    }

    - (UIImage *)imageOfView:(UIView *)view atSize:(CGSize)size {
        CGRect bounds = view.bounds;
        bounds.size = size;
        view.bounds = bounds;
        [view layoutIfNeeded];
        UIGraphicsBeginImageContextWithOptions(size, NO, 0); {
            [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
        }
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }

    @end
