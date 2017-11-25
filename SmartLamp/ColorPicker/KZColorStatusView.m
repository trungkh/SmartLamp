//
//  KZColorCompareView.m
//
//  Created by Alex Restrepo on 5/11/11.
//  Copyright 2011 KZLabs http://kzlabs.me
//  All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KZColorStatusView.h"

@implementation KZColorStatusView

#pragma mark - Properties
//@synthesize oldColor = _oldColor;
@synthesize currentColor = _currentColor;
@synthesize checkerBoardColor = _checkerBoardColor;

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (!self) 
        return nil;
    
    self.opaque = YES;
    self.backgroundColor = [UIColor clearColor];
    //self.oldColor = [[UIColor blueColor] colorWithAlphaComponent:0.6];
    self.currentColor = [[UIColor grayColor] colorWithAlphaComponent:0.8];
    
    return self;
}

#pragma mark - Custom Properties
/*- (void) setOldColor:(UIColor *)color
{
    _oldColor = color;
    [self setNeedsDisplay];
}*/

- (void) setCurrentColor:(UIColor *)color
{
    _currentColor = color;
    [self setNeedsDisplay];
}

- (UIColor *)checkerBoardColor
{
    if(!_checkerBoardColor)
    {
        self.checkerBoardColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CheckerBoard.png"]];
    }
    return _checkerBoardColor;
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{   
    const CGFloat cornerRadius = 6.0f;
    const CGFloat borderWidth = 2.0f;
    CGContextRef context = UIGraphicsGetCurrentContext();                    
    
    // does color have alpha???
    if(CGColorGetAlpha(self.currentColor.CGColor) /*|| CGColorGetAlpha(self.oldColor.CGColor) < 1.0*/)
    {
        CGPathRef checkerPath = [[self class] newRoundRectPathForBoundingRect:CGRectInset(self.bounds, borderWidth, borderWidth) cornerRadius:cornerRadius - 1.0f];
        CGContextAddPath(context, checkerPath);    
        [self.checkerBoardColor setFill];    
        CGContextFillPath(context);
        CGPathRelease(checkerPath);
    }
    
    /*CGPathRef leftFillPath = [[self class] newLeftRoundRectPathForBoundingRect:CGRectMake(0, 0, self.bounds.size.width * 0.5 + 1.0f, self.bounds.size.height) cornerRadius:cornerRadius + 1.0f];
    CGContextAddPath(context, leftFillPath);
    [self.oldColor setFill];
    CGContextFillPath(context);
    CGPathRelease(leftFillPath);*/
    
    CGPathRef rightFillPath = [[self class] newFillRectPathForBoundingRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) cornerRadius:cornerRadius + 1.0f];
    CGContextAddPath(context, rightFillPath);
    [self.currentColor setFill];    
    CGContextFillPath(context);
    CGPathRelease(rightFillPath);
    
    CGContextSetLineWidth(context, borderWidth);
    CGPathRef borderPath = [[self class] newRoundRectPathForBoundingRect:CGRectInset(self.bounds, borderWidth * 0.5, borderWidth * 0.5) cornerRadius:cornerRadius];
    [[UIColor whiteColor] setStroke];
    CGContextAddPath(context, borderPath);
    CGContextStrokePath(context);
    CGPathRelease(borderPath);
}

+ (CGPathRef)newFillRectPathForBoundingRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius
{
    const NSUInteger inset = 1.0f;
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat minx = CGRectGetMinX(rect) ,
    midx = CGRectGetMidX(rect),
    maxx = CGRectGetMaxX(rect) ;
    
    CGFloat miny = CGRectGetMinY(rect) ,
    midy = CGRectGetMidY(rect) ,
    maxy = CGRectGetMaxY(rect) ;
    
    minx = minx + inset;
    miny = miny + inset;
    
    maxx = maxx - inset;
    maxy = maxy - inset;
    
    CGPathMoveToPoint(path, NULL, minx, midy);
    CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, cornerRadius);
    CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, midy, cornerRadius);
    CGPathAddArcToPoint(path, NULL, maxx, maxy, midx, maxy, cornerRadius);
    CGPathAddArcToPoint(path, NULL, minx, maxy, minx, midy, cornerRadius);
    CGPathAddLineToPoint(path, NULL, minx, maxy);
    return path;
}

+ (CGPathRef)newRoundRectPathForBoundingRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius
{
    const NSUInteger inset = 1.0f;
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat minx = CGRectGetMinX(rect) ,
    midx = CGRectGetMidX(rect),
    maxx = CGRectGetMaxX(rect) ;
    
    CGFloat miny = CGRectGetMinY(rect) ,
    midy = CGRectGetMidY(rect) ,
    maxy = CGRectGetMaxY(rect) ;
    
    minx = minx + inset;
    miny = miny + inset;
    
    maxx = maxx - inset;
    maxy = maxy - inset;
    
    CGPathMoveToPoint(path, NULL, minx, midy);
    CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, cornerRadius);
    CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, midy, cornerRadius);
    CGPathAddArcToPoint(path, NULL, maxx, maxy, midx, maxy, cornerRadius);
    CGPathAddArcToPoint(path, NULL, minx, maxy, minx, midy, cornerRadius);
    CGPathCloseSubpath(path);
    return path;
}
@end
