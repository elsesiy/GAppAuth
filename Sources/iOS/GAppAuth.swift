// BSD 2-Clause License
// Copyright (c) 2016, Jonas-Taha El Sesiy
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
@_exported import AppAuth
@_exported import GTMAppAuth

/// Wrapper class that provides convenient AppAuth functionality with Google Services.
/// Set ClientId, RedirectUri and call respective methods where you need them.
/// Requires dependency to GTMAppAuth, see: https://github.com/google/GTMAppAuth
public final class GAppAuth: NSObject {
    
    // MARK: - Static declarations
    
    private static let KeychainPrefix   = Bundle.main.bundleIdentifier!
    private static let KeychainItemName = KeychainPrefix + "GoogleAuthorization"
    private static let GAppAuthCredentials = Bundle.main.object(forInfoDictionaryKey: "GAppAuth") as! NSDictionary
    
    private static var ClientId: String {
        return GAppAuthCredentials.value(forKey: "ClientId") as? String ?? ""
    }
    
    private static var RedirectUri: String {
        return GAppAuthCredentials.value(forKey: "RedirectUri") as? String ?? ""
    }
    
    // MARK: - Public vars
    
    // Authorization unsuccessful, subscribe if you're interested
    public var errorCallback: ((OIDAuthState, Error) -> Void)?
    
    // Authorization changed, subscribe if you're interested
    public var stateChangeCallback: ((OIDAuthState) -> Void)?
    
    // MARK: - Private vars
    
    private(set) var authorization: GTMAppAuthFetcherAuthorization?
    
    // Auth scopes
    private var scopes = [OIDScopeOpenID, OIDScopeProfile]
    
    // Used in continueAuthorization(with:callback:) in order to resume the authorization flow after app reentry
    private var currentAuthorizationFlow: OIDExternalUserAgentSession?
    
    // MARK: - Singleton
    
    private static var singletonInstance: GAppAuth?
    public static var shared: GAppAuth {
        if singletonInstance == nil {
            singletonInstance = GAppAuth()
        }
        return singletonInstance!
    }
    
    // No instances allowed
    private override init() {
        super.init()
    }
    
    // MARK: - APIs
    
    /// Add another authorization realm to the current set of scopes, i.e. `kGTLAuthScopeDrive` for Google Drive API.
    public func appendAuthorizationRealm(_ scope: String) {
        if !scopes.contains(scope) {
            scopes.append(scope)
        }
    }
    
