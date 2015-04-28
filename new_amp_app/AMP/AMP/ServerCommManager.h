
//
//  ServerCommManager.h
//  AMP
//
//  Created by Jason Malutich on 12/18/14.
//  Copyright (c) 2014 Jason Malutich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerCommManager : NSObject

-(BOOL)LoginWithClientCode:(NSString*)clientCode
        AndReturnMessage:(NSString**)returnMessage;

-(NSMutableArray*) GetFileList:(NSString*)clientCode;


@end
