//
//  PBViewController.h
//  ProtoBoard
//
//  Created by Nathan Burgers on 11/8/13.
//  Copyright (c) 2013 Nathan Burgers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBGameGenViewController;
@class PBUIGenViewController;

@interface PBViewController : UIViewController <UIImagePickerControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (readonly) NSMutableDictionary *buttonCallbacks;
@property (readonly) UITapGestureRecognizer *tapRecognizer;
@property (readonly) UIImagePickerController *imagePickerController;

- (void) viewWasTapped:(id)sender;

@end
