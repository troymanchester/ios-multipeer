//
//  ViewController.m
//  PeerTalk
//
//  Created by Troy Manchester on 9/19/22.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, copy) MCPeerID *peerID;
@property (nonatomic, copy) MCSession *session;
@property (nonatomic, copy) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, copy) MCNearbyServiceBrowser *browser;
@property (nonatomic, copy) MCBrowserViewController *browserViewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // init all Multipeer Connectivity related stuff!
    // TODO: pull this into a helper class?
    
    // create a local peer ID
    _peerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    
    // create multipeer session
    _session = [[MCSession alloc] initWithPeer:_peerID
                                        securityIdentity:nil
                                    encryptionPreference:MCEncryptionNone];
    _session.delegate = self;
    
    // create service advertiser!
    _advertiser =
        [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID
                                          discoveryInfo:nil
                                            serviceType:ptChatServiceType];
    _advertiser.delegate = self;
    [_advertiser startAdvertisingPeer];
    
    // create service browser!
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID serviceType:ptChatServiceType];
    _browser.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    // use Apple standard MC browser view controller..
    // apparently this needs to go in viewDidAppear not viewDidLoad??
    _browserViewController =
        [[MCBrowserViewController alloc] initWithBrowser:_browser
                                                 session:_session];
    _browserViewController.delegate = self;
    [self presentViewController:_browserViewController
                       animated:YES
                     completion:
    ^{
        NSLog(@"Calling startBrowsingForPeers...");
        [self->_browser startBrowsingForPeers];
    }];
}

// TODO: Should be using MCAdvertiserAssistant instead??
#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID
       withContext:(NSData *)context
 invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    // accept the invitation!
    NSLog(@"accept invitation!");
    invitationHandler(true, _session);
}

#pragma mark - MCNearbyServiceBrowserDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser
      foundPeer:(MCPeerID *)peerID
withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info
{
    // called when a nearby device is found
    // invite peer to a session!
    NSLog(@"Invite peer to session!");
    [browser invitePeer:peerID toSession:_session withContext:nil timeout:10];
}

- (void)browser:(MCNearbyServiceBrowser *)browser
       lostPeer:(MCPeerID *)peerID
{
    // called when nearby device goes away! Probably no-op
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session
           peer:(MCPeerID *)peerID
 didChangeState:(MCSessionState)state
{
    NSLog(@"session did change state...");
    // called when peer state changes - use to detect connection established
    // TODO: actually cache the peer! Right now this just sends a message
    if (state == MCSessionStateConnected)
    {
        NSString *message = @"Session connected!!";
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        // this seems really hacky - I only want to send to 1 peer!
        MCPeerID* peers[] = {peerID};
        NSArray<MCPeerID*> *peerIDs= [NSArray arrayWithObjects:peers count:1];
        if (![self.session sendData:data
                            toPeers:peerIDs
                           withMode:MCSessionSendDataReliable
                              error:&error]) {
            NSLog(@"[Error] %@", error);
        }
    }
}

- (void)session:(MCSession *)session
 didReceiveData:(NSData *)data
       fromPeer:(MCPeerID *)peerID
{
    // called when data is received from peer - specifically small data chunks!
    NSString *message =
            [[NSString alloc] initWithData:data
                                  encoding:NSUTF8StringEncoding];
    NSLog(@"Message received from peer: %@", message);
}

- (void)session:(MCSession *)session
didReceiveStream:(NSInputStream *)stream
       withName:(NSString *)streamName
       fromPeer:(MCPeerID *)peerID
{
    // TODO: implement!
}

- (void)session:(MCSession *)session
didStartReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID
   withProgress:(NSProgress *)progress
{
    // no-op for now...
}

- (void)session:(MCSession *)session
didFinishReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID
          atURL:(NSURL *)localURL
      withError:(NSError *)error
{
    // no-op
}

# pragma mark - MCBrowserViewControllerDelegate

- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController
      shouldPresentNearbyPeer:(MCPeerID *)peerID
            withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info
{
    return YES;
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    NSLog(@"browser view controller did finish");
    [browserViewController dismissViewControllerAnimated:true completion: nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    NSLog(@"browser view controller was cancelled");
    [browserViewController dismissViewControllerAnimated:true completion: nil];
}

@end
