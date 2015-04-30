//
//  ServerCommManager.m
//  AMP
//
//  Created by Jason Malutich on 12/18/14.
//  Copyright (c) 2014 Jason Malutich. All rights reserved.
//

#import "ServerCommManager.h"

@implementation ServerCommManager

NSString *server = @"http://ampupmypractice.com/";
NSURL *base_url;
NSString *app_code = @"j5K4F98j3vnME57G10f";
UIProgressView *pv = nil;
BOOL downloading = false;
int totalBytes;
NSData *fileData;

-(id)init
{
    self = [super init];
    base_url = [[NSURL alloc] initWithString: server];
    return self;
}

-(BOOL)LoginWithClientCode:(NSString*)clientCode
        AndReturnMessage:(NSString**)returnMessage
{
    NSLog(@"Creating URL request");
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    [req setURL:[NSURL URLWithString: @"php/clients.php" relativeToURL:base_url]];
    [req setHTTPMethod:@"POST"];
    NSLog(@"URL created [%@]", req.URL.absoluteString);
    
    NSLog(@"Creating request body");
    NSString *body = [NSString stringWithFormat:@"request_type=validate&clientCode=%@", clientCode];
    [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *responseCode = nil;
    NSLog(@"Sending login request [%@]", clientCode);
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

-(NSMutableArray*)GetFileList:(NSString *)clientCode{
    
    NSLog(@"Creating URL request");
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    [req setURL:[NSURL URLWithString: @"php/sync.php" relativeToURL:base_url]];
    [req setHTTPMethod:@"POST"];
    NSLog(@"URL created [%@]", req.URL.absoluteString);
    
    NSLog(@"Creating request body");
    NSString *body = [NSString stringWithFormat:@"app_code=%@&code=%@", app_code, clientCode];
    [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *responseCode = nil;
    NSLog(@"Sending request for file list [%@]", clientCode);
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req
                                                 returningResponse:&responseCode
                                                             error:nil];
    if ([responseCode statusCode] != 200)
    {
        NSLog(@"Error getting file list (%li) - %@", (long)responseCode.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode.statusCode]);
        return nil;
    }
    
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
    NSString *status = [response objectForKey:@"status"];
    if ([status isEqual: @"success"])
    {
        NSLog(@"Looks like our request was successful!");
        return [response objectForKey:@"file_list"];
    }
    else{
        NSLog(@"Looks like our call failed");
        NSLog(@"%@", [response objectForKey:@"msg"]);
    }
    return nil;
}

-(BOOL)DownloadFile:(NSString *)filename
             toPath:(NSString *)path
    withProgressBar:(UIProgressView *)progressBar{
    
    NSLog(@"Creating URL request");
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    [req setURL:[NSURL URLWithString: @"php/download.php" relativeToURL:base_url]];
    [req setHTTPMethod:@"POST"];
    NSLog(@"URL created [%@]", req.URL.absoluteString);
    
    NSLog(@"Creating request body");
    NSString *body = [NSString stringWithFormat:@"app_code=%@&file=%@", app_code, filename];
    [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    
    NSLog(@"Sending file download request [%@]", filename);
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    //now wait on the download to finish before returning. We don't want
    //to start the next download request before the first one finishes
    while (downloading) {
        //wait
        downloading = false;
    }
    return true;
}

//callback methods for the URL connection
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
 
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{

    // Actual progress is self.receivedBytes / self.totalBytes
}

@end
