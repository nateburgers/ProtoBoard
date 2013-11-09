//
//  PBComponentViewController.h
//  ProtoBoard
//
//  Created by Nathan Burgers on 11/9/13.
//  Copyright (c) 2013 Nathan Burgers. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PBComponentCallback)(NSString *);

@interface PBComponentViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property NSString *superClassString;
@property NSString *searchTerm;
@property UISearchBar *searchBar;
@property (weak, nonatomic) id delegate;
@property (strong) PBComponentCallback callback;

- (NSArray *)classes;
- (NSArray *)subclassesOf:(NSString *)class;

@end
