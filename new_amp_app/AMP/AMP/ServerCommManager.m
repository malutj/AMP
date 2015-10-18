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
NSUInteger totalBytes;
NSUInteger receivedBytes;
NSMutableData *fileData;
NSString *file_name;
NSString *file_path;
NSFileHandle *file;

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
    // create the url request
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    [req setURL:[NSURL URLWithString: @"php/clients.php" relativeToURL:base_url]];
    [req setHTTPMethod:@"POST"];
    
    // create the request body
    NSString *body = [NSString stringWithFormat:@"request_type=validate&clientCode=%@", clientCode];
    [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // send the request
    NSHTTPURLResponse *responseCode = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req
                                                 returningResponse:&responseCode
                                                             error:nil];
    // check the response code
    if ([responseCode statusCode] != 200)
    {
        NSLog(@"Error logging in (%li) - %@", (long)responseCode.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode.statusCode]);
        *returnMessage = [NSHTTPURLResponse localizedStringForStatusCode:responseCode.statusCode];
        return false;
    }
    
    // get the response array that the server sent
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
    // get the status that the server sent
    NSString *status = [response objectForKey:@"status"];
    
    if (![status isEqual: @"success"])
    {
        *returnMessage = [response objectForKey:@"msg"];
        return false;
    }
    
    *returnMessage = @"Success!";
    
    return true;
}


-(NSMutableArray*)GetFileList:(NSString *)clientCode{
    
    // create the url request
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    [req setURL:[NSURL URLWithString: @"php/sync.php" relativeToURL:base_url]];
    [req setHTTPMethod:@"POST"];
    
    // create the url request body
    NSString *body = [NSString stringWithFormat:@"app_code=%@&code=%@", app_code, clientCode];
    [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    // send the request
    NSHTTPURLResponse *responseCode = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req
                                                 returningResponse:&responseCode
                                                             error:nil];
    // check the response
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
        return [response objectForKey:@"file_list"];
    }
    else
    {
        NSLog(@"File list http request failed");
        NSLog(@"%@", [response objectForKey:@"msg"]);
    }
    
    return nil;
}


-(BOOL)DownloadFile:(NSString *)filename
             toPath:(NSString *)path
{
    self.totalBytes = 0;
    self.receivedBytes = 0;
    file_name = filename;
    file_path = path;
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];
    [req setURL:[NSURL URLWithString: @"php/download.php" relativeToURL:base_url]];
    [req setHTTPMethod:@"POST"];

    NSString *body = [NSString stringWithFormat:@"app_code=%@&file=%@", app_code, filename];
    [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];

    
    
    NSURLConnection *connection = [[NSURLConnection alloc ]initWithRequest:req delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];

    return true;
}

//callback methods for the URL connection
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSDictionary *dict = httpResponse.allHeaderFields;
    NSString *lengthString = [dict valueForKey:@"Content-Length"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *length = [formatter numberFromString:lengthString];
    self.totalBytes = length.unsignedIntegerValue;

    
    //find the file in the directory and save it in a file variable
    file = [NSFileHandle fileHandleForWritingAtPath:file_path];
    if (file)
    {
        [file truncateFileAtOffset:0];
    }
    else
    {
        // try to create the directories for the new file in case they're missing
        NSString *directories = [file_path stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:directories withIntermediateDirectories:YES attributes:nil error:nil];
        
        // create the new file
        [[NSFileManager defaultManager] createFileAtPath:file_path contents:nil attributes:nil];
        file = [NSFileHandle fileHandleForWritingAtPath:file_path];
    }
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    //save to file here
    [file writeData:data];
    
    self.receivedBytes += data.length;
    
    //update progress bar
    double progress = (double)self.receivedBytes / self.totalBytes;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressBarToUpdate setProgress:progress animated:YES];
        self.percentageToUpdate.text = [[NSString alloc] initWithFormat:@"%d%%", (int)progress];
    });
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Just finished saving file %@", file_path);
    [file closeFile];
    _downloading = false;
}


@end
