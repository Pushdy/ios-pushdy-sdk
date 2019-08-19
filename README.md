# Pushdy

[![Version](https://img.shields.io/cocoapods/v/PushdySDK.svg?style=flat)](https://cocoapods.org/pods/PushdySDK)
[![License](https://img.shields.io/cocoapods/l/PushdySDK.svg?style=flat)](https://cocoapods.org/pods/PushdySDK)
[![Platform](https://img.shields.io/cocoapods/p/PushdySDK.svg?style=flat)](https://cocoapods.org/pods/PushdySDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Pushdy is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PushdySDK'
```

## Usage
**Initialization**

In application:didFinishLaunchingWithOptions method, initialize Pushdy SDK as below:

Swift language:
```swift
let clientKey = "your client key from Pushdy application"
Pushdy.initWith(clientKey: clientKey, delegate: self, launchOptions: launchOptions)
```

Objective-C language:
```objc
NSString *clientKey = @"your client key from Pushdy application";
[Pushdy initWithClientKey:clientKey delegate:self launchOptions:launchOptions];
```

Then you can call registerForPushNotifications method to register receiving push notification.
Swift language:
```swift
Pushdy.registerForPushNotifications()
```
Objective-C language:
```objc
[Pushdy registerForPushNotifications];
```

**Pushdy Delegation**

For listen the Pushdy callback and adapt your logic with Pushdy, you must implement PushdyDelegate in your App Delegate

Swift language:
```swift
import PushdySDK
class AppDelegate: UIResponder, UIApplicationDelegate, PushdyDelegate {

}
```

Objective-C language:
```objc
#import <PushdySDK/PushdySDK-Swift.h> // You must generate brigde header first
@interface AppDelegate : UIResponder <UIApplicationDelegate, PushdyDelegate> {
  
}
```

**pushdyHasAlreadyForHandlingNotification**

Determine that the application can handle push notification or not. Default is true. 
If false, incoming push will be pushed to pending notifications and you can process pending notifications later.

**onReceivedNotification:fromState**

When the application received a notification, Pushdy will trigger this method.

**onNotificationOpened:fromState**

When user tap push notification banner (system notification or in app notification banner), Pushdy will trigger this method.

## Author

Pushdy Team, contact@pushdy.com

## License

Pushdy is available under the MIT license. See the LICENSE file for more info.
