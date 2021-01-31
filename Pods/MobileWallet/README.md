# mobile-wallet

The library provides convenient API for using `vcx` library.

## Dependencies

- `vcx`, v. 0.8.2 (included into the project)

## How to use

1. Add the following into your  `Podfile`:
```
pod 'MobileWallet'
...

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end
```
2. Disable Bitcode in Build Settings
3. Add `-ObjC` flag in "Other flags"
3. Check `Examples/` on how to configure and use the library.
