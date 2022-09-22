//
//  ViewController.h
//  PeerTalk
//
//  Created by Troy Manchester on 9/19/22.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

// service name(s) for our app
// text chat
static NSString * const ptChatServiceType = @"peertalk-text";
// TODO: implement audio streaming!
//static NSString * const ptVoiceServiceType = @"peertalk-voice";

@interface ViewController : UIViewController <UIApplicationDelegate, /*MCAdvertiserAssistantDelegate*/MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate>


@end

