//
//  CRTNCarotene.h
//  Pods
//
//  Created by Nacho Martin on 24/11/15.
//
//

#ifndef Pods_CRTNCarotene_h
#define Pods_CRTNCarotene_h

@interface CRTNCarotene : NSObject

- (id)init:(NSURLRequest *)host;

- (void)connect;

- (void)disconnect;

- (void)publish:(NSObject *)data channel:(NSString *)channelName;

- (void)subscribe:(NSString *)channelName handleWithBlock:(void (^)(NSString *))block;

@end

#endif
