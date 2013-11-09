//
//  PBPropertyViewController.h
//  ProtoBoard
//
//  Created by Nathan Burgers on 11/9/13.
//  Copyright (c) 2013 Nathan Burgers. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PBPropertyCompletion)(id object);

@interface PBPropertyViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

- (id) initWithObject:(id)object andCallback:(PBPropertyCompletion)block;

@property (strong, readonly) PBPropertyCompletion callback;
@property (readonly) id object;
@property (readonly) NSDictionary *typesByProperty;

- (void) create:(id)sender;

@end
