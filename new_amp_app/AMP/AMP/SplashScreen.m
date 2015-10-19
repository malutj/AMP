//
//  SplashScreen.m
//  AMP
//
//  Created by Jason Malutich on 10/18/15.
//  Copyright (c) 2015 Jason Malutich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SplashScreen.h"

@interface SplashScreen()
@property (weak, nonatomic) IBOutlet UIButton *learnMoreButton;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;


@end

@implementation SplashScreen

- (void)viewDidLoad
{
    // update the Learn More button
    self.learnMoreButton.layer.cornerRadius = 8;
    self.learnMoreButton.clipsToBounds = YES;
    [self.learnMoreButton setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.learnMoreButton.titleLabel.shadowOffset = CGSizeMake(-1.5,1.5);
    
    // update the login button
    self.loginButton.layer.cornerRadius = 8;
    self.loginButton.clipsToBounds = YES;
    [self.loginButton setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.loginButton.titleLabel.shadowOffset = CGSizeMake(-1.5,1.5);

}


- (IBAction)learnMorePressed:(UIButton *)sender
{
    
}

- (IBAction)loginPressed:(UIButton *)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginPage = [storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
    [self presentViewController:loginPage animated:YES completion:nil];
}


@end