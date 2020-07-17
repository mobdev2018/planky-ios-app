//
//  SharedWebCaller.m
//  TestScope
//
//  Created by Gursharan Singh on 28/11/15.
//  Copyright © 2015 Neural Business. All rights reserved.
//

#import "SharedWebCaller.h"
#import "AppDelegate.h"
#import "NSString+SBJSON.h"

@implementation SharedWebCaller



+ (SharedWebCaller *)sharedManager {
    // Persistent instance.
    static SharedWebCaller *_instance = nil;
    
    // Small optimization to avoid wasting time after the
    // singleton being initialized.
    if (_instance != nil)
    {
        return _instance;
    }
    // Allocates once with Grand Central Dispatch (GCD) routine.
    // It's thread safe.
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void)
                  {
                      _instance = [[SharedWebCaller alloc] init];
                      // private initialization goes here.
                      _instance.appURL = @"http://52.4.60.212:6125";
                  });
    return _instance;
}


#pragma mark - login/register/update user

- (void)makeloginWebCallWithEmail:(NSString *)email andPassword:(NSString *)password
            withCompletionHandler:(void (^)(NSMutableDictionary *, NSError *))completionHandler
               withFailureHandler:(void (^)(NSMutableDictionary *, NSError *))failureHandler {
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

    NSString *urlStr;
    
    self.configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    self.configuration.HTTPShouldSetCookies = YES;
   
    urlStr = [NSString stringWithFormat:@"%@/api/login", self.appURL];
    
    
    //prepare post data
    NSURL *loginURL = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loginURL];
    NSString *post = [NSString stringWithFormat:@"email=%@&password=%@", email, password];
    post = [post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPShouldHandleCookies = YES;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.configuration];
    session.configuration.HTTPCookieStorage.cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways ;
    session.configuration.HTTPShouldSetCookies = YES;
    [[session dataTaskWithRequest:request completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error)
      {
          if (!error)
          {
              NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
              self.cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[httpResp allHeaderFields] forURL:[response URL]];
              [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:self.cookies forURL:[request URL] mainDocumentURL:[request mainDocumentURL]];
              
              NSDictionary *fields = [httpResp allHeaderFields];
              self.cookie = [fields valueForKey:@"Set-Cookie"];
              
              if (self.cookie)
              {
                  self.cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
                  [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:self.cookies forURL:[request URL] mainDocumentURL:[request mainDocumentURL]];
                  
                  for (NSHTTPCookie *cookie in self.cookies) {
                      NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
                      [cookieProperties setObject:cookie.name forKey:NSHTTPCookieName];
                      [cookieProperties setObject:cookie.value forKey:NSHTTPCookieValue];
                      [cookieProperties setObject:cookie.domain forKey:NSHTTPCookieDomain];
                      [cookieProperties setObject:cookie.path forKey:NSHTTPCookiePath];
                      [cookieProperties setObject:[NSNumber numberWithUnsignedInteger:cookie.version] forKey:NSHTTPCookieVersion];
                      
                      [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:86400] forKey:NSHTTPCookieExpires];
                      
                      NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
                      [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                      [self.configuration.HTTPCookieStorage setCookie:cookie];
                  }
                  self.configuration.HTTPAdditionalHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:self.cookies];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                      NSMutableDictionary *responseDict = [responseStr JSONValue];
                      completionHandler (responseDict, error);
                  });
              }
              else
              {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      failureHandler(nil, error);
                  });
              }
              
          }
          else
          {
              dispatch_async(dispatch_get_main_queue(), ^{
                  failureHandler(nil, error);
              });
          }
          
      }] resume];
}

