//
//  ServerCommManager.m
//  AMP
//
//  Created by Jason Malutich on 12/18/14.
//  Copyright (c) 2014 Jason Malutich. All rights reserved.
//

#import "ServerCommManager.h"

@implementation ServerCommManager

NSString *server = @"http://necron99-198373.usw1.nitrousbox.com/";
NSURL *base_url;

-(id)init
{
    self = [super init];
    base_url = [[NSURL alloc] initWithString: server];
    return self;
}

-(BOOL)LoginWithUsername:(NSString*)username
             AndPassword:(NSString*)password
        AndReturnMessage:(NSString**)returnMessage
{
    NSLog(@"Creating URL request");
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    [req setURL:[NSURL URLWithString: @"php/validate.php" relativeToURL:base_url]];
    [req setHTTPMethod:@"POST"];
    NSLog(@"URL created [%@]", req.URL.absoluteString);
    
    NSLog(@"Creating request body");
    NSString *body = [NSString stringWithFormat:@"request_type=login&username=%@&password=%@", username, password];
    [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *responseCode = nil;
    NSLog(@"Sending login request [%@, %@]", username, password);
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req
                                                 returningResponse:&responseCode
                                                             error:nil];
    if ([responseCode statusCode] != 200)
    {
        NSLog(@"Error logging in (%li) - %@", (long)responseCode.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode.statusCode]);
        *returnMessage = [NSHTTPURLResponse localizedStringForStatusCode:responseCode.statusCode];
        return false;
    }
    
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
    NSString *status = [response objectForKey:@"status"];
    
    if (![status isEqual: @"success"])
    {
        *returnMessage = [response objectForKey:@"msg"];
        return false;
    }
    
    NSLog(@"Looks like our request was successful!");
    *returnMessage = @"Success!";
    
    return true;
}


@end
