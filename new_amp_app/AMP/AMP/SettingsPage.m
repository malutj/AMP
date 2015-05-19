//
//  SettingsPage.m
//  AMP
//
//  Created by Jason Malutich on 4/27/15.
//  Copyright (c) 2015 Jason Malutich. All rights reserved.
//

#import "SettingsPage.h"
#import "ServerCommManager.h"

@interface SettingsPage ()
@property (strong, nonatomic) ServerCommManager *commManager;
@property (weak, nonatomic) IBOutlet UIProgressView *overallProgress;
@property (weak, nonatomic) IBOutlet UIButton *SyncCancelButton;

@property (weak, nonatomic) IBOutlet UILabel *fileLabel;
@property (weak, nonatomic) IBOutlet UILabel *overallLabel;
@property (nonatomic, assign) BOOL syncing;
@property (strong, nonatomic) NSString *clientCode;

@end

@implementation SettingsPage

UIWebView *webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    _commManager = [[ServerCommManager alloc]initWithPage:self];
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.syncing = false;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SyncCancelPressed:(UIButton *)sender {
    NSLog(@"Syncing");
    
    //SYNC BUTTON
    if (!self.syncing){
        self.syncing = true;
        _SyncCancelButton.enabled = false;
        
        //get the file list from the server
        if (_clientCode == nil){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            _clientCode = [defaults objectForKey:@"clientCode"];
        }
        NSLog(@"Getting the file list");
        
        NSMutableArray *file_list = [_commManager GetFileList:_clientCode];
        
        NSLog(@"Creating download list");
        NSMutableArray *download_list = [self GetDownloadList:file_list];
        
        int total_file_count = [download_list count];
        _fileLabel.text = @"";
        _fileLabel.hidden = false;
        _overallLabel.text = @"";
        _overallLabel.hidden = false;
        _fileProgress.progress = 0.0;
        _fileProgress.hidden = false;
        _overallProgress.progress = 0.0;
        _overallProgress.hidden = false;
        
        // DOWNLOAD THREAD
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            for (int i; i < [download_list count]; ++i) {
                //update UI on UI thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    //update overall label
                    NSLog(@"Setting label text");
                    _overallLabel.text = [[NSString alloc] initWithFormat:@"Downloading %d/%d...", i+1, total_file_count];
                    
                    //update progress bar
                    _overallProgress.progress = (i+1)/total_file_count;
                    
                    //update file label
                    _fileLabel.text = download_list[i];
                    
                    //reset file progress bar
                    _fileProgress.progress = 0;
                });
                
                _commManager.downloading = true;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [self DownloadFile: download_list[i]];
                });
                
                while (_commManager.downloading == true) {
                    //wait
                    NSLog(@"Waiting...");
                    [NSThread sleepForTimeInterval:2];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self DoneWithSync];
            });
        });
        
        
        
    }
    //CANCEL BUTTON
    else{
        self.syncing = false;
    }
}

-(void)DownloadFile: (NSString *)filename{
    NSString *path = [[NSString alloc] initWithFormat:@"%@/html_files/%@", [[NSBundle mainBundle] resourcePath],[self GetFileName:filename]];
    [_commManager DownloadFile:filename toPath:path withProgressBar:_fileProgress];
}

-(NSMutableArray *)GetDownloadList: (NSMutableArray *)file_list
{
    NSMutableArray *download_list = [[NSMutableArray alloc] init];
    NSFileManager *fm = [[NSFileManager alloc] init];

    BOOL addToList;
    
    for (int i = 0; i < [file_list count]; ++i) {
        addToList = true;
        //get the clean filename (no 'common' or 'client_name' folder at the front of the path)
        NSString *filename = [self GetFileName: file_list[i][0]];
        //NSString *path = [[NSString alloc] initWithFormat:@"%@/html_files/%@", [[NSBundle mainBundle] resourcePath],filename];
        NSString *path = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"/html_files/"] stringByAppendingPathComponent:filename];
        
        //see if the file exists
        NSLog(@"Checking file at path: %@", path);
        if ([fm fileExistsAtPath:path]){
            NSLog(@"%@ exists...checking mod time", filename);
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
        else
        {
            NSLog(@"%@ doesn't exist", filename);
        }
        
        if(addToList){
            [download_list addObject:file_list[i][0]];
        }
    }
    
    return download_list;
}

-(NSString *)GetFileName: (NSString *)s{
    int index = 0;
    for (index = 1; index < [s length]; ++index) {
        if ([s characterAtIndex:index] == '/') {
            break;
        }
    }

    return [s substringFromIndex:index+1];
}

-(void)DoneWithSync
{
    NSLog(@"done downloading!");
    NSString *filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"/html_files/index.html"];

    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath])
    {
        NSLog(@"Loading web view!");
        [webView loadRequest:[NSURLRequest requestWithURL:
                              [NSURL fileURLWithPath:filePath]]];
        [self.view addSubview:webView];
        NSLog(@"web view loaded...");
    }
    else
    {
        NSLog(@"File does NOT exist");
    }
}
@end