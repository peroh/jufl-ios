//
//  FileHandler.m
//  ForIphone
//
//  Created by Satish Azad on 02/01/13.
//  Copyright (c) 2013 SAT. All rights reserved.
//

#import "FileHandler.h"
#include <sys/xattr.h>

//#define ImageFilterDir   @"ImageFilterDir"
#define kSubDirName         @"Inventory"


@implementation FileHandler
@synthesize dirPath;//, fileName;

/* int implementation */
-(id)init
{
    self = [super init];
    
    if(self) {
        //Custom Initialization
        self.dirPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        [self createDirectoryAtPath:self.dirPath];
        
    }
    
    return self;
}


/*  Singleton Method */
+(FileHandler*)sharedInstance
{
    static FileHandler *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[FileHandler alloc]init];
    });
    
    return _sharedInstance;
}

//return File from Documnent Directory
+ (NSString *)filePathFromDocuments:(NSString *)fileName {
    
    // Create the file path
    NSString * filePath = [DOCUMENT_DIRECTORY stringByAppendingPathComponent:fileName];
    
    return filePath;
}
/* Create Dir of Name SubDirName */
-(void)createSubDirectory
{
    self.dirPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    [self createDirectoryAtPath:self.dirPath];
}

/* Creating Director if not exists */
-(void)createDirectoryAtPath:(NSString *)folderPath
{
    NSString *dPath = [folderPath stringByAppendingPathComponent:kSubDirName];
    NSError *error=nil;
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:dPath])
    {
        [[NSFileManager defaultManager]  createDirectoryAtPath:dPath withIntermediateDirectories:NO attributes:nil error:&error];
        DLog(@"Directory Created.. %@ ",dPath);

    }
    else
    {
        DLog(@"Directory Exists Already..");
    }
    
}


/* Get File Path with File Name */
-(NSString*)getFilteredImageFilePathWithFileName:(NSString *)fileName
{
    NSString *documentDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filterImageDir = [documentDir stringByAppendingPathComponent:kSubDirName];
    NSString *filePath=nil;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filterImageDir])
    {
        filePath = [filterImageDir stringByAppendingPathComponent:fileName];
    }
    else
    {
        filePath=@"";
    }
    
    return filePath;
}


/* Save Image to Dir */
+(NSString *)saveImageToDocDir:(UIImage *)aImage withFileName:(NSString *)file
{
    //NSString *filePath = [self getFilteredImageFilePathWithFileName:file];
    NSString *filePath = [DOCUMENT_DIRECTORY stringByAppendingPathComponent:file];

    NSData *imageData = UIImagePNGRepresentation(aImage);
    [imageData writeToFile:filePath atomically:YES];
    
    DLog(@"image saved => %@ .... ",file);
    
    return filePath;
}


/* Get Image With File Name */
-(UIImage*)getImageWithFileName:(NSString *)imageFileName
{
    NSString *path = [self getFilteredImageFilePathWithFileName:imageFileName];
    NSData *fData = [NSData dataWithContentsOfFile:path];
    
    UIImage *image = [UIImage imageWithData:fData];
    
    return image;
}

+ (UIImage*)getImageWithFilePath:(NSString *)imageFilePath
{
    NSError* error = nil;

    NSData *fData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:&error];
    
    UIImage *image = [UIImage imageWithData:fData];
    
    return image;
}

/* Remove Image With File Name */
+ (BOOL)removeImageWithFileName:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [DOCUMENT_DIRECTORY stringByAppendingPathComponent:fileName];
    NSError *error=nil;
    if([fileManager fileExistsAtPath:path])
        return [fileManager removeItemAtPath:path error:&error];
    else
        return NO;
}

/* Delete All Dir Contents */
+(void)deleteAllDirContents:(NSString *)dirPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error=nil;
    //NSArray *arr = [fileManager contentsOfDirectoryAtPath:imgFilterDir error:&error];
    [fileManager removeItemAtPath:dirPath error:&error];

}

/* Get All Dir Contents. Returns an Array of Filenames */
+(NSArray*)getAllDirContents:(NSString *)directoryPAth
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSString *path = [DOCUMENT_DIRECTORY stringByAppendingPathComponent:directoryPAth];
    NSError *error=nil;
    NSArray *arr = [fileManager contentsOfDirectoryAtPath:path error:&error];
    return arr;
}


/* Get All Dir Contents. Returns an Array of Image */
-(NSArray*)getAllImageFromDir
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imgFilterDir = [self.dirPath stringByAppendingPathComponent:kSubDirName];
    NSError *error=nil;
    NSArray *arr = [fileManager contentsOfDirectoryAtPath:imgFilterDir error:&error];
    
    NSMutableArray *imgArr = [[NSMutableArray alloc]init];
    
    for (NSString *file in arr)
    {
        NSString *p = [self getFilteredImageFilePathWithFileName:file];
        if([fileManager fileExistsAtPath:p])
        {
            NSData *imgData = [NSData dataWithContentsOfFile:p];
            UIImage *image =[UIImage imageWithData:imgData];
            [imgArr addObject:image];
        }
        
    }
    
    return imgArr;
}


/* Delete Dir */
-(BOOL)deleteDir
{
    //[self deleteAllDirContents];
    
    NSString *f = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    f=[f stringByAppendingPathComponent:kSubDirName];
    NSError *error=nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:f])
    {
       return [[NSFileManager defaultManager] removeItemAtPath:f error:&error];
    }
    else
    {
        return NO;
    }
    
}



#pragma mark - <File Handling Functions TNPAUL>
+(BOOL)isFileExistAtFolderPath:(NSString *)folderPath fileName:(NSString *)fileName
{
    NSString *folderP = [DOCUMENT_DIRECTORY stringByAppendingPathComponent:folderPath];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",folderP,fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return NO;
    }
    
    return YES;
}

+ (void)createFolderWithPath:(NSString *)folderPath
{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:folderPath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
}


/*
 * folderPath - This Path is the path inside Document folder of iPhone.
 */

+(NSString*)getPathForFolderPath:(NSString *)folderPath withFileName:(NSString*)fileName{
    
    
    NSString *pathToFolder = [DOCUMENT_DIRECTORY stringByAppendingPathComponent:folderPath];
    NSString *filePath = [pathToFolder stringByAppendingPathComponent:fileName];
    
    return filePath;
}

/*
 This Function will write NSData to a file at path.
 If folder already exist then it simply saves the file
 else it will create the folder then will save the file.
 */
+ (void)saveFileWithData:(NSData *)fileData withFilePath:(NSString*)filePath
{
    // Add attribute for "do not backup"
    u_int8_t b = 1;
    //#include <sys/xattr.h>
    setxattr([filePath fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
    [fileData writeToFile:filePath atomically:YES];
}

/*
 This Function will write NSData to a file at specified folder and file.
 If folder already exist then it simply saves the file
 else it will create the folder then will save the file.
 */
+ (BOOL)saveFileWithData:(NSData *)fileData inFolder:(NSString*)folder withFileName:(NSString *)filename
{
    NSString *filePath = [FileHandler getPathForFolderPath:folder withFileName:filename];
    
    // Add attribute for "do not backup"
    //u_int8_t b = 1;
    //#include <sys/xattr.h>
    //setxattr([filePath fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
    BOOL writeFlag = [fileData writeToFile:filePath atomically:YES];
    if (writeFlag == FALSE)
    {
        DLog(@"Failed to write data on Document dir");
    }
    else{
        DLog(@"Succesfully saved.");
        
    }
    return writeFlag;
}


@end

















