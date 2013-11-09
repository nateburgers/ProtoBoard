//
//  PBDataViewController.h
//  ProtoBoard
//
//  Created by Nathan Burgers on 11/8/13.
//  Copyright (c) 2013 Nathan Burgers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PBDataViewController : UIViewController

+ (instancetype) controllerWithJSONSerialization:(NSDictionary *)json;
- (id) initWithJSONSerialization:(NSDictionary *)json;
@property (readonly) NSDictionary *json;

@end
