//
//  PBDataViewController.m
//  ProtoBoard
//
//  Created by Nathan Burgers on 11/8/13.
//  Copyright (c) 2013 Nathan Burgers. All rights reserved.
//

#import "PBDataViewController.h"

@interface PBDataViewController ()

@end

@implementation PBDataViewController

+ (instancetype)controllerWithJSONSerialization:(NSDictionary *)json
{
    return [[self alloc] initWithJSONSerialization:json];
}

- (id)initWithJSONSerialization:(NSDictionary *)json
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _json = json;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
