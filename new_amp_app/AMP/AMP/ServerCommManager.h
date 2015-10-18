
//
//  ServerCommManager.h
//  AMP
//
//  Created by Jason Malutich on 12/18/14.
//  Copyright (c) 2014 Jason Malutich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ServerCommManager : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic) NSUInteger totalBytes;
@property (nonatomic) NSUInteger receivedBytes;
@property (nonatomic) BOOL downloading;
@property (nonatomic) UIProgressView *progressBarToUpdate;
@property (nonatomic) UILabel *percentageToUpdate;

-(BOOL)LoginWithClientCode:(NSString*)clientCode
        AndReturnMessage:(NSString**)returnMessage;

-(NSMutableArray*) GetFileList:(NSString*)clientCode;

-(BOOL)DownloadFile:(NSString *)filename
             toPath:(NSString *)path;

@end
