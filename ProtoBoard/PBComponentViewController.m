//
//  PBComponentViewController.m
//  ProtoBoard
//
//  Created by Nathan Burgers on 11/9/13.
//  Copyright (c) 2013 Nathan Burgers. All rights reserved.
//

#import <objc/runtime.h>
#import "PBComponentViewController.h"

@interface PBComponentViewController ()
{
//    __unsafe_unretained Class *_classes;
    NSArray *_classes;
    NSCache *_cache;
}
@property (readonly) NSCache *cache;
- (NSCache *)cacheForSelector:(SEL)selector;
@end

@implementation PBComponentViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _searchTerm = @"";
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
        _searchBar.delegate = self;
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_searchBar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.searchBar setFrame:CGRectMake(0.f, 0.f, 320.f, 44.f)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchTerm = searchText;
    [self.tableView reloadData];
}

- (NSCache *)cache
{
    return LAZY_INIT(_cache, [[NSCache alloc] init]);
}

- (NSArray *)classes
{
    if (!_classes) {
        NSMutableArray *result = [NSMutableArray array];
        NSUInteger classCount = objc_getClassList(NULL, 0);
        if (classCount > 0) {
            Class *classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * classCount);
            classCount = objc_getClassList(classes, classCount);
            for (size_t i=0; i<classCount; i++) {
                [result addObject:NSStringFromClass(classes[i])];
            }
        }
        _classes = result;
    }
    return _classes;
}

- (NSArray *)subclassesOf:(NSString *)class
{
    return [[self classes] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
        return [[evaluatedObject lowercaseString] hasPrefix:[self.searchTerm lowercaseString]];
    }]];
//    NSArray *result = [[self classes] filteredArrayUsingPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"description MATCHES %@", self.searchTerm],
//                                                                                                                       [NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
//        return class_getSuperclass(NSClassFromString(evaluatedObject)) == NSClassFromString(class);
//    }]]]];
//    return result;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self subclassesOf:self.superClassString] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Views";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = [self subclassesOf:self.superClassString][[indexPath indexAtPosition:1]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.callback) {
        id object = [[self subclassesOf:self.superClassString] objectAtIndex:[indexPath indexAtPosition:1]];
        self.callback(object);
    }
}

#pragma mark - Private Methods
- (NSCache *)cacheForSelector:(SEL)selector
{
    NSString *key = NSStringFromSelector(selector);
    if (![self.cache objectForKey:key]) {
        [self.cache setObject:[[NSCache alloc] init] forKey:key];
    }
    return [self.cache objectForKey:key];
}

@end