- (void)createUserWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email
                              andPassword:(NSString *)password  withCompletionHandler:(void (^)(NSMutableDictionary *, NSError *))completionHandler
                       withFailureHandler:(void (^)(NSMutableDictionary *, NSError *))failureHandler {
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    NSString *urlStr;
    
    self.configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    self.configuration.HTTPShouldSetCookies = YES;
    
    urlStr = [NSString stringWithFormat:@"%@/api/signup", self.appURL];
    
    //prepare post data
    NSURL *signUpURL = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:signUpURL];
    
    NSString *post = [NSString stringWithFormat:@"f_name=%@&l_name=%@&password=%@&email=%@&type=%@",
                      firstName,
                      lastName,
                      password,
                      email,
                      @"signup"];
    
    post = [post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    [request setHTTPBody:postData];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPShouldHandleCookies = YES;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.configuration];
    session.configuration.HTTPCookieStorage.cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways ;
    session.configuration.HTTPShouldSetCookies = YES;
    
    [[session dataTaskWithRequest:request completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error)
      {
          if (!error) {
              NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
              self.cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[httpResp allHeaderFields] forURL:[response URL]];
              [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:self.cookies forURL:[request URL] mainDocumentURL:[request mainDocumentURL]];
              
              NSDictionary *fields = [httpResp allHeaderFields];
              self.cookie = [fields valueForKey:@"Set-Cookie"];
              self.cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
              [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:self.cookies forURL:[request URL] mainDocumentURL:[request mainDocumentURL]];
              
              for (NSHTTPCookie *cookie in self.cookies)
              {
                  NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
                  [cookieProperties setObject:cookie.name forKey:NSHTTPCookieName];
                  [cookieProperties setObject:cookie.value forKey:NSHTTPCookieValue];
                  [cookieProperties setObject:cookie.domain forKey:NSHTTPCookieDomain];
                  [cookieProperties setObject:cookie.path forKey:NSHTTPCookiePath];
                  [cookieProperties setObject:[NSNumber numberWithUnsignedInteger:cookie.version] forKey:NSHTTPCookieVersion];
                  
                  [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:86400] forKey:NSHTTPCookieExpires];
                  
                  NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
                  [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                  [self.configuration.HTTPCookieStorage setCookie:cookie];
              }
              self.configuration.HTTPAdditionalHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:self.cookies];
              dispatch_async(dispatch_get_main_queue(), ^{
                  NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                  NSMutableDictionary *responseDict = [responseStr JSONValue];
                  completionHandler (responseDict, error);
              });
          }
          else
          {
              NSLog(@"%@", error);
              dispatch_async(dispatch_get_main_queue(), ^{
                  failureHandler(nil, error);
              });
          }
          
      }] resume];
}

- (void)makeSavePhotoCallWithDetails:(NSDictionary *)imageDictionary withCompletionHandler:(void (^)(NSMutableDictionary *, NSError *))completionHandler withFailureHandler:(void (^)(NSMutableDictionary *, NSError *))failureHandler {
 
    NSString *urlStr;
    
    //remove http/https if it's already there
    
    urlStr = [NSString stringWithFormat:@"%@/api/set_photo", self.appURL];
    
    NSMutableString *post = [[NSMutableString alloc] init];
    [post appendFormat:@"img_id=%@", [imageDictionary objectForKey:@"imageId"]];                     // Image Id
    
    if ([imageDictionary objectForKey:@"creationDate"])
        [post appendFormat:@"&c_date=%@", [imageDictionary objectForKey:@"creationDate"]];           // Creation Date
    
    if ([imageDictionary objectForKey:@"modificationDate"])
        [post appendFormat:@"&m_date=%@", [imageDictionary objectForKey:@"modificationDate"]];       // Modification Date
    
    if ([imageDictionary objectForKey:@"latitude"])
        [post appendFormat:@"&lat=%@", [imageDictionary objectForKey:@"latitude"]];                  // Latitude
    
    if ([imageDictionary objectForKey:@"longitude"])
        [post appendFormat:@"&lat=%@", [imageDictionary objectForKey:@"longitude"]];                 // Longitude
    
    if ([imageDictionary objectForKey:@"size"])
        [post appendFormat:@"&size=%@", [imageDictionary objectForKey:@"size"]];                     // Size
    
    if ([imageDictionary objectForKey:@"pixelHeight"])
        [post appendFormat:@"&p_height=%@", [imageDictionary objectForKey:@"pixelHeight"]];          // Pixel Height
    
    if ([imageDictionary objectForKey:@"pixelWidth"])
        [post appendFormat:@"&p_width=%@", [imageDictionary objectForKey:@"pixelWidth"]];            // Pixel Width

    post = [post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:self.cookie forHTTPHeaderField:@"COOKIE"];
    [self.configuration setHTTPAdditionalHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:self.cookies]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.configuration];
    
    [session.configuration setHTTPAdditionalHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:self.cookies]];
    
    [[session dataTaskWithRequest:request completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          dispatch_async(dispatch_get_main_queue(), ^{
              if(error) {
                  failureHandler (nil, error);
              }
              else {
                  NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];                  
                  completionHandler([responseStr JSONValue], nil);
              }
          });
      }] resume];
}

