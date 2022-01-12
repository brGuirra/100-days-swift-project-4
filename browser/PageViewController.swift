//
//  ViewController.swift
//  browser
//
//  Created by Bruno Guirra on 07/01/22.
//

import UIKit
import WebKit

class PageViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var progressView: UIProgressView!
    var selectedWebsite: String?
    var websites: [String]?
    
    override func loadView() {
        // Create the Web View instance and set
        // the View as its value
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        // Hides the back button in navigation bar, this is
        // set because the interface has an open button with
        // the websites option
        navigationItem.setHidesBackButton(true, animated: true)
        
        // Create a Progress View and attach it to a Bar Button,
        // the sizeToFit is used to make the Progress View grow up
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        // Create the Bar Buttons to show in Tool Bar,
        // the spacer one is just to align the content
        // at corners
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        let forward = UIBarButtonItem(customView: createBackOrForwardButton(direction: "right"))
        let back = UIBarButtonItem(customView: createBackOrForwardButton(direction: "left"))
        
        
        // Pass the buttons to Tool Bar in the View Controller,
        // the property is an array and the order of the spacer
        // matters.
        toolbarItems = [progressButton, spacer, back, spacer, forward, spacer, refresh]
        
        // By default the Tool Bar is hidden, that's
        // why is necessary to change this property
        navigationController?.isToolbarHidden = false
        
        navigationItem.largeTitleDisplayMode = .never
        
        // Adds an Observer to look at the property estimatedProgress
        // and send updates when its receives new values. The #keyPath
        // is used to point the property in class constructor that will
        // be observed in the target
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        // Create an URL and passs to the Web View loads it
        // It's necessary to envolve the URL in URLRequest
        // since we want to navigate to a web page
        if let selectedWebsite = selectedWebsite {
            let url = URL(string: "https://" + selectedWebsite)!
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }
    }
    
    @objc func openTapped() {
        // Create an Alert Controller and add action itens to it,
        // the cancel one doesn't need a handler. The handler passed
        // here has access to UIAlertAction properties
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)

        if let websites = websites {
            for website in websites {
                ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
            }
        }

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)

    }

    
    // Handler that opens the page selected by user
    func openPage(action: UIAlertAction) {
        guard let actionTitle = action.title else { return }
        guard let url = URL(string: "https://" + actionTitle) else { return }
        
        webView.load(URLRequest(url: url))
    }
    
    // If the user tries to access a website that aren't
    // in the list, this function is responsible to sent
    // him back to Home View Controller to chose an allowed
    // website
    func loadHomePage(action: UIAlertAction) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Home") as? HomeTableViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // Create a back or forward button to insert in a
    // Bar Button Item
    func createBackOrForwardButton(direction: String) -> UIButton {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 25.0, weight: .regular, scale: .medium)
        
        if direction == "right" {
            button.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
            button.addTarget(webView, action: #selector(webView.goForward), for: .touchUpInside)
            button.sizeToFit()
        } else {
            button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
            button.addTarget(webView, action: #selector(webView.goBack), for: .touchUpInside)
            button.sizeToFit()
        }
        
        return button
    }
    
    // This will update the View's title with the title
    // of the website loaded
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    // This functions tells what's gonna happen when the observer catches
    // an update, in this case it will set a new value to the progress
    // property in the Progress View
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    // Check if the requested URL is in the array with websites
    // that can be accessed. This function receives a closure
    // with @escaping because has the funcionallity to be executed
    // later on. In this case is executed after the comparison
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        // It's possible that an URL doesn't have
        // a host property
        if let host = url?.host, let websites = websites {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
            
            // Show an alert informing the user that the site
            // isn't allowed to access
            let ac = UIAlertController(title: "Not allowed", message: "The access to this page is blocked.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Go home", style: .default, handler: loadHomePage))
            present(ac, animated: true)
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.cancel)
    }
}

