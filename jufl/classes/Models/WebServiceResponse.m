//
//  WebServiceResponse.m
//  MyScene
//
//  Created by Sashi Bhushan on 09/02/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#import "WebServiceResponse.h"

@implementation WebServiceResponse

-(instancetype)initWithData:(NSDictionary *)dataDic
{
    self = [super init];
    if(self)
    {
        _message = [dataDic objectForKey:kMessage];
        _result = [dataDic objectForKey:kResult];
        _success = [[dataDic objectForKey:kSuccess] boolValue];
    }
    return self;
}

@end
