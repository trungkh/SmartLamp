//
//  RSColorPickerView.h
//  RSColorPicker
//
//  Created by Ryan Sullivan on 8/12/11.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

@class RSColorPickerView;

IB_DESIGNABLE

@interface RSColorPickerView : UIControl
//@interface RSColorPickerView : UIView

/**
 * The brightness of the current selection
 */
@property (nonatomic) CGFloat brightness;

/**
 * The opacity of the current selection.
 */
@property (nonatomic) CGFloat opacity;

/**
 * The selection color.
 * This setter may modify `brightness` and `opacity` as necessary.
 */
@property (nonatomic) UIColor * selectionColor;

/**
 * The current point (in the color picker's bounds) of the selected color.
 */
@property (readwrite) CGPoint selection;

/**
 * The distance around the edges of the color picker that is drawn for padding.
 * Colors are cut-off before this distance so that the user can pick all colors.
 */
@property (readonly) CGFloat paddingDistance;

/**
 * Trung add
 */
@property (nonatomic, retain) UIImageView *wheelKnobView;

/**
 * The color at a given point in the color picker's bounds.
 */
- (UIColor *)colorAtPoint:(CGPoint)point;

// Called to handle a location selector change.
- (void)updateSelectionLocation;

/**
 * Methods that create/cache data needed to create a color picker.
 * These run async (except where noted) and can help the overall UX.
 */

+ (void)prepareForDiameter:(CGFloat)diameter;
+ (void)prepareForDiameter:(CGFloat)diameter padding:(CGFloat)padding;
+ (void)prepareForDiameter:(CGFloat)diameter scale:(CGFloat)scale;
+ (void)prepareForDiameter:(CGFloat)diameter scale:(CGFloat)scale padding:(CGFloat)padding;
+ (void)prepareForDiameter:(CGFloat)diameter scale:(CGFloat)scale padding:(CGFloat)padding inBackground:(BOOL)bg;
@end
