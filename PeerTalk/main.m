//
//  main.m
//  PeerTalk
//
//  Created by Troy Manchester on 9/19/22.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([MCAppDelegate class]);
    }
    
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
