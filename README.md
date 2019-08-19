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

**Import**

Import module in Swift language:
```swift
import PushdySDK
```

Import module in Objective-C language (You must generate brigde header to support Swift first):
```objc
#import <PushdySDK/PushdySDK-Swift.h>
```

**Initialization**

In application:didFinishLaunchingWithOptions method, initialize Pushdy SDK as below:

```swift
// Swift language
let clientKey = "your client key from Pushdy application"
Pushdy.initWith(clientKey: clientKey, delegate: self, launchOptions: launchOptions)
```

```objc
// Objective-C language
NSString *clientKey = @"your client key from Pushdy application";
[Pushdy initWithClientKey:clientKey delegate:self launchOptions:launchOptions];
```

Then you can call registerForPushNotifications method to register receiving push notification.

```swift
// Swift language
Pushdy.registerForPushNotifications()
```

```objc
// Objective-C language
[Pushdy registerForPushNotifications];
```

**Methods**

- getDeviceToken

Get device token from pushdy

- checkNotificationEnabling

Check allowing notification or not

- setDeviceID

Using your device id instead of Pushdy device id

- getPendingNotification

Get pending notification which is not handled

**Pushdy Delegation**

For listen the Pushdy callback and adapt your logic with Pushdy, you must implement PushdyDelegate in your App Delegate

```swift
// Swift language
import PushdySDK
class AppDelegate: UIResponder, UIApplicationDelegate, PushdyDelegate {

}
```

```objc
// Objective-C language
#import <PushdySDK/PushdySDK-Swift.h> // You must generate brigde header first
@interface AppDelegate : UIResponder <UIApplicationDelegate, PushdyDelegate> {
  
}
```

**pushdyHasAlreadyForHandlingNotification**

Determine that the application can handle push notification or not. Default is true. 
If false, incoming push will be pushed to pending notifications and you can process pending notifications later.

**pushdyOnReceivedNotification:fromState**

When the application received a notification, Pushdy will trigger this method.

**pushdyOnNotificationOpened:fromState**

When user tap push notification banner (system notification or in app notification banner), Pushdy will trigger this method.



## Author

Pushdy Team, contact@pushdy.com

## License

Pushdy is available under the MIT license. See the LICENSE file for more info.
