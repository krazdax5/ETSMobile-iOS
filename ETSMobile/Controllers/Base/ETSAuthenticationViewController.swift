//
//  ETSAuthenticationViewController.swift
//  ETSMobile
//
//  Created by Thomas Durand on 13/05/2015.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

import UIKit

protocol ETSAuthenticationViewControllerDelegate {
    func controllerDidAuthenticate(controller: ETSAuthenticationViewController)
}

class ETSAuthenticationViewController: UIViewController, UITextFieldDelegate {
    
    let kKeychainId = "ApplETS"
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    var usernameInKeychain: String? {
        get {
            let keychainItem: KeychainItemWrapper = KeychainItemWrapper(idenfitier: "ApplETS", accessGroup: nil)
            var username: String = keychainItem.objectForKey(kSecAttrAccount);
            
            if count(username) <= 0 {
                return nil
            }
            
            return username;
        }
    }
    var passwordInKeychain: String? {
        get {
            let keychainItem: KeychainItemWrapper = KeychainItemWrapper(idenfitier: "ApplETS", accessGroup: nil)
            var password: String = keychainItem.objectForKey(kSecValueData);
            
            if count(password) <= 0 {
                return nil
            }
            
            return password;
        }
    }
    
    @IBAction func panLeftMenu(sender: AnyObject?) {
        let dynamicsDrawerViewController: MSDynamicsDrawerViewController = UIApplication.sharedApplication().dynamicsDrawerViewController
        dynamicsDrawerViewController.setPaneState(MSDynamicsDrawerPaneStateOpen, animated:true, allowUserInterruption:true, completion: nil)
    }
    
    func validateJSONResponse(response: [String: AnyObject]) -> ETSSynchronizationResponse {
        let apiError = response["d.erreur"]
        let requestError = response["Message"]
        
        if apiError is String {
            if apiError == "Code d'accès ou mot de passe invalide" {
                return ETSSynchronizationResponseAuthenticationError
            } else if count(apiError) > 0 {
                return ETSSynchronizationResponseUnknownError
            }
        } else if requestError is String {
            if requestError == "There was an error processing the request." {
                return ETSSynchronizationResponseAuthenticationError
            }
        }
        
        return ETSSynchronizationResponseValid;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.setNavigationBarHidden(UIDevice.currentDevice().userInterfaceIdiom == .Phone, animated: animated)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.menuButton.hidden = true
            self.cancelButton.hidden = false
        } else {
            self.cancelButton.hidden = true
        }
        
        let dynamicsDrawerViewController: MSDynamicsDrawerViewController = UIApplication.sharedApplication().dynamicsDrawerViewController
        dynamicsDrawerViewController.setPaneDragRevealEnabled(true, forDirection: MSDynamicsDrawerDirectionLeft)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.usernameTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        } else {
            if count(self.usernameTextField.text) == 0 {
                self.usernameTextField.becomeFirstResponder()
            }
            else {
                self.authenticate(nil);
            }
        }
        
        return true
    }
    
    @IBAction func authenticate(sender: AnyObject?) {
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        
        let keychainItem: KeychainItemWrapper = KeychainItemWrapper(idenfitier: "ApplETS", accessGroup: nil)
        keychainItem.setObject(self.passwordTextField.text, forKey: kSecValueData )
        keychainItem.setObject(self.usernameTextField.text, forKey: kSecAttrAccount )
        
        self.delegate.controllerDidAuthenticate(self)
    }
    
    @IBAction func cancel(sender: AnyObject?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func resetKeychain() {
        let keychainItem: KeychainItemWrapper = KeychainItemWrapper(idenfitier: "ApplETS", accessGroup: nil)
        keychainItem.resetKeychainItem()
    }
}