//
//  PBUIGenViewController.h
//  ProtoBoard
//
//  Created by Nathan Burgers on 11/8/13.
//  Copyright (c) 2013 Nathan Burgers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBDataViewController.h"

@interface PBUIGenViewController : PBDataViewController <UIActionSheetDelegate>

@property (readonly) NSArray *viewControllers;
@property (readonly) NSArray *views;

@property (readonly) NSCache *cache;
@property (readonly) UITapGestureRecognizer *tapRecognizer;

- (void) viewWasTapped:(UITapGestureRecognizer *)sender;
- (UIView *) viewUnderPoint:(CGPoint)point;

@end