- (void)getImageDetailsForImageId:(NSString *)imageId withCompletionHandler:(void (^)(NSMutableDictionary *, NSError *))completionHandler withFailureHandler:(void (^)(NSMutableDictionary *, NSError *))failureHandler {
 
    NSString *urlStr;
    //imageId = @"131254";
    
    urlStr = [NSString stringWithFormat:@"%@/api/get_photo", self.appURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"POST"];

    if (imageId) {
        NSString *post = [[NSString stringWithFormat:@"img_id=%@", imageId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        [request setHTTPBody:postData];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    }
    
    [request setValue:self.cookie forHTTPHeaderField:@"Cookie"];
    [self.configuration setHTTPAdditionalHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:self.cookies]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.configuration];
    
    [session.configuration setHTTPAdditionalHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:self.cookies]];
    
    [[session dataTaskWithRequest:request completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          dispatch_async(dispatch_get_main_queue(), ^{
              if(error) {
                  failureHandler (nil, error);
              }
              else
              {
                  NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                  completionHandler([responseStr JSONValue], nil);
              }
          });
      }] resume];

}

-(void)logoutWithCompletionHandler:(void (^)(NSMutableDictionary *, NSError *))completionHandler withFailureHandler:(void (^)(NSMutableDictionary *, NSError *))failureHandler
{
    NSString *urlStr;
    urlStr = [NSString stringWithFormat:@"%@/api/logout", self.appURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:self.cookie forHTTPHeaderField:@"Cookie"];
    [self.configuration setHTTPAdditionalHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:self.cookies]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.configuration];
    
    [session.configuration setHTTPAdditionalHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:self.cookies]];
    
    [[session dataTaskWithRequest:request completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          dispatch_async(dispatch_get_main_queue(), ^{
              if(error) {
                  failureHandler (nil, error);
              }
              else
              {
                  NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                  completionHandler([responseStr JSONValue], nil);
              }
          });
      }] resume];
    
}

-(void)deletePhotoWithPhotosList:(NSMutableArray*)photosList WithCompletionHandler:(void (^)(NSMutableDictionary *, NSError *))completionHandler withFailureHandler:(void (^)(NSMutableDictionary *, NSError *))failureHandler
{
    NSString *urlStr;
    urlStr = [NSString stringWithFormat:@"%@/api/delete_photos", self.appURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"POST"];
    
    if (photosList) {

        NSMutableArray *arrIds = [[NSMutableArray alloc] init];
        
        for (NSMutableDictionary *dic in photosList) {
            NSString *strId = [dic objectForKey:@"id"];
            [arrIds addObject:strId];
        }
        
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setObject:arrIds forKey:@"keys"];
        
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:dicParam options:0 error:&error];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        [request setHTTPBody:postData];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }
    
    [request setValue:self.cookie forHTTPHeaderField:@"Cookie"];
    [self.configuration setHTTPAdditionalHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:self.cookies]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.configuration];
    
    [session.configuration setHTTPAdditionalHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:self.cookies]];
    
    [[session dataTaskWithRequest:request completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          dispatch_async(dispatch_get_main_queue(), ^{
              if(error) {
                  failureHandler (nil, error);
              }
              else
              {
                  NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                  completionHandler([responseStr JSONValue], nil);
              }
          });
      }] resume];
}

@end
