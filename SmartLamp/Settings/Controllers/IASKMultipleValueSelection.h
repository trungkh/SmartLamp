//
//  IASKMultipleValueSelection.h
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009:
//  Luc Vandal, Edovia Inc., http://www.edovia.com
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//  All rights reserved.
//
//  It is appreciated but not required that you give credit to Luc Vandal and Ortwin Gentz,
//  as the original authors of this code. You can give credit in a blog post, a tweet or on
//  a info page of your app. Also, the original authors appreciate letting them know if you use this code.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//

#import <UIKit/UIKit.h>

@class IASKSpecifier;
@protocol IASKSettingsStore;

/// Encapsulates the selection among multiple values.
/// This is used for PSMultiValueSpecifier and PSRadioGroupSpecifier
@interface IASKMultipleValueSelection : NSObject

@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, retain) IASKSpecifier *specifier;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, copy, readonly) NSIndexPath *checkedItem;
@property (nonatomic, strong) id<IASKSettingsStore> settingsStore;

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)updateSelectionInCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath;

@end
