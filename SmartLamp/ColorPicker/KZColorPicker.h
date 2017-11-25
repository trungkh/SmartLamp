//
//  KZColorWheelView.h
//
//  Created by Alex Restrepo on 5/11/11.
//  Copyright 2011 KZLabs http://kzlabs.me
//  All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RSColorPickerView.h"
#import "KZColorPickerBrightnessSlider.h"
//#import "KZColorPickerAlphaSlider.h"
#import "KZColorPickerSwatchView.h"
#import "KZColorStatusView.h"

#define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@interface KZColorPicker : UIControl {
    BOOL isSmallSize;
}

@property (nonatomic, retain) RSColorPickerView *colorPicker;
@property (nonatomic, retain) KZColorPickerBrightnessSlider *brightnessSlider;
//@property (nonatomic, retain) KZColorPickerAlphaSlider *alphaSlider;
@property (nonatomic, retain) KZColorStatusView *statusColorView;

@property (nonatomic, retain) NSMutableArray *swatches;
@property (nonatomic, retain) UIColor *selectedColor;

- (void) setSelectedColor:(UIColor *)color animated:(BOOL)animated;
- (void) fixLocations;
@end
