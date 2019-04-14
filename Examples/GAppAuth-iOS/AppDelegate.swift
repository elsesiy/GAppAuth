//
//  AppDelegate.swift
//  GAppAuth-iOS
//
//  Created by @elsesiy on 12/20/18.
//

import UIKit
import GAppAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Set Google services realms to authenticate against
        GAppAuth.shared.appendAuthorizationRealm(OIDScopeEmail)
        
        // Retrieve any existing authorization
        GAppAuth.shared.retrieveExistingAuthorizationState()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if GAppAuth.shared.continueAuthorization(with: url, callback: nil) {
            return true
        }
        
        return false
    }

}

