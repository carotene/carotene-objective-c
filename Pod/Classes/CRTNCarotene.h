//
//  CRTNCarotene.h
//  Pods
//
//  Created by Nacho Martin on 24/11/15.
//
//

#ifndef Pods_CRTNCarotene_h
#define Pods_CRTNCarotene_h

@class CRTNCarotene;

#pragma mark - CRTNCaroteneDelegate

@protocol CRTNCaroteneDelegate;

#pragma mark - CRTNCaroteneDelegate

@protocol CRTNCaroteneDelegate <NSObject>

// message will either be an NSString if the server is using text
// or NSData if the server is using binary.
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;

@optional

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;

@end


#endif
