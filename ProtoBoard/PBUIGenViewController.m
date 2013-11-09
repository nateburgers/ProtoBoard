//
//  PBUIGenViewController.m
//  ProtoBoard
//
//  Created by Nathan Burgers on 11/8/13.
//  Copyright (c) 2013 Nathan Burgers. All rights reserved.
//

#import "PBUIGenViewController.h"
#import "PBComponentViewController.h"
#import "PBPropertyViewController.h"

@interface PBUIGenViewController ()
{
    NSCache *_cache;
    UITapGestureRecognizer *_tapRecognizer;
}
- (void)setupView;
- (void)view:(UIView **)view underPoint:(CGPoint)point withParent:(UIView *)parent;
@end

@implementation PBUIGenViewController

- (id)initWithJSONSerialization:(NSDictionary *)json
{
    if (self = [super initWithJSONSerialization:json]) {
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        [self setupView];
    }
    return self;
}
#pragma mark - Setup View
- (void)setupView
{
    CGRect (^normalRect)(CGPoint center) = ^(CGPoint center){
        return CGRectMake(center.x-100, center.y-22, 200, 44);
    };
    
    NSDictionary *callbacksByClassifier = @{@"class0": ^UIView *(CGPoint center){
        UILabel *label = [[UILabel alloc] initWithFrame:normalRect(center)];
        label.text = @"New Label";
        return label;
    }, @"class1": ^UIView *(CGPoint center){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = normalRect(center);
        [button setTitle:@"New Button" forState:UIControlStateNormal];
        return button;
    }, @"class2": ^UIView *(CGPoint center){
        UISwitch *toggle = [[UISwitch alloc] initWithFrame:normalRect(center)];
        toggle.on = NO;
        return toggle;
    }, @"class3": ^UIView *(CGPoint center){
        UISlider *slider = [[UISlider alloc] initWithFrame:normalRect(center)];
        slider.minimumValue = 0.f;
        slider.maximumValue = 1.f;
        slider.value = 0.f;
        return slider;
    }, @"class4": ^UIView *(CGPoint center){
        UITextField *field = [[UITextField alloc] initWithFrame:normalRect(center)];
        return field;
    }};
    
    [self.json[@"entities"] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *objects, BOOL *stop) {
        [objects enumerateObjectsUsingBlock:^(NSDictionary *object, NSUInteger idx, BOOL *stop) {
            CGPoint point = CGPointMake([[NSDecimalNumber decimalNumberWithString:object[@"x"]] floatValue],
                                        [[NSDecimalNumber decimalNumberWithString:object[@"y"]] floatValue]);
            UIView *(^callback)(CGPoint) = callbacksByClassifier[key];
            UIView *view = callback(point);
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)];
            [view addGestureRecognizer:tapRecognizer];
            [self.view addSubview:view];
        }];
    }];
}

#pragma mark - Properties
- (NSCache *)cache
{
    return LAZY_INIT(_cache, [[NSCache alloc] init]);
}

- (UITapGestureRecognizer *)tapRecognizer
{
    return LAZY_INIT(_tapRecognizer, [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addGestureRecognizer:self.tapRecognizer];
}

- (void)viewWasTapped:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationOfTouch:0 inView:self.view];
    UIView *viewUnderPoint = [self viewUnderPoint:point];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Edit", @"Add View", @"Add View Controller", nil];
    actionSheet.delegate = self;
    
    [self.cache setObject:[[NSCache alloc] init] forKey:actionSheet];
    
    [[self.cache objectForKey:actionSheet] setObject:^{
        PBPropertyViewController *propertyViewController = [[PBPropertyViewController alloc] initWithObject:viewUnderPoint andCallback:^(id object) {
            
        }];
        [self.navigationController pushViewController:propertyViewController animated:YES];
    }forKey:@(0)];
    
    [[self.cache objectForKey:actionSheet] setObject:^{
        PBComponentViewController *componentPicker = [[PBComponentViewController alloc] init];
        componentPicker.superClassString = NSStringFromClass([UIView class]);
        [self.navigationController pushViewController:componentPicker animated:YES];
            componentPicker.callback = ^(NSString *class){
                
                id object = [[NSClassFromString(class) alloc] init];
                PBPropertyViewController *propertyViewController = [[PBPropertyViewController alloc] initWithObject:object andCallback:^(UIView *view) {
                    view.frame = CGRectMake(point.x-100, point.y-22, 200, 44);
                    [viewUnderPoint addSubview:view];
                    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)];
                    [view addGestureRecognizer:tapRecognizer];
                    [self.view setNeedsLayout];
                    [self.view setNeedsDisplay];
                }];
                [self.navigationController pushViewController:propertyViewController animated:YES];
            };
    }forKey:@(1)];
    
    [[self.cache objectForKey:actionSheet] setObject:^{
        PBComponentViewController *componentPicker = [[PBComponentViewController alloc] init];
        componentPicker.superClassString = NSStringFromClass([UIViewController class]);
        [self.navigationController pushViewController:componentPicker animated:YES];
        componentPicker.callback = ^(NSString *class){
            
            id object = [[NSClassFromString(class) alloc] init];
            PBPropertyViewController *propertyViewController = [[PBPropertyViewController alloc] initWithObject:object andCallback:^(id object) {
                [self.navigationController presentViewController:propertyViewController animated:YES completion:nil];
            }];
            [self.navigationController pushViewController:propertyViewController animated:YES];
        };
    }forKey:@(2)];
    
    [actionSheet showInView:viewUnderPoint];
}

- (UIView *)viewUnderPoint:(CGPoint)point
{
    UIView *view = nil;
    [self view:&view underPoint:point withParent:self.view.superview];
    return view;
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    PBThunk thunk = [[self.cache objectForKey:actionSheet] objectForKey:@(buttonIndex)];
    if (thunk) thunk();
}

#pragma mark - Private Methods
- (void)view:(UIView **)viewUnderPoint underPoint:(CGPoint)point withParent:(UIView *)parent
{
    UIView *globalView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    for (UIView *view in parent.subviews) {
        if (view.superview != nil && view.hidden == NO && view.alpha > 0) {
            CGPoint localPoint = [globalView convertPoint:point fromView:view];
            if ([view pointInside:localPoint withEvent:nil]) {
                *viewUnderPoint = view;
                break;
            }
            [self view:viewUnderPoint underPoint:point withParent:view];
        }
    }
}

@end
