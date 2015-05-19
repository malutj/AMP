
//
//  ServerCommManager.h
//  AMP
//
//  Created by Jason Malutich on 12/18/14.
//  Copyright (c) 2014 Jason Malutich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SettingsPage.h"

@interface ServerCommManager : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic) NSMutableData *imageData;
@property (nonatomic) NSUInteger totalBytes;
@property (nonatomic) NSUInteger receivedBytes;
@property (nonatomic) BOOL downloading;

-(id)initWithPage:(SettingsPage*) page;

-(BOOL)LoginWithClientCode:(NSString*)clientCode
        AndReturnMessage:(NSString**)returnMessage;

-(NSMutableArray*) GetFileList:(NSString*)clientCode;

-(BOOL)DownloadFile:(NSString *)filename
             toPath:(NSString *)path
    withProgressBar:(UIProgressView *)progressBar;

@end
