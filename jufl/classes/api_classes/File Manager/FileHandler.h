//
//  FileHandler.h
//  ForIphone
//
//  Created by Satish Azad on 02/01/13.
//  Copyright (c) 2013 SAT. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface FileHandler : NSObject
{
    
}

/* Property */
@property (nonatomic, retain) NSString *dirPath;
//@property (nonatomic, retain) NSString *fileName;

/* init method */

-(id)init;
+(FileHandler *)sharedInstance;

/* Other Contents */
+ (NSString *)filePathFromDocuments:(NSString *)fileName;
-(void)createSubDirectory;

-(void)createDirectoryAtPath:(NSString*)folderPath;

-(NSString*)getFilteredImageFilePathWithFileName:(NSString*)fileName;

+(NSString *)saveImageToDocDir:(UIImage *)aImage withFileName:(NSString *)file;

-(UIImage*)getImageWithFileName:(NSString*)imageFileName;

+ (BOOL)removeImageWithFileName:(NSString*)fName;

+(void)deleteAllDirContents:(NSString *)dirPath;

+(NSArray*)getAllDirContents:(NSString *)directoryPAth;

-(NSArray*)getAllImageFromDir;

-(BOOL)deleteDir;

+ (UIImage*)getImageWithFilePath:(NSString *)imageFilePath;



#pragma mark - <File Handling Functions TNPAUL>
+(BOOL)isFileExistAtFolderPath:(NSString *)folderPath fileName:(NSString *)fileName;
+ (void)createFolderWithPath:(NSString *)folderPath;
+(NSString*)getPathForFolderPath:(NSString *)folderPath withFileName:(NSString*)fileName;
+ (void)saveFileWithData:(NSData *)fileData withFilePath:(NSString*)filePath;
+ (BOOL)saveFileWithData:(NSData *)fileData inFolder:(NSString*)folder withFileName:(NSString *)filename;

@end
