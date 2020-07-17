//
//  DropBox.h
//  BackUpRestore
//
//  Created by Avnish Chuchras on 4/15/15.
//  Copyright (c) 2015 NIIT Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>

@protocol DropboxDelegate <NSObject>

@optional

// Dropbox Connection Succedded
- (void)dropboxConnectionComplete;

// Failed to Connect to Dropbox
- (void)failedToConnectToDropbox;

// File upload complete
- (void)fileUploadCompleteWithId:(NSString *)fileId;

// File upload failed
- (void)fileUploadFailedWithId:(NSString *)fileId andError:(NSDictionary *)error;

// Upload progress
- (void)fileUploadProgress:(CGFloat)progress forFile:(NSString*)destPath from:(NSString*)srcPath;

// File download successful
- (void)fileDownloadCompleteWithId:(NSString *)fileId;

// File download failed
- (void)fileDownloadFailedWithId:(NSString *)file andError:(NSError *)error;

@end

typedef void(^BackupCompletionHandler)(NSArray *, NSError *);
@interface DropBox : NSObject < DBSessionDelegate, DBNetworkRequestDelegate , DBRestClientDelegate >

@property (nonatomic) NSMutableArray *dataArray;
@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, copy) void(^CompletionHandler)(NSArray *, NSError *);

@property (nonatomic, assign) id       dropboxDelegate;

@property (nonatomic, strong) NSString *    downloadFileId;
@property (nonatomic, strong) NSString *    uploadFileId;


+ (DropBox *)sharedInstance;
- (void)backUpCompletionHandler:(NSMutableArray*)dataArray
                  viewControler:(UIViewController *)controller
                     completion:(BackupCompletionHandler)completionHandler;

- (void)uploadImageName:(NSString *)imageName fromImagePath:(NSString *)imagePath toPath:(NSString *)destPath;

- (void)downloadFileWithId:(NSString *)fileId toPath:(NSString *)filePath;

@end
