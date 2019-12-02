# Pushdy

[![Version](https://img.shields.io/cocoapods/v/PushdySDK.svg?style=flat)](https://cocoapods.org/pods/PushdySDK)
[![License](https://img.shields.io/cocoapods/l/PushdySDK.svg?style=flat)](https://cocoapods.org/pods/PushdySDK)
[![Platform](https://img.shields.io/cocoapods/p/PushdySDK.svg?style=flat)](https://cocoapods.org/pods/PushdySDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Swift >= 4.2

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


```swift
// Swift language
Pushdy.getDeviceToken()
```

```objc
// Objective-C language
[Pushdy getDeviceToken];
```


- checkNotificationEnabling

Check allowing notification or not


```swift
// Swift language
Pushdy.checkNotificationEnabling { (enabled:Bool) in

}
```

```objc
// Objective-C language
[Pushdy checkNotificationEnabling:^(BOOL enabled) {
        
}];
```


- setDeviceID

Using your device id instead of Pushdy device id

```swift
// Swift language
let yourDeviceID = ...
Pushdy.setDeviceID(yourDeviceID)
```

```objc
// Objective-C language
NSString* yourDeviceID = ...;
[Pushdy setDeviceID:yourDeviceID];
```


- getPendingNotification

Get pending notification which is not handled

```swift
// Swift language
Pushdy.getPendingNotification()
```

```objc
// Objective-C language
[Pushdy getPendingNotification];
```

- setAttribute

Set value for an attribute. You can set "commitImmediately" variable  to true to commit your value immediately.

```swift
// Swift language
try? Pushdy.setAttribute("", value: "") 

// Equivalent to
try? Pushdy.setAttribute("network_carrier", value: "your_network_carrier", commitImmediately: false)
```

```objc
// Objective-C language
[Pushdy setAttribute:@"network_carrier" value:@"your_network_carrier" error:nil];

// Equivalent to
[Pushdy setAttribute:@"network_carrier" value:@"your_network_carrier" commitImmediately:FALSE error:nil];
```

- pushAttribute

Push value into a type of array attributer. You can set "commitImmediately" variable  to true to commit your value immediately.

```swift
// Swift language
let books:[String] = [
"book_1",
"book_2"
]
try? Pushdy.pushAttribute("bought_books", value: books)

// Equivalent to
try? Pushdy.pushAttribute("bought_books", value: books, commitImmediately: false)
```

```objc
// Objective-C language

NSArray *books = @[@"book_1", @"book_2"];
[Pushdy pushAttribute:@"bought_books" value:books error:nil];

// Equivalent to
[Pushdy pushAttribute:@"bought_books" value:books commitImmediately:FALSE error:nil];
```

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


-readyForHandlingNotification :

Determine that the application can handle push notification or not. Default is true. 
If false, incoming push will be pushed to pending notifications and you can process pending notifications later.

```swift
// Swift language
func readyForHandlingNotification() -> Bool {
    var already = true
    // Example: already = pass through login or tutorial/introdution screen
    return already
}
```

```objc
// Objective-C language
- (BOOL)readyForHandlingNotification {
    BOOL already = YES;
    // Example: already = pass through login or tutorial/introduction screen
    return already;
}
```


-onNotificationReceived:fromState :

When the application received a notification, Pushdy will trigger this method.

```swift
// Swift language
func onNotificationReceived(_ notification: [String : Any], fromState: String) {
        if fromState == "not_running" {
            // Example: is_app_launched_from_push = true
        }
        else if fromState == "active" {
            // Example: Play a sound to notitfy user
        }
        else if fromState == "inactive" {
            // Example: Play a sound to notitfy user
        }
        else if fromState == "background" {
            
        }
    }
```

```objc
// Objective-C language
- (void)onNotificationReceived:(NSDictionary<NSString *,id> *)notification fromState:(NSString *)fromState {
    if ([fromState isEqualToString:@"not_running"]) {
        // Example: is_app_launched_from_push = true
    }
    else if ([fromState isEqualToString:@"active"]) {
        // Example: Play a sound to notitfy user
    }
    else if ([fromState isEqualToString:@"inactive"]) {
        // Example: Play a sound to notitfy user
    }
    else if ([fromState isEqualToString:@"background"]) {

    }
}
```


-onNotificationOpened:fromState :

When user tap push notification banner (system notification or in app notification banner), Pushdy will trigger this method.

```swift
// Swift language
func onNotificationOpened(_ notification: [String : Any], fromState: String) {
     // Handle notification
}
```

```objc
// Objective-C language
- (void)onNotificationOpened:(NSDictionary<NSString *,id> *)notification fromState:(NSString *)fromState {
    // Handle notification
}
```


And some other delegate methods...

**Customize In App Notification Banner**

We use PDYNotificationView view for default displaying in app push notification.
Pushdy also provides some method to adjust default notification view and set your custom view.

- setPushBannerAutoDismiss :

Turn on/off auto dismiss for in app notification banner.

```swift
// Swift language
Pushdy.setPushBannerAutoDismiss(true)
```

```objc
// Objective-C language
[Pushdy setPushBannerAutoDismiss:TRUE];
```


- setPushBannerDismissDuration : 

Set auto dismiss duration for default custom view.

```swift
// Swift language
Pushdy.setPushBannerDismissDuration(5) // 5 seconds
```

```objc
// Objective-C language
[Pushdy setPushBannerDismissDuration:5]; // 5 seconds
```


- setCustomPushBanner :

Set custom notification banner view. Implementating PDYPushBannerActionProtocol protocol is required.

```swift
// Swift language
let yourCustomView = ...
Pushdy.setCustomPushBanner(yourCustomView)
```

```objc
// Objective-C language
UIView* yourCustomView = ...
[Pushdy setCustomPushBanner:yourCustomView];
```

*** Note: 

Pushdy SDK use `_nms_image` key for displaying thumbnail image from json push payload as default.
```ruby
{
   "aps" : {
        ...
   },
   "_nms_image" : "https://domain.com/path/image.png"
}
```

If you want to custom your own key, use setCustomMediaKey method for override it.
```swift
// Swift language
PDYNotificationView.setCustomMediaKey("your_custom_media_key")
```

```objc
// Objective-C language
[PDYNotificationView setCustomMediaKey:@"your_custom_media_key"];
```


## Author

Pushdy Team, contact@pushdy.com

## License

Pushdy is available under the MIT license. See the LICENSE file for more info.
