//
//  WebServiceResponse.h
//  MyScene
//
//  Created by Sashi Bhushan on 09/02/15.
//  Copyright (c) 2015 Appster. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WebServiceResponse : NSObject

@property (nonatomic,strong) NSString *message;
@property (nonatomic,strong) NSArray *result;
@property (nonatomic,assign) BOOL success;

-(instancetype)initWithData:(NSDictionary *)dataDic;

@end
