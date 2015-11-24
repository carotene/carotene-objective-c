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

#if OS_OBJECT_USE_OBJC_RETAIN_RELEASE
#define sr_dispatch_retain(x)
#define sr_dispatch_release(x)
#define maybe_bridge(x) ((__bridge void *) x)
#else
#define sr_dispatch_retain(x) dispatch_retain(x)
#define sr_dispatch_release(x) dispatch_release(x)
#define maybe_bridge(x) (x)
#endif


@interface CRTNCarotene () <SRWebSocketDelegate>
@property (nonatomic, copy) NSString *socketID;
@property (nonatomic, assign) NSString *state;
@property (nonatomic) dispatch_queue_t delegateDispatchQueue;
@end


@implementation CRTNCarotene {
    SRWebSocket *socket;
    NSMutableDictionary *subscriptions;
    dispatch_queue_t _delegateDispatchQueue;
}



-(id)init:(NSURLRequest *)host {
    subscriptions = [[NSMutableDictionary alloc] init];
    
    _delegateDispatchQueue = dispatch_get_main_queue();
    sr_dispatch_retain(_delegateDispatchQueue);
    
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

- (void)subscribe:(NSString *)channelName handleWithBlock:(void (^)(NSString *))block
{


    [subscriptions setObject:block forKey:channelName];
}

- (void)dealloc
{
    if (_delegateDispatchQueue) {
        sr_dispatch_release(_delegateDispatchQueue);
        _delegateDispatchQueue = NULL;
    }
    [socket setDelegate:nil];
    [socket close];
}

- (void) doSubscribe:(NSString *)channelName
{
    NSLog(@"Subcriptor for %@ ", channelName);
    
    NSError *error;
    NSDictionary *dictionary = @{
                                 @"subscribe" : channelName
                                 };
    
    NSData  *jsonData  = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *msg = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [socket send:msg];
}

- (void)dispatchToSubscribers:(NSString *)messageJson channelName:(NSString *)channel
{
    NSLog(@"Channel is %@ ", channel);

    void (^block)(NSString * ch) = [subscriptions objectForKey:channel];
    NSLog(@"Got a block ");

    assert(_delegateDispatchQueue);
    NSLog(@"Got a queue ");

    dispatch_async(_delegateDispatchQueue, ^{
        block(messageJson);
    });
    
}


#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    for (NSString* channelName in subscriptions) {
        [self doSubscribe:channelName];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    
    socket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)payload;
{
    NSLog(@"Received \"%@\"", payload);
    
    NSError *jsonError;
    //NSDictionary *jsonObject = [[NSArray alloc]init];
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[payload dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    
    NSLog(@"jsonDataArray: %@",jsonObject);
    
    if (jsonObject != nil) {
        NSString *typeStr = [jsonObject objectForKey:@"type"];
        NSArray *types = @[@"message", @"presence", @"info"];
        int type = (int)[types indexOfObject:typeStr];
        switch (type) {
            case 0:
                // message
                [self processMessage:jsonObject];
                break;
            case 1:
                // presence
                break;
            case 2:
                // info
                break;
            default:
                break;
        }
        
    }
    
    
}

-(void)processMessage:(NSDictionary *)jsonMessage
{
    NSString *messageRaw;
    NSLog(@"Got a message ");
    messageRaw = [jsonMessage objectForKey:@"message"];
    NSString *channelStr = [jsonMessage objectForKey:@"channel"];
    [self dispatchToSubscribers:messageRaw channelName:channelStr];
}


@end