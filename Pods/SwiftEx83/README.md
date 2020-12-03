# SwiftEx(83)

Public library with Swift extensions.

Contains Foundation and UIKit extensions that are very helpful in every project (mobile apps or plain scripts)

iOS classes are extended with shortcuts and simple functions.

Please fork the project and create merge requests to contribute. Lets make Swift better together.

## Integration

#### CocoaPods (iOS 10+)

You can use [CocoaPods](http://cocoapods.org/) to install `SwiftEx` by adding it to your `Podfile`:

```ruby
platform :ios, '10.0'
use_frameworks!

target 'MyApp' do
    pod 'SwiftEx83', :git => 'https://gitlab.com/seriyvolk83/SwiftEx.git'
end
```

You can use any of the versions depending on what API you need: SwiftEx/Data, SwiftEx/UI, SwiftEx/Api, SwiftEx/Int

```ruby
platform :ios, '10.0'
use_frameworks!

target 'MyApp' do
    pod 'SwiftEx83/Int', :git => 'https://gitlab.com/seriyvolk83/SwiftEx.git'
end
```

#### Swift Package Manager

You can use [The Swift Package Manager](https://swift.org/package-manager) to install `SwiftEx` by adding the proper description to your `Package.swift` file:

```swift
// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "https://gitlab.com/seriyvolk83/SwiftEx.git", from: "0.3.30"),
    ]
    targets: [
        .target(name: "YOUR_PROJECT_NAME", dependencies: ["SwiftEx/Data"]) // You can use "SwiftEx" or "SwiftEx/Data"
    ]
)
```
Then run `swift build` whenever you get prepared.

#### Manually (iOS 10+)

To use this library in your project manually you may:

1. for Projects, just drag needed *.swift files to the project tree
2. for Workspaces, to the same

## Usage

Please open any Source/*.swift file and read method documentation. Usage of each method is straightforward.
The usage examples below are just a subset of what you can find in source files.

### String

#### String validations

```swift
print("notemail".isValidEmail) // false
print("email@gmail.com".isValidEmail)  // true

print("".isValidString) // false
print("string".isValidString) // true

print("abc".isValidPositiveNumber) // false
print("123".isValidPositiveNumber) // true
print("1234567890".formatPhone) // 123-456-7890
print("123456789012345".formatPhone) // +12-345-678-9012 (345)
```

#### String shortcuts

```swift
print(" string ".trim()) // "string"
print("ABC".contains("BC")) // true
print("ABD".replace("D", withString: "C")) // ABC
print("http://some thing \"cool\"".urlEncodedString()) // "http%3A%2F%2Fsome%20thing%20%22cool%22"
print("domain.com/folder/something".lastPath()) // "something"
print("123456".substring(index: 1, length: 3)) // "234"
```

### Int

```swift
print(Int.random())
print(Int.random(10))
print(1000.toCurrency()) // 1,000
print(16.toHex()) // "10"
```

### Date



### Array

#### Hash map from array
```swift
let a = [Item(id: 1, title: "one"), Item(id: 2, title: "two"), Item(id: 3, title: "three"), Item(id: 1, title: "another one")]
let map = a.hashmapWithKey{$0.id} // [1: Item(id: 1, title: "another one"), 2: Item(id: 2, title: "two"), 3: Item(id: 3 title: "three")]
```
     Note that first element is dropped because there is duplication (by ID)

#### Hash map with list values from array

```swift
let a = [Item(id: 1, title: "one"), Item(id: 2, title: "two"), Item(id: 3, title: "three"), Item(id: 1, title: "another one")]
let map = a.hasharrayWithKey{$0.id} // [1: [Item(id: 1, title: "one"), Item(id: 1, title: "another one")], 2: [Item(id: 2, title: "two")], 3: [Item(id: 3, title: "three")]]
```

## UIKit extensions

### Loading and transitions of view controllers

### Navigation bar

[Examples](docs/UINavigationControllerExtensions.md)

### Notification center

### UICollectionView extensions

### UITableView extensions

### UILabel extensions

### UIImage extensions

### UIView extensions

### JSON extensions: encoding/decoding, object mapping, loading

## REST API base implementation


TODO
