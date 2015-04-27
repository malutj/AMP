//
//  ViewController.m
//  AMP
//
//  Created by Jason Malutich on 4/21/15.
//  Copyright (c) 2015 Jason Malutich. All rights reserved.
//

#import "LoginScreen.h"
#import "CommManager.h"

@interface LoginScreen ()

@property NSUserDefaults *defaults;
@property NSString *clientCode;
@property (weak, nonatomic) IBOutlet UITextField *clientCodeField;
@property (strong, nonatomic) ServerCommManager *commManager;

@end

@implementation LoginScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    _commManager = [[ServerCommManager alloc]init];
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
    _clientCode = self.clientCodeField.text;
    if([_clientCode length]==0){
        NSLog(@"Attempt to log in with no username and/or password");
        return;
    }
    NSString *returnMessage;
    
    BOOL loginSuccessful = [_commManager LoginWithClientCode:_clientCode
                                         AndReturnMessage:&returnMessage];
    
    if (loginSuccessful)
    {
        //set client code in user defaults
        //close this view and open settings page
    }
    else
    {
        _response.text = returnMessage;
    }
}

@end
