//
//  SettingsPage.m
//  AMP
//
//  Created by Jason Malutich on 4/27/15.
//  Copyright (c) 2015 Jason Malutich. All rights reserved.
//

#import "SettingsPage.h"
#import "ServerCommManager.h"
#import <QuartzCore/QuartzCore.h>

@interface SettingsPage ()
@property (strong, nonatomic) ServerCommManager *commManager;
@property (weak, nonatomic) IBOutlet UIButton *SyncButton;

@property (weak, nonatomic) IBOutlet UILabel *fileLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *fileProgress;
@property (weak, nonatomic) IBOutlet UILabel *overallLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *overallProgress;

@property (nonatomic, assign) BOOL syncing;
@property (strong, nonatomic) NSString *clientCode;
@property (weak, nonatomic) IBOutlet UIButton *LaunchButton;
@property (weak, nonatomic) IBOutlet UILabel *filePercentage;
@property (weak, nonatomic) IBOutlet UILabel *overallPercentage;

@end

@implementation SettingsPage

UIWebView *webView;
bool syncing = false;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // initialize the server communication manager
    self.commManager = [[ServerCommManager alloc]init];
    self.commManager.progressBarToUpdate = self.fileProgress;
    self.commManager.percentageToUpdate = self.filePercentage;
    
    // initialize the web view
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    
    // update the look of the sync and launch buttons
    self.SyncButton.layer.cornerRadius = 8;
    self.SyncButton.clipsToBounds = YES;
    [self.SyncButton setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.SyncButton.titleLabel.shadowOffset = CGSizeMake(-1.5,1.5);
    
    self.LaunchButton.layer.cornerRadius = 8;
    self.LaunchButton.clipsToBounds = YES;
    [self.LaunchButton setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.LaunchButton.titleLabel.shadowOffset = CGSizeMake(-1.5,1.5);
    
    // update height of progress bars
    [self.fileProgress setTransform:CGAffineTransformMakeScale(1.0, 3.0)];
    [self.overallProgress setTransform:CGAffineTransformMakeScale(1.0, 3.0)];
    
    // display the launch button if a root index file is present
    if ([self RootFileExists])
    {
        NSLog(@"Found root file. Making launch visible");
        self.LaunchButton.hidden = false;
    }
    else
    {
        NSLog(@"Couldn't find root file. Hiding launch button");
        self.LaunchButton.hidden = true;
    }
}


//This method resets all of the UI labels and progress bars
- (void)ResetLabelsAndProgressBars
{
    _fileLabel.text = @"";
    _fileLabel.hidden = false;
    _overallLabel.text = @"";
    _overallLabel.hidden = false;
    _fileProgress.progress = 0.0;
    _fileProgress.hidden = false;
    _overallProgress.progress = 0.0;
    _overallProgress.hidden = false;
    _overallPercentage.hidden = false;
    _overallPercentage.text = @"0%%";
    _filePercentage.hidden = false;
    _filePercentage.text = @"0%%";
}


- (void)HideLabelsAndProgressBars
{
    // this clears all the labels
    [self ResetLabelsAndProgressBars];
    
    // now hide everything until sync is pressed again
    _fileLabel.hidden = true;
    _overallLabel.hidden = true;
    _fileProgress.hidden = true;
    _overallProgress.hidden = true;
    _filePercentage.hidden = true;
    _overallPercentage.hidden = true;
}


//This method updates the UI labels and progress bars during download
- (void)UpdateLabelsAndProgressBars:(int)currentFile
                         totalFiles:(int)totalFiles
                           filename:(NSString*)filename
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //update overall label
        self.overallLabel.text = [[NSString alloc] initWithFormat:@"Downloading %d/%d", currentFile, totalFiles];
        
        //update overall progress bar
        self.overallProgress.progress = (double)(currentFile)/totalFiles;
        
        //update overall percentage
        self.overallPercentage.text = [[NSString alloc]initWithFormat:@"%d%%", ((currentFile-1)*100)/totalFiles];
        
        //update file label
        self.fileLabel.text = filename;
        
        //reset file progress bar
        self.fileProgress.progress = 0;
        
        //reset file percentage
        self.filePercentage.text = @"0%";
        
    });
}


