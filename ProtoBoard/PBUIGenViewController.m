//
//  PBUIGenViewController.m
//  ProtoBoard
//
//  Created by Nathan Burgers on 11/8/13.
//  Copyright (c) 2013 Nathan Burgers. All rights reserved.
//

#import "PBUIGenViewController.h"

@interface PBUIGenViewController ()
{
    NSCache *_cache;
    UITapGestureRecognizer *_tapRecognizer;
}
- (void)view:(UIView **)view underPoint:(CGPoint)point withParent:(UIView *)parent;
@end

@implementation PBUIGenViewController

- (id)initWithJSONSerialization:(NSDictionary *)json
{
    if (self = [super initWithJSONSerialization:json]) {
        
    }
    return self;
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
    actionSheet.delegate = self;
    
    [self.cache setObject:[[NSCache alloc] init] forKey:actionSheet];
    [[self.cache objectForKey:actionSheet] setObject:^{
        [viewUnderPoint addSubview:[UIButton buttonWithType:UIButtonTypeContactAdd]];
    } forKey:@([actionSheet addButtonWithTitle:@"Add View"])];
    
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
    thunk();
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
