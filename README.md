GAppAuth
=====

![pod](https://img.shields.io/cocoapods/v/GAppAuth.svg)
[![License](https://img.shields.io/cocoapods/l/GAppAuth.svg)](http://cocoapods.org/pods/GAppAuth)
[![Twitter](https://img.shields.io/badge/twitter-@elsesiy-blue.svg)](http://twitter.com/elsesiy)

This is a drop-in class to handle AppAuth with Google Services (currently supporting only iOS).

## Installation via cocoapods

Just add this dependency to your Podfile:

`pod GAppAuth`  

The transitive dependency to GTMAppAuth is added automatically.

## Manually
Add `GTMAppAuth` dependency to your Podfile (Cocoapods) or copy the files manually to your project directory. Add `GAppAuth.swift` to your project and set-up you project as follows to use AppAuth with Google Services.

1. Setup your project (iOS) at https://console.developers.google.com to retrieve ClientID and iOS scheme URL.
2. Enable Google APIs as desired.
3. Add ClientId and RedirectUri to your Info.plist:
```
  <key>GAppAuth</key>
  <dict>
    <key>RedirectUri</key>
    <string>com.googleusercontent.apps.YOUR-CLIENT-ID:/oauthredirect</string>
    <key>ClientId</key>
    <string>YOUR-CLIENT-ID.apps.googleusercontent.com</string>
  </dict>
```
4. Add Custom URL-Scheme to your project:
```
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleURLSchemes</key>
        <array>
          <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
  </array>
```
5. In order to authorize for any Google Service, you'd need to append the respective scope to the authorization request via:
`GAppAuth.shared.appendAuthorizationRealm` (i.e. kGTLRAuthScopeDrive for Google Drive access).
6. From any `UIViewController` start the authorization workflow by calling `GAppAuth.shared.authorize`.
7. You might want to retrieve any existing authorization upon start of the app which can be done via `GAppAuth.shared.retrieveExistingAuthorizationState`.
8. There are two closures you can monitor in order to be notified about any changes `stateChangeCallback` or errors `errorCallback`.
**Note:** In case of a revoked access by the user, both callbacks will be called.

##### A good spot for 5. and 7. is the AppDelegate's `didFinishLaunchingWithOptions`.

#### Feel free to add any remarks or open up a PR.
