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

    static CGSize sizePriorToAdditiveBasicAnimation(CGSize size, CABasicAnimation *animation) {
        CGSize adjustment = [animation.fromValue CGSizeValue];
        size.width += adjustment.width;
        size.height += adjustment.height;
        return size;
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

        CABasicAnimation *animation;
        NSString *key;
        [self getSocketSizeMostRecentAdditiveBasicAnimation:&animation key:&key];
        if (animation == nil) {
            self.plugView.frame = self.socketView.bounds;
            [self.socketView addSubview:self.plugView];
            return;
        }

        CGSize endSize = self.socketView.bounds.size;
        CGSize beginSize = sizePriorToAdditiveBasicAnimation(endSize, animation);

        UIImage *beginImage = [self imageOfView:self.plugView atSize:beginSize];
        UIImage *endImage = [self imageOfView:self.plugView atSize:endSize];

        self.placeholderView.frame = self.socketView.bounds;
        self.placeholderView.image = endImage;
        [self.socketView addSubview:self.placeholderView];

        CABasicAnimation *contentsAnimation = [animation copy];
        contentsAnimation.keyPath = @"contents";
        contentsAnimation.additive = NO;
        contentsAnimation.fromValue = (__bridge id _Nullable)(beginImage.CGImage);
        contentsAnimation.toValue = (__bridge id _Nullable)(endImage.CGImage);

        [CATransaction begin]; {
            [CATransaction setCompletionBlock:^{
                [self replacePlaceholderViewWithPlugView];
            }];

            [self.placeholderView.layer addAnimation:animation forKey:key];
            [self.placeholderView.layer addAnimation:contentsAnimation forKey:@"contents"];
        } [CATransaction commit];
    }

    - (void)replacePlaceholderViewWithPlugView {
        if (self.placeholderView.superview && [self.placeholderView.layer animationForKey:@"contents"] == nil) {
            [self.placeholderView removeFromSuperview];
            self.plugView.frame = self.socketView.bounds;
            [self.socketView addSubview:self.plugView];
        }
    }

    - (void)getSocketSizeMostRecentAdditiveBasicAnimation:(CABasicAnimation **)animationOut key:(NSString **)keyOut {
        CABasicAnimation *mostRecentAnimation = nil;
        NSString *mostRecentAnimationKey = nil;
        CFTimeInterval mostRecentBeginTime = -HUGE_VAL;
        for (NSString *key in self.socketView.layer.animationKeys) {
            CABasicAnimation *animation = (CABasicAnimation *)[self.socketView.layer animationForKey:key];
            if ([animation isKindOfClass:[CABasicAnimation class]] && [animation.keyPath isEqualToString:@"bounds.size"] && animation.additive && animation.beginTime > mostRecentBeginTime) {
                mostRecentBeginTime = animation.beginTime;
                mostRecentAnimation = animation;
            }
        }
        *animationOut = mostRecentAnimation;
        *keyOut = mostRecentAnimationKey;
    }

    - (void)insertPlaceholderView {

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
