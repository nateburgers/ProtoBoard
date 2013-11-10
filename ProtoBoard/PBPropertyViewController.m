//
//  PBPropertyViewController.m
//  ProtoBoard
//
//  Created by Nathan Burgers on 11/9/13.
//  Copyright (c) 2013 Nathan Burgers. All rights reserved.
//

#import <objc/runtime.h>
#import "PBPropertyViewController.h"

@interface PBPropertyViewController ()
{
    NSString *_classString;
}
@end

@implementation PBPropertyViewController

- (id)initWithObject:(id)object andCallback:(PBPropertyCompletion)block
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _object = object;
        _callback = block;
        UIBarButtonItem *commitButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(create:)];
        self.navigationItem.rightBarButtonItem = commitButton;
    }
    return self;
}

- (NSDictionary *)typesByProperty
{
    return [self typesByPropertyOfClass:NSStringFromClass([self.object class])];
}

- (NSDictionary *)typesByPropertyOfClass:(NSString *)class
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSUInteger count;
    objc_property_t *properties = class_copyPropertyList(NSClassFromString(class), &count);
    for (size_t i=0; i<count; i++) {
        objc_property_t property = properties[i];
        
        const char * name = property_getName(property);
        NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        const char * type = property_getAttributes(property);
        
        NSString * typeString = [NSString stringWithUTF8String:type];
        NSArray * attributes = [typeString componentsSeparatedByString:@","];
        NSString * typeAttribute = [attributes objectAtIndex:0];
        
        if ([typeAttribute hasPrefix:@"T@"] && [typeAttribute length] > 1 && [typeAttribute characterAtIndex:2] != '?') {
            NSString * typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length]-4)];
            [result setObject:typeClassName forKey:propertyName];
        }
    }
    return result;
}

#pragma mark - Methods
- (void)create:(id)sender
{
    if (self.callback) {
        [self.navigationController popViewControllerAnimated:YES];
        self.callback(self.object);
    }
}

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.typesByProperty count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSString *key = [[self.typesByProperty allKeys] objectAtIndex:[indexPath indexAtPosition:1]];
    NSString *class = [[self.typesByProperty allValues] objectAtIndex:[indexPath indexAtPosition:1]];
    cell.textLabel.text = key;
    cell.detailTextLabel.text = class;
    
    Class propertyClass = NSClassFromString([self typesByPropertyOfClass:NSStringFromClass([self.object class])][key]);
    if ([[[propertyClass alloc] init] isKindOfClass:[NSString class]]){
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(110.f, 10.f, 200.f, 30.f)];
        cell.accessoryView = textField;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *key = [[self.typesByProperty allKeys] objectAtIndex:[indexPath indexAtPosition:1]];
    Class propertyClass = NSClassFromString([[self.typesByProperty allValues] objectAtIndex:[indexPath indexAtPosition:1]]);
    
    PBPropertyViewController *nestedController = [[PBPropertyViewController alloc] initWithObject:[[propertyClass alloc]init] andCallback:^(id object) {
        NSString *cap = [[key substringToIndex:1] capitalizedString];
        NSString *rest = [key substringWithRange:NSMakeRange(1, key.length-1)];
        NSString *selector = [NSString stringWithFormat:@"set%@%@:", cap, rest];
        [self.object performSelector:NSSelectorFromString(selector) withObject:object];
    }];
    [self.navigationController pushViewController:nestedController animated:YES];
}

@end
