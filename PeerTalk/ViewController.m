//
//  ViewController.m
//  PeerTalk
//
//  Created by Troy Manchester on 9/19/22.
//

#import "ViewController.h"
#import "AudioToolbox/AudioToolbox.h"

@interface ViewController ()
@property (nonatomic, copy) MCPeerID *peerID;
@property (nonatomic, copy) MCSession *session;
@property (nonatomic, copy) MCNearbyServiceAdvertiser *advertiser;
//@property (nonatomic, copy) MCAdvertiserAssistant *advertiser;
@property (nonatomic, copy) MCBrowserViewController *browserViewController;
@property (nonatomic, copy) UIButton *sendDataButton;

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
    //TODO: try using advertiser assistant here instead..
    /*_advertiser =
        [[MCAdvertiserAssistant alloc] initWithServiceType:ptChatServiceType
                                       discoveryInfo:nil
                                       session:_session];
    _advertiser.delegate = self;
    [_advertiser start];*/

    _sendDataButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_sendDataButton setTitle:@"Send Data" forState:UIControlStateNormal];
    [_sendDataButton addTarget:self
                     action:@selector(sendDataToPeers)
                     forControlEvents:UIControlEventTouchUpInside];
    _sendDataButton.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
    [[self view] addSubview:_sendDataButton];
}

- (void)sendDataToPeers
{
    NSString *message = @"hello peer!";
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    if (![self.session sendData:data
                        toPeers:self.session.connectedPeers
                       withMode:MCSessionSendDataReliable
                          error:&error]) {
        NSLog(@"[Error] %@", error);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    // use Apple standard MC browser view controller.
    // apparently this needs to go in viewDidAppear not viewDidLoad...
    // check number of connected peers before showing service browser - otherwise the
    // service browser view will continually pop up!
    // TODO: add a way to re-invoke the service browser!
    if (_session.connectedPeers.count < 1)
    {
        _browserViewController =
            [[MCBrowserViewController alloc] initWithServiceType:ptChatServiceType session:_session];
        _browserViewController.delegate = self;
        [self presentViewController:_browserViewController
                           animated:YES
                         completion:nil];
    }
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

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session
           peer:(MCPeerID *)peerID
 didChangeState:(MCSessionState)state
{
    NSLog(@"session did change state...");
    // called when peer state changes - use to detect connection established
    if (state == MCSessionStateConnected)
    {
        NSString *message = @"Session connected!!";
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        // this seems really hacky - I only want to send to 1 peer so can't use session connectedPeers.
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
    
    // play a notification sound for now...
    AudioServicesPlaySystemSound(1003);
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
    [browserViewController dismissViewControllerAnimated:true completion: nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:true completion: nil];
}

@end