    /// Starts the authorization flow.
    ///
    /// - parameter presentingViewController: The UIViewController that starts the workflow.
    /// - parameter callback: A completion callback to be used for further processing.
    @available(iOS 8.0, *)
    public func authorize(in presentingViewController: UIViewController, callback: ((Bool) -> Void)?) throws {
        guard GAppAuth.RedirectUri != "" else {
            throw GAppAuthError.plistValueEmpty("The value for RedirectUri seems to be wrong, did you forget to set it up?")
        }
        
        guard GAppAuth.ClientId != "" else {
            throw GAppAuthError.plistValueEmpty("The value for ClientId seems to be wrong, did you forget to set it up?")
        }
        
        let issuer = URL(string: "https://accounts.google.com")!
        let redirectURI = URL(string: GAppAuth.RedirectUri)!
        
        // Search for endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) {(configuration: OIDServiceConfiguration?, error: Error?) in
            
            if configuration == nil {
                self.setAuthorization(nil)
                return
            }
            
            // Create auth request
            let request = OIDAuthorizationRequest(configuration: configuration!, clientId: GAppAuth.ClientId, scopes: self.scopes, redirectURL: redirectURI, responseType: OIDResponseTypeCode, additionalParameters: nil)
            
            // Store auth flow to be resumed after app reentry, serialize response
            self.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: presentingViewController) {(authState: OIDAuthState?, error: Error?) in
                var response = false
                if let authState = authState {
                    
                    let authorization = GTMAppAuthFetcherAuthorization(authState: authState)
                    self.setAuthorization(authorization)
                    response = true
                    
                } else {
                    self.setAuthorization(nil)
                    if let error = error {
                        NSLog("Authorization error: \(error.localizedDescription)")
                    }
                }
                
                if let callback = callback {
                    callback(response)
                }
            }
        }
    }
    
    /// Continues the authorization flow (to be called from AppDelegate), i.e. in
    ///     func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    ///
    /// - parameter url: The url that's used to enter the app.
    /// - parameter callback: A completion callback to be used for further processing.
    /// - returns: true, if the authorization workflow can be continued with the provided url, else false
    public func continueAuthorization(with url: URL, callback: ((Bool) -> Void)?) -> Bool {
        var response = false
        if let authFlow = currentAuthorizationFlow {
            
            if authFlow.resumeExternalUserAgentFlow(with: url) {
                currentAuthorizationFlow = nil
                response = true
            } else {
                NSLog("Couldn't resume authorization flow!")
            }
        }
        
        if let callback = callback {
            callback(response)
        }
        
        return response
    }
    
    /// Determines the current authorization state.
    ///
    /// - returns: true, if there is a valid authorization available, else false
    public func isAuthorized() -> Bool {
        return authorization != nil ? authorization!.canAuthorize() : false
    }
    
    /// Load any existing authorization from the key chain on app start.
    public func retrieveExistingAuthorizationState() {
        let keychainItemName = GAppAuth.KeychainItemName
        if let authorization = GTMAppAuthFetcherAuthorization(fromKeychainForName: keychainItemName) {
            setAuthorization(authorization)
        }
    }
    
    /// Resets the authorization state and removes any stored information.
    public func resetAuthorizationState() {
        GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: GAppAuth.KeychainItemName)
        // As keychain and cached authorization token are meant to be in sync, we also have to:
        setAuthorization(nil)
    }
    
    /// Query the current authorization state
    public func getCurrentAuthorization() -> GTMAppAuthFetcherAuthorization? { return authorization }
    
    // MARK: - Internal functions
    
    /// Internal: Store the authorization.
    private func setAuthorization(_ authorization: GTMAppAuthFetcherAuthorization?) {
        guard self.authorization == nil || !self.authorization!.isEqual(authorization) else { return }
        
        self.authorization = authorization
        
        if self.authorization != nil {
            self.authorization!.authState.errorDelegate = self
            self.authorization!.authState.stateChangeDelegate = self
        }
        
        serializeAuthorizationState()
    }
    
    /// Internal: Save the authorization result from the workflow.
    private func serializeAuthorizationState() {
        // No authorization available which can be saved
        guard let authorization = authorization else { return }
        
        let keychainItemName = GAppAuth.KeychainItemName
        if authorization.canAuthorize() {
            GTMAppAuthFetcherAuthorization.save(authorization, toKeychainForName: keychainItemName)
        } else {
            // Remove existing authorization state
            GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: keychainItemName)
        }
    }
    
}

// MARK: - OIDAuthStateChangeDelegate

extension GAppAuth: OIDAuthStateChangeDelegate {
    
    public func didChange(_ state: OIDAuthState) {
        guard self.authorization != nil else { return }
        
        let authorization = GTMAppAuthFetcherAuthorization(authState: state)
        self.setAuthorization(authorization)
        
        if let stateChangeCallback = stateChangeCallback {
            stateChangeCallback(state)
        }
    }
    
}

// MARK: - OIDAuthStateErrorDelegate

extension GAppAuth: OIDAuthStateErrorDelegate {
    
    // Error callback
    public func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        guard self.authorization != nil else { return }
        
        currentAuthorizationFlow = nil
        setAuthorization(nil)
        if let errorCallback = errorCallback {
            errorCallback(state, error)
        }
    }
    
}

// MARK: - Error
private enum GAppAuthError: Error {
    case plistValueEmpty(String)
}
