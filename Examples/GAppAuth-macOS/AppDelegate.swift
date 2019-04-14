//
//  AppDelegate.swift
//  GAppAuth-macOS
//
//  Created by @elsesiy on 07.03.18.
//

import Cocoa
import GAppAuth

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Handle URL event
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleEvent(event:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
        GAppAuth.shared.appendAuthorizationRealm(OIDScopeEmail)
        
        // Retrieve existing auth
        GAppAuth.shared.retrieveExistingAuthorizationState()
    }
    
    @objc private func handleEvent(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue ?? ""
        let url = URL(string: urlString)!
        
        _ = GAppAuth.shared.continueAuthorization(with: url, callback: nil)
    }
    
}
