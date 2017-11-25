//
//  KZUnitSlider.h
//
//  Created by Alex Restrepo on 5/11/11.
//  Copyright 2011 KZLabs http://kzlabs.me
//  All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KZUnitSlider : UIControl 
{	
    BOOL horizontal;
	CGFloat value;
}

@property (nonatomic, retain) UIImageView *sliderKnobView;
@property (nonatomic) CGFloat value;

@end
