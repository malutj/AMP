//
//  ServerCommManager.m
//  AMP
//
//  Created by Jason Malutich on 12/18/14.
//  Copyright (c) 2014 Jason Malutich. All rights reserved.
//

#import "ServerCommManager.h"

@implementation ServerCommManager

SettingsPage *sp;
NSString *server = @"http://ampupmypractice.com/";
NSURL *base_url;
NSString *app_code = @"j5K4F98j3vnME57G10f";
UIProgressView *pv = nil;
NSUInteger totalBytes;
NSUInteger receivedBytes;
NSMutableData *fileData;
NSString *file_name;
NSString *file_path;
NSFileHandle *file;

-(id)initWithPage:(SettingsPage *) page
{
    sp = page;
    return [self init];
}

-(id)init
{
    self = [super init];
    base_url = [[NSURL alloc] initWithString: server];
    _downloading = false;
    return self;
}

-(BOOL)LoginWithClientCode:(NSString*)clientCode
        AndReturnMessage:(NSString**)returnMessage
{
    NSLog(@"Creating URL request");
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    NSLog(@"base url: %@", base_url.path);
    [req setURL:[NSURL URLWithString: @"php/clients.php" relativeToURL:base_url]];
    [req setHTTPMethod:@"POST"];
    NSLog(@"URL created [%@]", req.URL.absoluteString);
    
    NSLog(@"Creating request body");
    NSString *body = [NSString stringWithFormat:@"request_type=validate&clientCode=%@", clientCode];
    [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *responseCode = nil;
    NSLog(@"Sending login request [%@]", clientCode);
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req
                                                 returningResponse:&responseCode
                                                             error:&error];
    if (error)
    {
        NSLog(@"Something went wrong - %@", [error userInfo]);
    }
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
    self.totalBytes = 0;
    self.receivedBytes = 0;
    file_name = filename;
    file_path = path;
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    [req setURL:[NSURL URLWithString: @"php/download.php" relativeToURL:base_url]];
    [req setHTTPMethod:@"POST"];
    NSLog(@"URL created [%@]", req.URL.absoluteString);

    NSString *body = [NSString stringWithFormat:@"app_code=%@&file=%@", app_code, filename];
    [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];

    NSLog(@"Sending file download request [%@]", filename);
    
    NSURLConnection *connection = [[NSURLConnection alloc ]initWithRequest:req delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];

    return true;
}

//callback methods for the URL connection
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse");
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSDictionary *dict = httpResponse.allHeaderFields;
    NSString *lengthString = [dict valueForKey:@"Content-Length"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *length = [formatter numberFromString:lengthString];
    self.totalBytes = length.unsignedIntegerValue;
    NSLog(@"Total download bytes: %d", self.totalBytes);
    
    //find the file in the directory and save it in a file variable
    NSLog(@"saving file to path: %@", file_path);
    file = [NSFileHandle fileHandleForWritingAtPath:file_path];
    if (file)
    {
        [file truncateFileAtOffset:0];
    }
    else
    {
        [[NSFileManager defaultManager] createFileAtPath:file_path contents:nil attributes:nil];
        file = [NSFileHandle fileHandleForWritingAtPath:file_path];
    }

    
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData");
    //save to file here
    [file writeData:data];
    
    self.receivedBytes += data.length;
    NSLog(@"received bytes: %d", self.receivedBytes);
    
    //update progress bar
    double progress = (double)self.receivedBytes / self.totalBytes;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"updating progress bar: %d/%d = %f", self.receivedBytes, self.totalBytes, progress);
        [sp.fileProgress setProgress:progress animated:true];
    });
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"didFinishLoading");
    [file closeFile];
    _downloading = false;
}


@end
