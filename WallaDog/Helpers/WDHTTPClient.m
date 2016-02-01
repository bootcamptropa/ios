//
//  WDHTTPClient.m
//  WallaDog
//
//  Created by Fernando Luna on 12/22/15.
//  Copyright © 2015 Dancing Queen. All rights reserved.
//
//#import <AFOAuth2Manager/AFOAuth2Manager.h>
//#import <AFOAuth2Manager/AFHTTPRequestSerializer+OAuth2.h>

@import AFOAuth2Manager;

#import "WDHTTPClient.h"

#define URL_BASE_WALLADOG @"http://api.walladog.com/"
#define CLIENT_ID_WALLADOG @"uEAoxVEYOVmpg4Z8IAyCCEItlXO8Cf4G7RSu647d"
#define SECRET_WALLADOG @"Zc0JGu5pVUt7zNxrhQaCvit6ydr4WxMVI4nXluF9GBWgJV0rbUcR5y2uBZl3TgmLYryashJREp9AiIkbfRUVv5Cdd3n6ZX4Va3fI2cmvMwcgWRFYnrp7K8ZtwkopXrhV"
#define KEY_SAVE_TOKEN @"KEY_SAVE_TOKEN"


@interface WDHTTPClient ()

@property(nonatomic) BOOL isAutentification;

@end


@implementation WDHTTPClient

+ (WDHTTPClient *)sharedWDHTTPClient
{
    static WDHTTPClient *_sharedWeatherHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWeatherHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:URL_BASE_WALLADOG]];
    });
    
    return _sharedWeatherHTTPClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    if (self = [super initWithBaseURL:url]) {
        _isAutentification = NO;
        [self configureAFNetworking];
        [self loadAuthentication];
    }
    
    return self;
}

- (void)configureAFNetworking {
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
}

- (void)loadAuthentication {
    AFOAuthCredential *credential = [AFOAuthCredential retrieveCredentialWithIdentifier:KEY_SAVE_TOKEN];
    if(credential != nil) {
        [self.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
        self.isAutentification = YES;
    }
}

-(NSURLSessionDataTask *) loadProductsWithLocationCoordinate:(CLLocationCoordinate2D) locationCoordinate
                                                filterRaceId:(NSInteger) filterRaceId
                                            filterCategoryId:(NSInteger) filterCategoryId
                                               filterStateId:(NSInteger) filterStateId
                                                  filterName:(NSString*) filterName
                                                     success:(void (^)(id responseObject))success
                                                     failure:(void (^)(NSString *errorDescripcion))failure {
    
    NSMutableDictionary *parametersFilters = [NSMutableDictionary dictionary];
    
    if (![filterName isEqualToString:@""])
        [parametersFilters setObject:filterName forKey:@"name"];
    
    if (CLLocationCoordinate2DIsValid(locationCoordinate)
        && locationCoordinate.latitude != 0
        && locationCoordinate.longitude != 0) {
        [parametersFilters setObject:@(locationCoordinate.latitude) forKey:@"lat"];
        [parametersFilters setObject:@(locationCoordinate.longitude) forKey:@"lon"];
    }
    if (filterCategoryId != 0)
        [parametersFilters setObject:@(filterCategoryId) forKey:@"category"];
    
    if (filterRaceId != 0)
        [parametersFilters setObject:@(filterRaceId) forKey:@"race"];
    
    if (filterStateId != 0)
        [parametersFilters setObject:@(filterStateId) forKey:@"state"];
    
    [parametersFilters setObject:@(20) forKey:@"limit"];
    [parametersFilters setObject:@(0) forKey:@"offset"];
    
    return [self GET:@"/api/1.0/products/" parameters:parametersFilters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success([responseObject objectForKey:@"results"]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        id response = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSString *myStringError = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        failure(myStringError);
    }];
}

-(void) getCategoriesSuccess:(void (^)(id responseObject))success
                     failure:(void (^)(NSString *errorDescripcion))failure {
    
    NSMutableDictionary *parametersFilters = [NSMutableDictionary dictionary];
    [parametersFilters setObject:@(20) forKey:@"limit"];
    [parametersFilters setObject:@(0) forKey:@"offset"];
    
    [self GET:@"/api/1.0/categories/" parameters:parametersFilters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success([responseObject objectForKey:@"results"]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        id response = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSString *myStringError = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        failure(myStringError);
    }];
}


-(void) getCurrentUserSuccess:(void (^)(id responseObject))success
                      failure:(void (^)(NSString *errorDescripcion))failure {
    
    
    [self GET:@"/api/1.0/logins/" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        id response = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSString *myStringError = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        failure(myStringError);
    }];
}

-(void) signUpWithUserName:(NSString*)userName
                     email:(NSString*)email
                  password:(NSString*)password
                   success:(void (^)(id responseObject))success
                   failure:(void (^)(NSString *errorDescripcion))failure {
    
    NSDictionary *parameters = @{@"username":userName,
                                 @"email":email,
                                 @"password":password};
    
    [self POST:@"/api/1.0/users/" parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        id response = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSString *myStringError = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        failure(myStringError);
    }];
}

- (void)loginAndobtainAuthorizationTokenWithUserName:(NSString*)userName
                                            password:(NSString*)password
                                     complitionBLock:(void(^)())complitionBLock
                                     complitionError:(void(^)(NSString* error))complitionError {
    
    AFOAuth2Manager *OAuth2Manager =
    [[AFOAuth2Manager alloc] initWithBaseURL:[NSURL URLWithString:URL_BASE_WALLADOG]
                                    clientID:CLIENT_ID_WALLADOG
                                      secret:SECRET_WALLADOG];
    
    [OAuth2Manager authenticateUsingOAuthWithURLString:@"/o/token/"
                                              username:userName
                                              password:password
                                                 scope:@"read write"
                                               success:^(AFOAuthCredential *credential) {
                                                   [AFOAuthCredential storeCredential:credential
                                                                       withIdentifier:KEY_SAVE_TOKEN];
                                                   [self.requestSerializer setAuthorizationHeaderFieldWithCredential:credential];
                                                   self.isAutentification = YES;
                                                   complitionBLock();
                                               }
                                               failure:^(NSError *error) {
                                                   complitionError(error.localizedDescription);
                                               }];
    
}


- (void)removeAuthorization {
    self.isAutentification = NO;
    [AFOAuthCredential deleteCredentialWithIdentifier:KEY_SAVE_TOKEN];
}

@end