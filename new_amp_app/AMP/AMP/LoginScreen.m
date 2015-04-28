//
//  ViewController.m
//  AMP
//
//  Created by Jason Malutich on 4/21/15.
//  Copyright (c) 2015 Jason Malutich. All rights reserved.
//

#import "LoginScreen.h"
#import "ServerCommManager.h"
#import "SettingsPage.h"

@interface LoginScreen ()

@property (weak, nonatomic) IBOutlet UITextField *clientCodeField;
@property (weak, nonatomic) IBOutlet UILabel *response;
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

- (IBAction)connectButtonPressed:(UIButton *)sender {
    NSString *clientCode = self.clientCodeField.text;
    if([clientCode length]==0){
        NSLog(@"Attempt to log in with no username and/or password");
        return;
    }
    NSString *returnMessage;
    
    BOOL loginSuccessful = [_commManager LoginWithClientCode:clientCode
                                         AndReturnMessage:&returnMessage];
    
    if (loginSuccessful)
    {
        NSLog(@"Login was successful!");
        
        //set client code in user defaults
        [self setClientCode:clientCode];
        /*
        NSLog(@"messing with navigation controller");
        //close this view and open settings page
        UINavigationController *navController = self.navigationController;
        NSMutableArray *activeViews = [[NSMutableArray alloc] initWithArray: navController.viewControllers];
        NSLog(@"removing last view from array");
        [activeViews removeLastObject];
        
        NSLog(@"Setting the navigation controllers list of views");
        [navController setViewControllers:activeViews];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NSLog(@"Getting settings page view");
        UIViewController *settingsPage = [storyboard instantiateViewControllerWithIdentifier:@"SettingsPage"];
        NSLog(@"Pushing view");
        [navController pushViewController:settingsPage animated:YES];
        NSLog(@"Pushed!");
        
        [self dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"should be closed");
         */
        
        NSLog(@"Presenting the settings page");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *settingsPage = [storyboard instantiateViewControllerWithIdentifier:@"SettingsPage"];
        [self presentViewController:settingsPage animated:YES completion:nil];
        
    }
    else
    {
        NSLog(@"Login failed!");
        _response.text = returnMessage;
    }
}

- (void)setClientCode:(NSString *)clientCode{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:clientCode forKey:@"clientCode"];
}

@end
