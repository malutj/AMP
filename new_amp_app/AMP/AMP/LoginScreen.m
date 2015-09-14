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
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@property (weak, nonatomic) IBOutlet UIImageView *tr;
@end

@implementation LoginScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    _commManager = [[ServerCommManager alloc]init];
    // Do any additional setup after loading the view, typically from a nib.
    
    // update the look of the sync buton
    self.connectButton.layer.cornerRadius = 10;
    self.connectButton.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectButtonPressed:(UIButton *)sender {
    NSString *clientCode = self.clientCodeField.text;
    if([clientCode length]==0){
        _response.text = @"Please enter a client code";
        NSLog(@"Attempt to log in with no username and/or password");
        return;
    }
    else if([clientCode isEqualToString:@"danoonez"])
    {
        _response.text = @"";
        _tr.hidden = false;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            sleep(2);
            dispatch_async(dispatch_get_main_queue(), ^{
               _tr.hidden = true;
            });
        });
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
        
        //create the html_files directory
        NSArray *path_array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = path_array[0];
        NSError * error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        
        if (error != nil) {
            _response.text = @"Error creating the html_files folder";
            NSLog(@"error creating directory: %@", error);
            return;
        }
        
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
