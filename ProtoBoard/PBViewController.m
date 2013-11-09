//
//  PBViewController.m
//  ProtoBoard
//
//  Created by Nathan Burgers on 11/8/13.
//  Copyright (c) 2013 Nathan Burgers. All rights reserved.
//

#import <AFNetworking.h>
#import "PBAppDelegate.h"
#import "PBViewController.h"
#import "PBUIGenViewController.h"
#import "PBGameGenViewController.h"

@interface PBViewController ()
{
    NSMutableDictionary *_buttonCallbacks;
    UIImagePickerController *_imagePickerController;
}
@end

@implementation PBViewController

- (id)init
{
    if (self = [super init]) {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)];
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

#pragma mark - Properties
- (NSMutableDictionary *)buttonCallbacks
{
    if (!_buttonCallbacks) {
        _buttonCallbacks = [NSMutableDictionary dictionary];
    }
    return _buttonCallbacks;
}

- (UIImagePickerController *)imagePickerController
{
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.sourceType = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        ? UIImagePickerControllerSourceTypeCamera
        : UIImagePickerControllerSourceTypePhotoLibrary ;
    }
    return _imagePickerController;
}

- (void)viewDidLoad
{
    NSLog(@"view loaded");
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addGestureRecognizer:self.tapRecognizer];
    [self presentViewController:self.imagePickerController animated:NO completion:^{
        NSLog(@"presented view controller");
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Gesture Recognizer
- (void)viewWasTapped:(id)sender
{
    [self presentViewController:self.imagePickerController animated:YES completion:^{
        NSLog(@"presented view controller");
    }];
}

#pragma mark - Image Picker Controller Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage]
    ?: [info objectForKey:UIImagePickerControllerOriginalImage];
    
    image = [UIImage imageWithCGImage:image.CGImage scale:0.25 orientation:image.imageOrientation];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = self.view.bounds;
    [self.view addSubview:imageView];
    NSData *imageData = UIImagePNGRepresentation(image);
    
    // test
    void (^respond)(id) = ^(id responseObject){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Use As..." message:@"Select what to do with your image" delegate:self cancelButtonTitle:@"Nothing" otherButtonTitles: nil];
        UINavigationController *navigationController = self.navigationController;
        self.buttonCallbacks[@([alertView addButtonWithTitle:@"Game"])] = ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            [navigationController pushViewController:[PBGameGenViewController controllerWithJSONSerialization:responseObject] animated:YES];
        };
        self.buttonCallbacks[@([alertView addButtonWithTitle:@"UI"])] = ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            [navigationController pushViewController:[PBUIGenViewController controllerWithJSONSerialization:responseObject] animated:YES];
        };
        [alertView show];
    };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://184.169.153.235:80/" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:@"capture.png" mimeType:@"image/png"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        respond(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //            NSAssert(NO, @"HTTP REQUEST DONE FUCKED UP: %@", error.description);
        respond(@{@"entities": @[@{@"class1":@[@{@"x": @(20), @"y": @(20)}]}]});
    }];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    PBThunk thunk = self.buttonCallbacks[@(buttonIndex)];
    if (thunk) thunk();
}

@end
