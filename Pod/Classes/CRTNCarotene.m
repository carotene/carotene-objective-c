//
//  CRTNCarotene.m
//  Pods
//
//  Created by Nacho Martin on 24/11/15.
//
//

#import <Foundation/Foundation.h>
#import "CRTNCarotene.h"
#import <SocketRocket/SRWebSocket.h>


@interface CRTNCarotene () <SRWebSocketDelegate>
@property (nonatomic, copy) NSString *socketID;
@property (nonatomic, assign) NSString *state;
@end

@implementation CRTNCarotene {
    SRWebSocket *socket;
}

-(id)init:(NSURLRequest *)host {
    socket.delegate = nil;
    [socket close];
    
    socket = [[SRWebSocket alloc] initWithURLRequest:host];
    socket.delegate = self;
    
    [socket open];
    return self;
}

-(void)publish:(NSObject *)data channel:(NSString *)channelName
{
    NSError *error;
    
    NSData *jsonDataTxt  = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
    NSString *msgTxt = [[NSString alloc] initWithData:jsonDataTxt encoding:NSUTF8StringEncoding];
    
    NSDictionary *dictionary = @{
                                 @"publish" : msgTxt,
                                 @"channel" : @"chat"
                                 
                                 };
    
    NSData       *jsonData  = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *msg = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [socket send:msg];
}

- (void)dealloc
{
    [socket setDelegate:nil];
    [socket close];
}


@end