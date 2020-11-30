# Keychain83 🔐

Simple utility for storing data in Apple's Keychain. 

Once the data is stored in the keychain it's persistent and secure even after deleting the app.

## Installation

### CocoaPods (iOS 10+)

You can use [CocoaPods](http://cocoapods.org/) to install `Keychain83` by adding it to your `Podfile`:

Add the following line to your `Podfile`.
```
pod 'Keychain83'
```

For example as follows:

```ruby
platform :ios, '10.0'
use_frameworks!

target 'MyApp' do
pod 'Keychain83'
end
```

You can provide direct path to the library:

```ruby
platform :ios, '10.0'
use_frameworks!

target 'MyApp' do
pod 'Keychain83', :git => 'https://github.com/seriyvolk83/keychain.git'
end
```

## Usage

```swift
let keychainUtility = Keychain(service: "My Keychain")

let key = "myAccount"

// Adding 🔑
keychainUtility[key] = "password123"

// Updating 🗝
keychainUtility[key] = "passwordABC"

// Deleting 🤷🏻‍♂️
keychainUtility[key] = nil
```

## Updates

You can request the changes you need (e.g. support other Apple Keychain classes) and I will glad to help to implement it.

Consider to donate a few $ using "♡ Sponsor" button.
