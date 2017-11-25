//
//  AboutViewController.m
//
//  Created by Trung Huynh on 7/11/15.
//  Copyright (c) 2015 Smart Lamp. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController

@synthesize version;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"About", nil);
    //self.version = [[UILabel alloc] init];
    
    UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *beView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    beView.frame = self.view.bounds;
    
    self.view.frame = self.view.bounds;
    self.view.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f];
    [self.view insertSubview:beView atIndex:0];
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                   target:self
                                   action:@selector(cancel:)];
    
    self.navigationItem.leftBarButtonItem = buttonItem;
}

- (IBAction)cancel:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
