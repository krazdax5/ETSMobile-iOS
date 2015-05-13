//
//  ETSWebViewViewController.swift
//  ETSMobile
//
//  Created by Thomas Durand on 13/05/2015.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

import UIKit

class ETSWebViewViewController: UIViewController, UIScrollViewDelegate, UIWebViewDelegate, UISplitViewControllerDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    
    @IBOutlet var masterPopoverController: UIPopoverController!
    @IBOutlet var masterBarButtonItem: UIBarButtonItem!
    
    var urlRequest: NSURLRequest?
    
    var request: NSURLRequest? {
        get {
            return urlRequest
        }
        set {
            self.urlRequest = newValue
            
            if self.urlRequest != nil {
                self.webView.loadRequest(self.urlRequest!)
                self.stopButton.enabled = true
                self.refreshButton.enabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.scrollView.delegate = self;
        self.webView.delegate = self;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.setNavigationBarHidden(false, animated: animated)
        self.navigationController!.setToolbarHidden(false, animated: animated)
        
        if self.urlRequest != nil {
            self.webView.loadRequest(self.urlRequest!)
            self.stopButton.enabled = true
            self.refreshButton.enabled = false
        }
    }
    
    func loadData(#data: NSData!, mimeType: String, textEncodingName: String!, baseUrl: NSURL!) {
        self.webView.loadData(data, MIMEType: mimeType, textEncodingName: textEncodingName, baseURL: baseUrl)
    }
    
    // UIWebViewDelegate Methods
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        self.stopButton.enabled = true
        self.refreshButton.enabled = false
        self.nextButton.enabled = self.webView.canGoForward
        self.backButton.enabled = self.webView.canGoBack
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        self.stopButton.enabled = false
        self.refreshButton.enabled = true
        self.nextButton.enabled = self.webView.canGoForward
        self.backButton.enabled = self.webView.canGoBack
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        self.stopButton.enabled = false
        self.refreshButton.enabled = true
        self.nextButton.enabled = self.webView.canGoForward
        self.backButton.enabled = self.webView.canGoBack
    }
    
    // UISplitViewControllerDelegate Methods
    func splitViewController(svc: UISplitViewController, willHideViewController aViewController: UIViewController, withBarButtonItem barButtonItem: UIBarButtonItem, forPopoverController pc: UIPopoverController) {
        self.masterBarButtonItem = barButtonItem
        barButtonItem.title = NSLocalizedString("Cours", comment: "")
        self.navigationItem.setLeftBarButtonItem(barButtonItem, animated: true)
        self.masterPopoverController = pc
    }
    
    func splitViewController(svc: UISplitViewController, willShowViewController aViewController: UIViewController, invalidatingBarButtonItem barButtonItem: UIBarButtonItem) {
        self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        self.masterPopoverController = nil
    }
}