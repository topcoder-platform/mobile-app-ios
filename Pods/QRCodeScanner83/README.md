# QRCodeScanner83

Simple and extendable QR code/barcode/etc. scanner for iOS apps.

## Installation

### CocoaPods (iOS 10+)

You can use [CocoaPods](http://cocoapods.org/) to install `Keychain83` by adding it to your `Podfile`:

Add the following line to your `Podfile`.
```
pod 'QRCodeScanner83'
```

For example as follows:

```ruby
platform :ios, '10.0'
use_frameworks!

target 'MyApp' do
pod 'QRCodeScanner83'
end
```

You can provide direct path to the library:

```ruby
platform :ios, '10.0'
use_frameworks!

target 'MyApp' do
pod 'QRCodeScanner83', :git => 'https://github.com/seriyvolk83/QRCodeScanner.git'
end
```

## Usage

- Add `NSCameraUsageDescription` to `Info.plist`, e.g.:
```
<key>NSCameraUsageDescription</key>
<string>Will scan QR codes</string>
```
- Create view controller in XIB and set its class to `CodeScannerViewController` and specify identifier, e.g. `CodeScannerViewController`
- Add view, set its class to `CameraPreviewView` and connect it with `previewView` outlet.
- Instantiate `CodeScannerViewController` in code and configure using public vars and callbacks, e.g. you need at least define `callbackCodeScanned`.
- Optionally configure:
- - `codeTypes` - to limit the recognized code types
- - `delegate` - to handle different states of the scanner (add `import AVFoundation`)
- Dismiss the view controller in `callbackCodeScanned` callback.

```swift

import QRCodeScanner83
import AVFoundation

...

guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "CodeScannerViewController") as? CodeScannerViewController else {
    return
}
vc.callbackCodeScanned = { code in
    print("SCANNED CODE: \(code)")
    vc.dismiss(animated: true, completion: nil)
}
self.present(vc, animated: true, completion: nil)
```

## Updates

You can request the changes you need and I will glad to help to implement it.

Consider to donate a few $ using "♡ Sponsor" button.
