# Keychain83

Simple utility for iOS apps to store data in the keychain.

## Installation

### CocoaPods (iOS 10+)

You can use [CocoaPods](http://cocoapods.org/) to install `Keychain83` by adding it to your `Podfile`:

```
```ruby
platform :ios, '10.0'
use_frameworks!

target 'MyApp' do
pod 'Keychain83'
end
```

You can provide direct path to the library:

```

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

// Adding
keychainUtility[key] = "password123"

// Updating
keychainUtility[key] = "passwordABC"

// Deleting
keychainUtility[key] = nil
```
