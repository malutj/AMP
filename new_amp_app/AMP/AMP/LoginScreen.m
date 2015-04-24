//
//  ViewController.m
//  AMP
//
//  Created by Jason Malutich on 4/21/15.
//  Copyright (c) 2015 Jason Malutich. All rights reserved.
//

#import "LoginScreen.h"

@interface LoginScreen ()

@property NSUserDefaults *defaults;
@property NSString* clientCode;
@property (weak, nonatomic) IBOutlet UITextField *clientCodeField;

@end

@implementation LoginScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)clientCodeIsSet {
    if(!_defaults)
        _defaults = [NSUserDefaults standardUserDefaults];
    
    _clientCode = [_defaults stringForKey:@"clientCode"];
    
    return _clientCode != nil ? true : false;
}
- (IBAction)connectButtonPressed:(UIButton *)sender {
}

- (BOOL)clientValidationSuccessful:(NSString *)cc {
    //send http request
    //check http response
    
    return true;
}

@end