//This method downloads a list of files from the server
- (void)DownloadFileList:(NSMutableArray *)download_list
{
    // loop through the download list and download each file
    for (int i=0; i < [download_list count]; ++i)
    {
        //update UI
        [self UpdateLabelsAndProgressBars:i+1 totalFiles:(int)[download_list count] filename:download_list[i]];
        
        // ask the server communication manager to download the file
        self.commManager.downloading = true;
        [self DownloadFile: download_list[i]];

        // wait for this download to finish before starting the next
        while (self.commManager.downloading == true) {
            [NSThread sleepForTimeInterval:0.2];
        }
    }
}


// SYNC BUTTON PRESSED
- (IBAction)SyncPressed:(UIButton *)sender
{
    self.SyncButton.enabled = false;
    self.LaunchButton.hidden = true;
    
    //get client code from User settings
    if (self.clientCode == nil){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.clientCode = [defaults objectForKey:@"clientCode"];
    }
    
    // get the entire list of files for this client
    NSMutableArray *file_list = [self.commManager GetFileList:self.clientCode];
    
    // make sure our server manager returned something
    if (file_list == nil)
    {
        NSLog(@"GetFileList call returned a null array pointer");
        [self DoneWithSync];
        return;
    }
    
    // create the list of files we're going to download
    NSMutableArray *download_list = [self GetDownloadList:file_list];
    
    // delete all of the files that are no longer needed
    [self DeleteOldFiles:file_list];
    
    // if download list is empty, just skip this part
    if ([download_list count] == 0)
    {
        NSLog(@"No files to download...");
        [self DoneWithSync];
        return;
    }
    
    // reset the labels and progress bars
    [self ResetLabelsAndProgressBars];
    
    // DOWNLOAD THREAD
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // download the file list
        [self DownloadFileList:download_list];
        
        // let main thread know that we finished downloading
        dispatch_async(dispatch_get_main_queue(), ^{
            [self DoneWithSync];
        });
    });
}

- (IBAction)LaunchPressed:(UIButton *)sender {
    [self OpenWebView:[self GetRootFileName]];
}

//This method asynchronously downloads the specified file.
- (void)DownloadFile: (NSString *)filename{
    // create the path to which we want to download the file
    NSArray *path_array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = path_array[0];
    path = [path stringByAppendingPathComponent:@"/html_files/"];
    path = [path stringByAppendingPathComponent:[self GetFileName:filename]];
    
    // dispatch the download
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.commManager DownloadFile:filename toPath:path];
    });
}


//This method creates a list of all files in the html_files directory
//that need to be deleted.
- (void)DeleteOldFiles: (NSMutableArray *)file_list
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    //build the path to the root html_files directory
    NSArray *path_array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = path_array[0];
    path = [path stringByAppendingPathComponent:@"/html_files/"];
    
    NSDirectoryEnumerator *directory = [fm enumeratorAtPath:path];
                                        
    for (NSString *file in directory)
    {
        BOOL isDirectory = NO;
        NSString *fullpath = [path stringByAppendingPathComponent: file];
        [fm fileExistsAtPath:fullpath isDirectory:&isDirectory];
        if (!isDirectory)
        {
            BOOL delete = true;
            // loop through our file list and mark items not found for deletion
            for (int i = 0; i < [file_list count]; ++i)
            {
                NSString *found_file = file_list[i][0];
                
                if ([[self GetFileName:found_file] isEqual:file])
                {
                    delete = false;
                    break;
                }
            }
            if (delete)
            {
                NSLog(@"Deleting '%@'", file);
                [fm removeItemAtPath:fullpath error:nil];
            }
        }
    }
}


