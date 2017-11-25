//
//  KZColorWheelView.m
//
//  Created by Alex Restrepo on 5/11/11.
//  Copyright 2011 KZLabs http://kzlabs.me
//  All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KZColorPicker.h"

#import "RSColorFunctions.h"
#import "HSV.h"

#define COLOR(color) [UIColor colorWithRed:((color >> 16) & 0xFF)/255.0f \
                                     green:((color >> 8) & 0xFF)/255.0f \
                                      blue:((color >> 0) & 0xFF)/255.0f \
                                     alpha:((color >> 24) & 0xFF)/255.0f]


@implementation KZColorPicker

@synthesize colorPicker;
@synthesize brightnessSlider;
@synthesize selectedColor;
//@synthesize alphaSlider;
@synthesize swatches;
@synthesize statusColorView = _statusColorView;

- (void) setup
{
    // set the frame to a fixed 300 x 300
    //self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 300, 280);
    //self.backgroundColor = IS_IPAD ? [UIColor clearColor] :
    //          [UIColor colorWithRed:0.225 green:0.225 blue:0.225 alpha:1.000];
    self.backgroundColor = COLOR(0xFF252510);
    
    /*UIGraphicsBeginImageContext(self.frame.size);
    [[UIImage imageNamed:@"Background"] drawInRect:self.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundColor = [UIColor colorWithPatternImage:image];*/
    
    // View that displays color picker (needs to be square)
    colorPicker = [[RSColorPickerView alloc] initWithFrame:CGRectMake(40.0, 95.0, 240.0, 240.0)];
    // Set the selection color - useful to present when the user had picked a color previously
    [colorPicker setSelectionColor:[UIColor redColor]];
    // Set the delegate to receive events
    [colorPicker addTarget:self action:@selector(colorWheelChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:colorPicker];
    
    // current color indicator hier.
    KZColorStatusView *statusView = [[KZColorStatusView alloc] initWithFrame:CGRectMake(260, 78, 44, 44)];
    self.statusColorView = statusView;
    [self addSubview:statusView];
    
    // brightness slider
    KZColorPickerBrightnessSlider *brightness = [[KZColorPickerBrightnessSlider alloc]
                                             initWithFrame:CGRectMake(24, 277, 272, 38)];
    [brightness addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:brightness];
    self.brightnessSlider = brightness;
    
    // alpha slider
    /*KZColorPickerAlphaSlider *alpha = [[KZColorPickerAlphaSlider alloc]
                                             initWithFrame:CGRectMake(24, 321, 272, 38)];
    [alpha addTarget:self action:@selector(alphaChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:alpha];
    self.alphaSlider = alpha;*/
    
    // swatches.
    NSMutableArray *colors = [NSMutableArray array];
    [colors addObject:[UIColor colorWithHue:((M_PI / 180.0 * 0) / (2 * M_PI)) saturation:1.0 brightness:1.0 alpha:1.0]];
    [colors addObject:[UIColor colorWithHue:((M_PI / 180.0 * 60) / (2 * M_PI))  saturation:1.0 brightness:1.0 alpha:1.0]];
    [colors addObject:[UIColor colorWithHue:((M_PI / 180.0 * 120) / (2 * M_PI))  saturation:1.0 brightness:1.0 alpha:1.0]];
    [colors addObject:[UIColor colorWithHue:((M_PI / 180.0 * 240) / (2 * M_PI))  saturation:1.0 brightness:1.0 alpha:1.0]];
    [colors addObject:[UIColor colorWithWhite:1.0 alpha:1.0]];

    KZColorPickerSwatchView *swatch = nil;
    self.swatches = [NSMutableArray array];
    for (UIColor *color in colors)
    {
        swatch = [[KZColorPickerSwatchView alloc] initWithFrame:CGRectZero];
        [swatch addTarget:self action:@selector(swatchAction:) forControlEvents:UIControlEventTouchUpInside];
        swatch.color = color;
        [self addSubview:swatch];
        [self.swatches addObject:swatch];
    }

    [self fixLocations];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame]))
    {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void) awakeFromNib
{
    [self setup];
}

RGBType rgbWithUIColor(UIColor *color)
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r,g,b;
    
    switch (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)))
    {
        case kCGColorSpaceModelMonochrome:
            r = g = b = components[0];
            break;
        case kCGColorSpaceModelRGB:
            r = components[0];
            g = components[1];
            b = components[2];
            break;
        default:	// We don't know how to handle this model
            return RGBTypeMake(0, 0, 0);
    }
    
    return RGBTypeMake(r, g, b);
}

- (void) setSelectedColor:(UIColor *)color animated:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [self.colorPicker setSelectionColor:color];
        self.selectedColor = color;
        [UIView commitAnimations];
    }
    else
    {
        self.selectedColor = color;
    }
}

