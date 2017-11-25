//
//  KZColorCompareView.h
//
//  Created by Alex Restrepo on 5/11/11.
//  Copyright 2011 KZLabs http://kzlabs.me
//  All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KZColorStatusView : UIControl

//@property (nonatomic, retain) UIColor *oldColor;
@property (nonatomic, retain) UIColor *currentColor;
@property (nonatomic, retain) UIColor *checkerBoardColor;

+ (CGPathRef)newFillRectPathForBoundingRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;
+ (CGPathRef)newRoundRectPathForBoundingRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;

@end
