//
//  BrowserViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import WebKit
import Core

class BrowserViewController: UIViewController, UISearchBarDelegate, WebLoadingDelegate {
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    private let groupData = GroupData()
    private var searchBar: UISearchBar!
    private weak var webController: WebViewController?
    private var initialUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        refreshNavigationButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    private func configureSearchBar() {
        searchBar = UISearchBar()
        searchBar.placeholder = UserText.searchDuckDuckGo
        searchBar.textColor = UIColor.darkGray
        searchBar.tintColor = UIColor.accent
        searchBar.autocapitalizationType = .none
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    private func configureNavigationBar() {
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.isToolbarHidden = false
    }
    
    private func refreshSearchBarText() {
        guard let url = webController?.url else {
            searchBar.text = nil
            return
        }
        
        if let query = AppUrls.searchQuery(fromUrl: url) {
            searchBar.text = query
            return
        }

        if AppUrls.isDuckDuckGo(url: url) {
            searchBar.text = nil
            return
        }
 
        searchBar.text = url.absoluteString
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        onSearchSubmitted()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        onSearchSubmitted()
    }
    
    private func onSearchSubmitted() {
        searchBar.resignFirstResponder()
        guard let text = searchBar.text?.trimWhitespace() else {
            return
        }
        load(query: text)
    }
    
    func webpageDidStartLoading() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webpageDidFinishLoading() {
        refreshNavigationButtons()
        refreshSearchBarText()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    private func refreshNavigationButtons() {
        backButton.isEnabled = webController?.canGoBack ?? false
        forwardButton.isEnabled = webController?.canGoForward ?? false
    }
    
    func load(query: String) {
        guard let url = AppUrls.url(forQuery: query) else {
            return
        }
        load(url: url)
    }
    
    func load(url: URL) {
        if let webController = webController {
            webController.load(url: url)
        } else {
            initialUrl = url
        }
    }
    
    @IBAction func onHomePressed(_ sender: UIBarButtonItem) {
        webController?.loadHomepage()
    }
    
    @IBAction func onRefreshPressed(_ sender: UIBarButtonItem) {
        webController?.reload()
    }
    
    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        webController?.goBack()
    }
    
    @IBAction func onForwardPressed(_ sender: UIBarButtonItem) {
        webController?.goForward()
    }
    
    @IBAction func onSharePressed(_ sender: UIBarButtonItem) {
        if let url = webController?.url {
            presentShareSheetFromButton(activityItems: [url], buttonItem: sender)
        }
    }
    
    @IBAction func onSaveQuickLink(_ sender: UIBarButtonItem) {
        if let link = webController?.link {
            groupData.addQuickLink(link: link)
            view.makeToast(UserText.webSaveLinkDone)
        }
    }
    
    @IBAction func onDeleteEverything(_ sender: UIBarButtonItem) {
        webController?.reset()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? WebViewController else {
            return
        }
        webController = controller
        controller.loadingDelegate = self
        controller.initialUrl = initialUrl
        initialUrl = nil
    }
}