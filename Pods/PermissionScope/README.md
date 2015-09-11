# PermissionScope 🔐🔭

![iOS 8+](https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat
) [![Language](https://img.shields.io/badge/language-swift2-f48041.svg?style=flat
)](https://developer.apple.com/swift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Cocoapods compatible](https://cocoapod-badges.herokuapp.com/v/PermissionScope/badge.png)](https://cocoapods.org/pods/PermissionScope)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)

Inspired by (but unrelated to) [Periscope](https://www.periscope.tv)'s permission control, PermissionScope is a Swift framework for intelligently requesting permissions from users. **It contains not only a simple UI to request permissions but also a unified permissions API** that can tell you the status of any given system permission or easily request them.

Some examples of multiple permissions requests, a single permission and the denied alert.

<img src="http://raquo.net/images/permissionscope.gif" alt="permissionscope gif" />

We should all be more careful about when we request permissions from users, opting to request them only when they're needed and definitely not all in one barrage when the user opens the app for the first time.

PermissionScope gives you space to explain your reasons for requesting their precious permissions and allows users to tackle the system dialogs at their own pace. It conforms to (what I hope will be) a standard permissions design but is flexible enough to fit in to most UIKit-based apps.

Best of all, PermissionScope detects when your app's permissions have been denied by a user and gives them an easy prompt to go into the system settings page to modify these permissions.

## Table of Contents
* [Installation](https://github.com/nickoneill/PermissionScope/#installation)
* [Dialog Usage](https://github.com/nickoneill/PermissionScope/#dialog-usage)
* [UI Customization](https://github.com/nickoneill/PermissionScope/#ui-customization)
* [Unified Permissions API](https://github.com/nickoneill/PermissionScope/#unified-permissions-api)
* [Issues](https://github.com/nickoneill/PermissionScope/#issues)
* [Extra Requirements for Permissions](https://github.com/nickoneill/PermissionScope/#extra-requirements-for-permissions)
* [Projects using PermissionScope](https://github.com/nickoneill/PermissionScope/#projects-using-permissionscope)
* [License](https://github.com/nickoneill/PermissionScope/#license)


## installation

requires iOS 8+

Installation for [Carthage](https://github.com/Carthage/Carthage) is simple enough:

`github "nickoneill/PermissionScope" ~> 0.7`

As for [Cocoapods](https://cocoapods.org), use this to get the latest code:

```ruby
use_frameworks!

pod 'PermissionScope', '~> 0.7'
```

And `import PermissionScope` in the files you'd like to use it.

No promises that it works with Obj-C at the moment, I'm using it with a mostly-Swift codebase. Feedback on this would be great though.

## dialog usage

The simplest implementation displays a list of permissions and is removed when all of them have satisfactory access.

```swift
class ViewController: UIViewController {
    let pscope = PermissionScope()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up permissions
         pscope.addPermission(ContactsPermission(),
            message: "We use this to steal\r\nyour friends")
        pscope.addPermission(NotificationsPermission(notificationCategories: nil),
            message: "We use this to send you\r\nspam and love notes")
        pscope.addPermission(LocationWhileInUsePermission(),
            message: "We use this to track\r\nwhere you live")
	
	// Show dialog with callbacks
        pscope.show(authChange: { (finished, results) -> Void in
            println("got results \(results)")
        }, cancelled: { (results) -> Void in
            println("thing was cancelled")
        })   
    }
}
```

The permissions view will automatically show if there are permissions to approve and will take no action if permissions are already granted. It will automatically hide when all permissions have been approved.

If you're attempting to block access to a screen in your app without permissions (like, say, the broadcast screen in Periscope), you should watch for the cancel closure and take an appropriate action for your app.

### ui customization

You can easily change the colors, label and buttons fonts with PermissionScope by modifying any of these properties:

Field | Type | Comment
----- | ---- | -------
headerLabel | UILabel | Header UILabel with the message "Hey, listen!" by default.
bodyLabel | UILabel | Header UILabel with the message "We need a couple things\r\nbefore you get started." by default.
closeButtonTextColor | UIColor | Color for the close button's text color.
permissionButtonTextColor  | UIColor | Color for the permission buttons' text color.
permissionButtonBorderColor | UIColor | Color for the permission buttons' border color.
buttonFont | UIFont | Font used for all the UIButtons
labelFont | UIFont | Font used for all the UILabels
closeButton | UIButton | Close button. By default in the top right corner.
closeOffset | CGSize | Offset used to position the Close button.
authorizedButtonColor | UIColor | Color used for permission buttons with authorized status
unauthorizedButtonColor | UIColor? | Color used for permission buttons with unauthorized status. By default, inverse of `authorizedButtonColor`.
permissionButtonΒorderWidth | CGFloat | Border width for the permission buttons.
permissionButtonCornerRadius | CGFloat | Corner radius for the permission buttons.
permissionLabelColor | UIColor | Color for the permission labels' text color.
contentView | UIView | Dialog's content view

In addition, the default behavior for tapping the background behind the dialog is to cancel the dialog (which calls the cancel closure you can provide on `show`). You can change this behavior with `backgroundTapCancels` during init.

If you'd like more control over the button text for a particular permission, you can [use a `.strings` file](https://github.com/nickoneill/PermissionScope/pull/12#issuecomment-96428580) for your intended language and override them that way. Please get in touch if you'd like to contribute a localization file for another language!

## unified permissions API

PermissionScope also has an abstracted API for getting the state for a given permission and requesting permissions if you need to do so outside of the normal dialog UI. Think of it as a unified iOS permissions API that can provide some features that even Apple does not (such as detecting denied notification permissions).

```swift
switch PermissionScope().statusContacts() {
case .Unknown:
    // ask
    PermissionScope().requestContacts()
case .Unauthorized, .Disabled:
    // bummer
    return
case .Authorized:
    // thanks!
    return
}
```

### calling `request*` methods directly

Normally PermissionScope is used to walk users through necessary permissions before they're allowed to do something in your app. Sometimes you may wish to instead call into the various `request*` permissions-seeking methods of PermissionScope directly, from your own UI.

To call these methods directly, you must first set the `viewControllerForAlerts` method to your current UIViewController, in case PermissionScope needs to present some alerts to the user for denied or disabled permissions:

```swift
let pscope = PermissionScope()
pscope.viewControllerForAlerts = self
```

You will probably also want to set the `authChangeClosure`, `cancelClosure`, and `disabledOrDeniedClosure` closures, which are called at the appropriate times when the `request*` methods are finished, otherwise you won't know when the work has been completed.

```swift
pscope.authChangeClosure = { (finished, results) -> Void in
	println("Request was finished with results \(results)")
	if results[0].status == .Authorized {
		println("They've authorized the use of notifications")
		UIApplication.sharedApplication().registerForRemoteNotifications()
	}
}
pscope.cancelClosure = { (results) -> Void in
	println("Request was cancelled with results \(results)")
}
pscope.disabledOrDeniedClosure = { (results) -> Void in
	println("Request was denied or disabled with results \(results)")
}
```

And then you might call it when the user toggles a switch:

```swift
@IBAction func notificationsChanged(sender: UISwitch) {
	if sender.on {
		// turn on notifications
		if PermissionScope().statusNotifications() == .Authorized {
			UIApplication.sharedApplication().registerForRemoteNotifications()
		} else {
			pscope.requestNotifications()
		}
	} else {
	    // turn off notifications
	}
```
If you're also using PermissionScope in the traditional manner, don't forget to set viewControllerForAlerts back to it's default, the instance of PermissionScope. The easiest way to do this is to set it explicitly before you call a `request*` method, and then reset it in your closures.

```swift
pscope.viewControllerForAlerts = pscope as UIViewController
```

## issues

* You get `Library not loaded: @rpath/libswiftCoreAudio.dylib`, `image not found` errors when your app runs:

PermissionScope imports CoreAudio to request microphone access but it's not automatically linked in if your app doesn't `import CoreAudio` somewhere. I'm not sure if this is a bug or a a quirk of how CoreAudio is imported. For now, if you `import CoreAudio` in your top level project it should fix the issue.

### beta
We're using PermissionScope in [treat](https://gettre.at) and fixing issues as they arise. Still, there's definitely some beta-ness around and the API can change without warning. Check out what we have planned in [issues](http://github.com/nickoneill/PermissionScope/issues) and contribute a suggestion or some code 😃

### PermissionScope registers user notification settings, not remote notifications
Users will get the prompt to enable notifications when using PermissionScope but it's up to you to watch for results in your app delegate's `didRegisterUserNotificationSettings` and then register for remote notifications independently. This won't alert the user again. You're still responsible for handling the shipment of user notification settings off to your push server.

## extra requirements for permissions

### location 
**You must set these Info.plist keys for location to work**

Trickiest part of implementing location permissions? You must implement the proper key in your Info.plist file with a short description of how your app uses location info (shown in the system permissions dialog). Without this, trying to get location  permissions will just silently fail. *Software*!

Use `NSLocationAlwaysUsageDescription` or `NSLocationWhenInUseUsageDescription` where appropriate for your app usage. You can specify which of these location permissions you wish to request with `.LocationAlways` or `.LocationInUse` while configuring PermissionScope.

### bluetooth

The *NSBluetoothPeripheralUsageDescription* key in the Info.plist specifying a short description of why your app needs to act as a bluetooth peripheralin the background is **optional**.

However, enabling `background-modes` in the capabilities section and checking the `acts as a bluetooth LE accessory` checkbox is **required**.

### healthkit

Enable `HealthKit` in your target's capabilities, **required**.

### cloudkit

Enable `CloudKit` in your target's capabilities, **required**.

Also, remember to add an observer and manage [CKAccountChangedNotification](https://developer.apple.com/library/prerelease/ios/documentation/CloudKit/Reference/CKContainer_class/#//apple_ref/c/data/CKAccountChangedNotification) in your app.

## projects using PermissionScope

Feel free to add your project in a PR if you're using PermissionScope:

<img src="http://raquo.net/images/icon-round-80.png" width="40" height="40" /><br />
<a href="https://gettre.at">treat</a>

## license

PermissionScope uses the MIT license. Please file an issue if you have any questions or if you'd like to share how you're using this tool.
