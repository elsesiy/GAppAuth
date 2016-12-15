# GAppAuth

This is a drop-in class to handle AppAuth with Google Services.

## Usage
Add `GTMAppAuth` dependency to your Podfile (Cocoapods) or copy the files manually to your project directory. Add `GAppAuthorizer.swift` to your project and set-up you project as follows to use AppAuth with Google Services.

1. Setup your project (iOS) at https://console.developers.google.com to retrieve ClientID and iOS scheme URL.
2. Enable Google APIs as desired.
3. Replace ClientID and RedirectURI in `GAppAuthorizer.swift`.
3. Add Custom URL-Scheme to your project:
    ```<key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
            </array>
        </dict>
    </array>
    ```
4. From any `UIViewController` start the authorization workflow by calling `GAppAuth.shared.authorize`.

#### Feel free to add any remarks or open up a PR.
