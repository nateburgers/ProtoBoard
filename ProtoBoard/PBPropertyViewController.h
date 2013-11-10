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

@property (strong, readonly) PBPropertyCompletion callback;
@property (readonly) id object;
@property (readonly) NSDictionary *typesByProperty;

- (id) initWithObject:(id)object andCallback:(PBPropertyCompletion)block;

- (void) create:(id)sender;

- (NSString *)typeOf:(NSString *)property inClass:(NSString *)class;

- (NSDictionary *)typesByPropertyOfClass:(NSString *)class;

@end
