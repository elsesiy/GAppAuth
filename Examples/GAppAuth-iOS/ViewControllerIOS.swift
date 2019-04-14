//
//  ViewControllerIOS.swift
//  GAppAuth-iOS
//
//  Created by @elsesiy on 12/20/18.
//

import UIKit
import GAppAuth

class ViewControllerIOS: UIViewController {
    
    @IBOutlet weak var accessToken: UITextField!
    @IBOutlet weak var refreshToken: UITextField!
    @IBOutlet weak var scopes: UITextField!
    @IBOutlet weak var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if GAppAuth.shared.isAuthorized() {
            let authorization = GAppAuth.shared.getCurrentAuthorization()
            self.updateUI(authorization)
        }
    }
    
    private func updateUI(_ authorization: GTMAppAuthFetcherAuthorization?) {
        let tokenResponse = authorization?.authState.lastTokenResponse
        
        self.accessToken.text = tokenResponse?.accessToken ?? ""
        self.refreshToken.text = tokenResponse?.refreshToken ?? ""
        self.scopes.text = tokenResponse?.scope ?? ""
        self.email.text = authorization?.userEmail ?? ""
    }
    
    @IBAction func login() {
        do {
            try GAppAuth.shared.authorize(in: self) { auth in
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
    
    @IBAction func logout() {
        GAppAuth.shared.resetAuthorizationState()
        updateUI(nil)
    }
    
}