//This method creates a list of all files on the server that
//need to be downloaded.
- (NSMutableArray *)GetDownloadList: (NSMutableArray *)file_list
{
    NSMutableArray *download_list = [[NSMutableArray alloc] init];
    NSFileManager *fm = [[NSFileManager alloc] init];

    bool addToList;
    for (int i = 0; i < [file_list count]; ++i) {
        addToList = true;
        
        //get the clean filename
        NSString *filename = [self GetFileName: file_list[i][0]];
        
        //build the path to the file
        NSArray *path_array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = path_array[0];
        path = [path stringByAppendingPathComponent:@"/html_files/"];
        path = [path stringByAppendingPathComponent:filename];
        
        //see if the file exists
        if ([fm fileExistsAtPath:path])
        {
            //get mod date of local file
            NSDictionary *file_attributes = [fm attributesOfItemAtPath:path error:nil];
            NSDate *local_mod_time = [file_attributes objectForKey:NSFileModificationDate];
            
            //convert time of file on server
            NSDate *server_mod_time = [NSDate dateWithTimeIntervalSince1970:[file_list[i][1] doubleValue]];
            
            //if the local time is later than or equal to what is on the server, don't add
            if ( [local_mod_time compare:server_mod_time] != NSOrderedAscending ){
                addToList = false;
            }
        }
        
        if(addToList){
            //NSLog(@"%@", file_list[i][0]);
            [download_list addObject:file_list[i][0]];
        }
    }
    
    return download_list;
}


//This method removes the leading directory from the string and returns just the filename
//ex. "/Common/index.html" returns as "index.html"
- (NSString *)GetFileName: (NSString *)s{
    int index = 0;
    for (index = 1; index < [s length]; ++index) {
        if ([s characterAtIndex:index] == '/') {
            break;
        }
    }

    return [s substringFromIndex:index+1];
}


//This method loads and displays the root html file in the html_files folder
- (void)OpenWebView: (NSString*)filePath
{
    // load the web page
    [webView loadRequest:[NSURLRequest requestWithURL: [NSURL fileURLWithPath:filePath]]];
        
    // hide the status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
        
    // add self as the delegate for the webview callbacks
    [webView setDelegate:self];
        
    // display the webview
    [self.view addSubview:webView];
}

- (BOOL)RootFileExists
{
    // find the path to the index.html file
    NSArray *path_array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath  = path_array[0];
    NSString *filePath2 = path_array[0];
    filePath  = [filePath stringByAppendingPathComponent:@"/html_files/index.php"];
    filePath2 = [filePath2 stringByAppendingPathComponent:@"/html_files/index.html"];
    
    // check if the index.php file exists
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath])
    {
        NSLog(@"Found index.php");
        return true;
    }
    // didn't find index.php. check for index.html
    else if([fm fileExistsAtPath:filePath2])
    {
        NSLog(@"Found index.html");
        return true;
    }
    
    return false;
}


-(NSString*)GetRootFileName
{
    // find the path to the index.html file
    NSArray *path_array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath  = path_array[0];
    NSString *filePath2 = path_array[0];
    filePath  = [filePath stringByAppendingPathComponent:@"/html_files/index.php"];
    filePath2 = [filePath2 stringByAppendingPathComponent:@"/html_files/index.html"];
    
    // check if the index.php file exists
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath])
    {
        return filePath;
    }
    // didn't find index.php. check for index.html
    else if([fm fileExistsAtPath:filePath2])
    {
        return filePath2;
    }
    
    return nil;
}


//This method is called when the sync process is finished
- (void)DoneWithSync
{
    NSLog(@"Sync finished");
    self.SyncButton.enabled = true;
    [self HideLabelsAndProgressBars];
    if ([self RootFileExists])
    {
        NSLog(@"Root file exists. Enabling launch button");
        self.LaunchButton.hidden = false;
    }
    else
    {
        NSLog(@"Couldn't find root file.");
        self.LaunchButton.hidden = true;
        _fileLabel.text = @"Unable to find root index file";
        _fileLabel.hidden = false;
    }
}


//This method is called whenever a link is pressed within the web view
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
                                                 navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[request.URL lastPathComponent]  isEqual: @"SettingsPage"])
    {
        [webView removeFromSuperview];
        return NO;
    }

    return YES;
}

@end
