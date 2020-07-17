//
//  DropBox.m
//  BackUpRestore
//
//  Created by Avnish Chuchras on 4/15/15.
//  Copyright (c) 2015 NIIT Tech. All rights reserved.
//

#import "DropBox.h"
#import "AppDelegate.h"
#import "ImageMetaData.h"



@implementation DropBox

static DropBox *sharedInstance = nil;

+ (DropBox *)sharedInstance {
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

// setup the data collection
- init {
    if (self = [super init]) {
        // Intialize the Dropbox API
        NSString *dropBoxAppKey = AppKey;
        NSString *dropBoxAppSecret = AppSecret;
        NSString *root = kDBRootDropbox;
        
        DBSession* session = [[DBSession alloc] initWithAppKey:dropBoxAppKey appSecret:dropBoxAppSecret root:root];
        session.delegate = self;
        [DBSession setSharedSession:session];
        [DBRequest setNetworkRequestDelegate:self];
        
        self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        self.restClient.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLoginDone:) name:@"OPEN_DROPBOX_VIEW" object:nil];
    }
    return self;
}


#pragma mark - DBSessionDelegate methods
- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId {
    NSString *relinkUserId;
    relinkUserId = userId;
}


#pragma mark - DBNetworkRequestDelegate methods
static int outstandingRequests;
- (void)networkRequestStarted
{
    outstandingRequests++;
    if (outstandingRequests == 1) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)networkRequestStopped
{
    outstandingRequests--;
    if (outstandingRequests == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}


#pragma mark DropBox Delegate

- (void)dropboxLoginDone:(id)sender {
    //[self uploadCompletionHandler:self.dataArray];
    
    if ([self.dropboxDelegate respondsToSelector:@selector(dropboxConnectionComplete)]) {
        [self.dropboxDelegate dropboxConnectionComplete];
    }
    
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    
    // File upload successfull
    if ([self.dropboxDelegate respondsToSelector:@selector(fileUploadCompleteWithId:)]) {
        [self.dropboxDelegate fileUploadCompleteWithId:self.uploadFileId];
    }
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    if ([self.dropboxDelegate respondsToSelector:@selector(failedToConnectToDropbox)]) {
        [self.dropboxDelegate failedToConnectToDropbox];
    }
    
    NSLog(@"File upload failed with error: %@", error);
}

- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress forFile:(NSString*)destPath from:(NSString*)srcPath {
    
    if ([self.dropboxDelegate respondsToSelector:@selector(fileUploadProgress:forFile:from:)])
        [self.dropboxDelegate fileUploadProgress:progress forFile:destPath from:srcPath];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    NSLog(@"Error loading metadata: %@", error);
}


- (void)uploadCompletionHandler:(NSMutableArray*)dataArray {
    
    if ([self.dataArray count] == 0) {
        self.CompletionHandler(nil,nil);
        
        return;
    }
    
    ImageMetaData *imageMetaData = [self.dataArray firstObject];
    [self.dataArray removeObjectAtIndex:0];
    [self.restClient uploadFile:imageMetaData.imageName toPath:imageMetaData.imagePath withParentRev:nil fromPath:imageMetaData.imageURL];
}


#pragma mark - Uplaod File

- (void)uploadImageName:(NSString *)imageName fromImagePath:(NSString *)imagePath toPath:(NSString *)destPath {
    
    NSLog(@"imageName = %@", imageName);
    self.uploadFileId = imageName;
    [self.restClient uploadFile:imageName toPath:destPath withParentRev:nil fromPath:imagePath];
}


#pragma mark - Download File

- (void)downloadFileWithId:(NSString *)fileId toPath:(NSString *)filePath {
    self.downloadFileId = fileId;
    [self.restClient loadFile:[NSString stringWithFormat:@"/Planky/%@", fileId] intoPath:filePath];
}


#pragma mark - Dropbox Download Delegate Methods

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
   
    if ([self.dropboxDelegate respondsToSelector:@selector(fileDownloadCompleteWithId:)]) {
        [self.dropboxDelegate fileDownloadCompleteWithId:self.downloadFileId];
    }
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {

    if ([self.dropboxDelegate respondsToSelector:@selector(fileDownloadFailedWithId:andError:)]) {
        [self.dropboxDelegate fileDownloadFailedWithId:self.downloadFileId andError:error];
    }
}

-(DBRestClient*) restClient
{
    if (_restClient == nil) {
        if ( [[DBSession sharedSession].userIds count] ) {
            _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
            _restClient.delegate = self;
        }
    }
    
    return _restClient;
}

@end