- (void) setSelectedColor:(UIColor *)color
{
    RGBType rgb = rgbWithUIColor(color);
    HSVType hsv = RGB_to_HSV(rgb);
    
    self.brightnessSlider.value = hsv.v;
    //self.alphaSlider.value = [color alpha];
    
    if (hsv.h != 0 && hsv.s != 0)
    {
        UIColor *keyColor = [UIColor colorWithHue:hsv.h
                                       saturation:hsv.s
                                       brightness:1.0
                                            alpha:1.0];
        [self.brightnessSlider setKeyColor:keyColor];
        
        /*keyColor = [UIColor colorWithHue:hsv.h
                              saturation:hsv.s
                              brightness:hsv.v
                                   alpha:1.0];
        [self.alphaSlider setKeyColor:keyColor];*/
    }
    else
    {
        UIColor *colorWheel = [self.colorPicker selectionColor];
        RGBType rgbWheel = rgbWithUIColor(colorWheel);
        HSVType hsvWheel = RGB_to_HSV(rgbWheel);
        
        UIColor *keyColor = [UIColor colorWithHue:hsvWheel.h
                                       saturation:hsvWheel.s
                                       brightness:1.0
                                            alpha:1.0];
        [self.brightnessSlider setKeyColor:keyColor];
        
        /*keyColor = [UIColor colorWithHue:hsvWheel.h
                              saturation:hsvWheel.s
                              brightness:hsv.v
                                   alpha:1.0];
        [self.alphaSlider setKeyColor:keyColor];*/
    }
    
    self.statusColorView.currentColor = color;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) colorWheelChanged:(RSColorPickerView *)wheel
{
    UIColor *color = [wheel selectionColor];
    RGBType rgb = rgbWithUIColor(color);
    HSVType hsv = RGB_to_HSV(rgb);
    
    /*self.selectedColor = [UIColor colorWithHue:hsv.h
                                    saturation:hsv.s
                                    brightness:self.brightnessSlider.value
                                         alpha:self.alphaSlider.value];*/
    
    self.selectedColor = [UIColor colorWithHue:hsv.h
                                    saturation:hsv.s
                                    brightness:self.brightnessSlider.value
                                         alpha:1.0];
}

- (void) brightnessChanged:(KZColorPickerBrightnessSlider *)slider
{
    UIColor *color = [self.colorPicker selectionColor];
    RGBType rgb = rgbWithUIColor(color);
    HSVType hsv = RGB_to_HSV(rgb);
    
    /*self.selectedColor = [UIColor colorWithHue:hsv.h
                                    saturation:hsv.s
                                    brightness:self.brightnessSlider.value
                                         alpha:self.alphaSlider.value];*/
    
    self.selectedColor = [UIColor colorWithHue:hsv.h
                                    saturation:hsv.s
                                    brightness:self.brightnessSlider.value
                                         alpha:1.0];
}

/*- (void) alphaChanged:(KZColorPickerAlphaSlider *)slider
{
    UIColor *color = [self.colorPicker selectionColor];
    RGBType rgb = rgbWithUIColor(color);
    HSVType hsv = RGB_to_HSV(rgb);
 
    self.selectedColor = [UIColor colorWithHue:hsv.h
                                    saturation:hsv.s
                                    brightness:self.brightnessSlider.value
                                         alpha:self.alphaSlider.value];
}*/

- (void) swatchAction:(KZColorPickerSwatchView *)sender
{
    [self setSelectedColor:sender.color animated:YES];
}

- (void) fixLocations
{
    //horizontal
    if(self.bounds.size.width < self.bounds.size.height)
    {
        CGFloat totalWidth = self.bounds.size.width - 40.0;
        CGFloat swatchCellWidth = totalWidth / 6.0;
        
        int sx = 45;
        int sy = 500;
        for (KZColorPickerSwatchView *swatch in self.swatches)
        {
            swatch.frame = CGRectMake(sx + swatchCellWidth * 0.5 - 18.0,
                                      sy, 36.0, 36.0);
            sx += swatchCellWidth;
        }
        
        self.brightnessSlider.frame = CGRectMake(24, 360, 272, 38);
        //self.alphaSlider.frame = CGRectMake(24, 379, 272, 38);
    }
    else
    {
        CGFloat totalWidth = 160.0;
        CGFloat swatchCellWidth = totalWidth / 3.0;
        
        int sx = 300;
        int sy = 140;
        int index = 0;
        for (KZColorPickerSwatchView *swatch in self.swatches)
        {
            swatch.frame = CGRectMake(sx + swatchCellWidth * 0.5 - 18.0,
                                      sy, 36.0, 36.0);
            sx += swatchCellWidth;
            if(++index % 3 == 0)
            {
                sx = 300;
                sy += swatchCellWidth;
            }
        }
        
        self.brightnessSlider.frame = CGRectMake(300,
                                                 self.bounds.size.height * 0.5 - 38 - 50,
                                                 165,
                                                 38);
        
        //self.alphaSlider.frame = CGRectMake(300,
        //                                    self.bounds.size.height * 0.5 + 5 - 50,
        //                                    165,
        //                                    38);
    }
}

/*- (void) layoutSubviews
{
    [UIView beginAnimations:nil context:nil];
    
    [self fixLocations];
    
    [UIView commitAnimations];
}*/

@end
