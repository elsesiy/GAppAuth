//
//  ViewControllerMacOS.swift
//  GAppAuth-macOS
//
//  Created by @elsesiy on 07.03.18.
//

import Cocoa
import GAppAuth

class ViewControllerMacOS: NSViewController {
    
    @IBOutlet weak var accessToken: NSTextField!
    @IBOutlet weak var refreshToken: NSTextField!
    @IBOutlet weak var scopes: NSTextField!
    @IBOutlet weak var email: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GAppAuth.shared.retrieveExistingAuthorizationState()
        
        if GAppAuth.shared.isAuthorized() {
            let authorization = GAppAuth.shared.getCurrentAuthorization()
            self.updateUI(authorization)
        }
    }
    
    override var representedObject: Any? {
        didSet {
            if GAppAuth.shared.isAuthorized() {
                let authorization = GAppAuth.shared.getCurrentAuthorization()
                self.updateUI(authorization)
            }
        }
    }
    
    @IBAction func click(_ sender: NSButton?) {
        do {
            try GAppAuth.shared.authorize { auth in
                if auth {
                    if GAppAuth.shared.isAuthorized() {
                        let authorization = GAppAuth.shared.getCurrentAuthorization()
                        self.updateUI(authorization)
                    }
                }
            }
        } catch let error {
            print(error.localizedDescription)
            updateUI(nil)
        }
        
    }
    
    @IBAction func logout(_ sender: NSButton?) {
        GAppAuth.shared.resetAuthorizationState()
        updateUI(nil)
    }
    
    private func updateUI(_ authorization: GTMAppAuthFetcherAuthorization?) {
        let tokenResponse = authorization?.authState.lastTokenResponse
        
        self.accessToken.stringValue = tokenResponse?.accessToken ?? ""
        self.refreshToken.stringValue = tokenResponse?.refreshToken ?? ""
        self.scopes.stringValue = tokenResponse?.scope ?? ""
        self.email.stringValue = authorization?.userEmail ?? ""
    }
}
