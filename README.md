 
 Topcoder wallet built on Evernym
 
 [![Build status](https://build.appcenter.ms/v0.1/apps/50627fd5-5140-4e93-a904-039b6dd8d974/branches/main/badge)](https://appcenter.ms)
 
 ## Deployment dependencies
 
 Before performing a Deployment, it is assumed that the following have been set up:
 
 - Xcode 12.5+
 - iOS device iOS 14+
 
 ## Organization of Submission
 - `TopcoderMobileApp.xcworkspace` – Xcode workspace to open.
 - `README.md` – this file
 - `docs` - directory containing postman files.
 
 ## 3rd party Libraries
 
 - [SwiftEx83/*](https://gitlab.com/seriyvolk83/SwiftEx.git) v. 1.1.11
 - [MobileWallet](git@github.com:topcoder-platform/mobile-wallet.git)
 - [Keychain83](https://github.com/seriyvolk83/keychain)
 - [QRCodeScanner83](https://github.com/seriyvolk83/QRCodeScanner.git) v. 0.0.4
 - AppCenter/Distribute (4.2.0);
 - Auth0 (1.35.0);
 - Amplify(1.13.3) and AmplifyPlugins (AmplifyPlugins/AWSPinpointAnalyticsPlugin (1.13.3), AmplifyPlugins/AWSCognitoAuthPlugin (1.13.3));
 - Lock (2.23.0);
 - [SwiftJWT](https://github.com/Kitura/Swift-JWT) (3.6.200).
 
 ## Configuration
 
 Configuration is provided in `configuration.plist` stored in `TopcoderMobileApp/Supporting Files`
 
 - `API_ENDPOINT` - the endpoint for Topcoder API;
 - `APP_CENTER_SECRET` - AppCenter secret key;
 - `URL_CHALLENGES` - URL used to open challenges list
 - `URL_LOGIN` - URL used to open login form in embedded web view
 - `APN_ENDPOINT` - the endpoint for APN token
 
 In the mobile wallet pod, in `CMConfig.swift`, line 261 has `let privateKey=....`. Use the key provided in [the fourm](https://discussions.topcoder.com/discussion/10210/how-to-get-the-app-set-up)) for the string. (Can be skipped for submission verification).
 
 ## Deployment
 
 *Note*: You can skip this section and move to "Run the app" section during verification of the submission because all libraries are provided with the submission.
 
 Run `pod install` to update the libraries. You may need to run `pod update` if compilation will fail - "MobileWallet" framework may be updated and you need to pull the updates using `pod update`.
 If you updated the libraries in Pods using one of the above commands, then you may need to update the private key (check "Configuration" section) and `vcx.framework` - it's not included into the repository (a stub framework is included in the repositories to make them lightweight).
 
 ### Copy `vcx.framework`.
 
 MobileWallet repository contains stub framework without most of the binary code. Obtain the correct framework copy and copy it to `Pods/MobileWallet/Libraries` and replace `vcx.framework`.  
 
 ### Run the app
 
 To build and run the app you will need to do the following:
 
 1. Open `src/TopcoderMobileApp.xcworkspace` in Xcode
 2. Select *TopcoderMobileApp* scheme from the top left drop down list
 3. Select your iPhone/iPad from the top left dropdown list.
 4. Click menu Product -> Run (Cmd+R)
 
 
 ## Verification
 
 1. Try to build the app and check if it's compiled. If it's not compiled, then you may need to follow "Deployment" section.
 2. Follow [https://discussions.topcoder.com/discussion/10210/how-to-get-the-app-set-up](https://discussions.topcoder.com/discussion/10210/how-to-get-the-app-set-up) to create an account and register in the system. As a result you should have a valid connection for the related account.
 -  When obtaining the token from `challenges.topcoder-dev.com` you can take it from cookies, e.g. from `v3jwt` cookie.
 3. Once ready, run the app in the simulator and login with your account (you need to use account from `topcoder.com` because the suggested "dev" endpoint does not work properly).
 4. Stop the app and run it again and check Xcode console - it should have "Credentials" printed as JSON string. Copy it including the start `{` and the end `}` symbols. It's needed to allow you to open the app on a real device without authentication.
 - Authentication works only when the original Bundle ID is used. To run the app on a real device you may need to change the Bundle ID and as a result the app will not complete the login process (due to redirection URL assigned with specific Bundle ID).
 5. Paste the copied JSON string to `LoginViewController.swift` (replace "<PASTE HERE>" string).
 6. Change Bundle ID to your own in Project -> "TopcoderMobileApp" target -> Signing and Capabilities.
 7. Run the app on a real device.
 - You need to run the app on a real device to have access to the camera to scan QR code.
 8. Follow the rest of the steps from the [forum](https://discussions.topcoder.com/discussion/10210/how-to-get-the-app-set-up) to scan the QR code and create and accept the credentials.
 9. Verify how QR scanner screen is updated:
 - [ticket](https://github.com/topcoder-platform/mobile-app-ios/issues/24)
 - [video](https://youtu.be/eEGJkKqddYU)
 10. Verify "Challenges" UI
 - [ticket](https://github.com/topcoder-platform/mobile-app-ios/issues/22)
 - [video](https://youtu.be/kYjFYVK93xc)
 11.1: Verify updated loading indicator in "My Credentials":
 - - In "My Credentials" the loading indicator is shown on the top right corner. It's shown longer if you just launched the app and moved directly to this screen - SDK initialization is longer in most cases than credentials load (that is done only after the SDK is initialized).
 - [ticket](https://github.com/topcoder-platform/mobile-app-ios/issues/22)
 - WARNING! Verify connection deletion only after you verified all other changes. Once deleted it will not be possible to use the same invitation QR code to add the connection back. You will need to register new account to generate it.
 11.2 Verify how credentials are cleaned up when connection is removed. 
 
 ### Notes
 
 - Make sure you register on `topcoder-dev.com` (all the time, including activation link), because sometimes the service switches to `topcoder.com` and you may create a new topcoder account on `topcoder.com` instead of `topcoder-dev.com`. If `curl` below (for user registration) will fail with an error message saying "account not found", then this is the case.
 - If you need to create a new account for testing, you may need to logout on `topcoder-dev.com` (you may already be logged in when obtaining an access token). Open the following link in the browser to logout: [https://www.topcoder-dev.com/logout](https://www.topcoder-dev.com/logout). If you log out from the website it tries to log out on `topcoder.com` (bug on the website).
 - `curl` for registering the created account in the system (update access token and `--data` content with your own. 
 ```
 curl --request POST --url https://api.topcoder-dev.com/v5/users --header "Authorization: Bearer <ACCESS TOKEN HERE>" --header 'content-type: application/json' --data '{"handle":"iostester", "firstName":"John", "lastName":"Appleseed"}'
 ```
 - A few other API requests mentioned in the forum are provided as postman collection (see `/docs`). Update `{{TOKEN}}` and `{{HANDLE}}` in the environment.
 - I didn't find API for token refresh in the documentation. It's not implemented, but can be easily integrated by catching 40* HTTP codes using fields and closures in used `RestServiceApi.swift`

