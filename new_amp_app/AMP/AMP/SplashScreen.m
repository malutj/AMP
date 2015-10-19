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
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UILabel *leadsLabel;


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

    // update the leads label
    NSMutableAttributedString* leadsString = [[NSMutableAttributedString alloc] initWithString:@"And Convert More Leads into Patients"];
    
    [leadsString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:32.0] range:NSMakeRange(4,18)];
    [leadsString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.51 green:.16 blue:.50 alpha:1.0] range:NSMakeRange(4,18)];
    self.leadsLabel.attributedText = leadsString;
    
    // update the question label
    NSMutableAttributedString* questionString = [[NSMutableAttributedString alloc] initWithString:@"Ready to AMP up your practice?"];
    
    [questionString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:28.0] range:NSMakeRange(9,3)];
    [questionString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.51 green:.16 blue:.50 alpha:1.0] range:NSMakeRange(9,3)];
    self.questionLabel.attributedText = questionString;
}


- (IBAction)learnMorePressed:(UIButton *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http:ampupmypractice.com"]];
}

- (IBAction)loginPressed:(UIButton *)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginPage = [storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
    [self presentViewController:loginPage animated:YES completion:nil];
}

- (IBAction)leftVideoPressed:(UIButton *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://d.pr/v/14G1Y"]];

}
- (IBAction)middleVideoPressed:(UIButton *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://d.pr/v/S8eM"]];
}
- (IBAction)rightVideoPressed:(UIButton *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://d.pr/v/11mUd"]];
}


@end