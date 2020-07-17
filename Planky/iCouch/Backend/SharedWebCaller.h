//
//  SharedWebCaller.h
//  TestScope
//
//  Created by Gursharan Singh on 28/11/15.
//  Copyright © 2015 Neural Business. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SharedWebCaller : NSObject {
    BOOL isLoggedIn;
}

@property (strong, nonatomic) NSString* appURL;
@property (strong, nonatomic) NSString* cookie;
@property (strong, nonatomic) NSArray* cookies;
@property (strong, nonatomic) NSURLSessionConfiguration * configuration;

+ (SharedWebCaller *)sharedManager;

- (void)makeloginWebCallWithEmail:(NSString *)email andPassword:(NSString *)password
            withCompletionHandler:(void (^)(NSMutableDictionary *, NSError *))completionHandler
               withFailureHandler:(void (^)(NSMutableDictionary *, NSError *))failureHandler;

- (void)createUserWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email
                    andPassword:(NSString *)password  withCompletionHandler:(void (^)(NSMutableDictionary *, NSError *))completionHandler
             withFailureHandler:(void (^)(NSMutableDictionary *, NSError *))failureHandler;

- (void)makeSavePhotoCallWithDetails:(NSDictionary *)imageDictionary withCompletionHandler:(void (^)(NSMutableDictionary *, NSError *))completionHandler withFailureHandler:(void (^)(NSMutableDictionary *, NSError *))failureHandler;

- (void)getImageDetailsForImageId:(NSString *)imageId withCompletionHandler:(void (^)(NSMutableDictionary *, NSError *))completionHandler withFailureHandler:(void (^)(NSMutableDictionary *, NSError *))failureHandler;

-(void)logoutWithCompletionHandler:(void (^)(NSMutableDictionary *, NSError *))completionHandler withFailureHandler:(void (^)(NSMutableDictionary *, NSError *))failureHandler;


-(void)deletePhotoWithPhotosList:(NSMutableArray*)photosList WithCompletionHandler:(void (^)(NSMutableDictionary *, NSError *))completionHandler withFailureHandler:(void (^)(NSMutableDictionary *, NSError *))failureHandler;


@end
