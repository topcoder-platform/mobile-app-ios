//
//  WelcomeViewController.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 2/9/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftEx83
import SwiftyJSON

class WelcomeViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    
    /// the selected tab index
    private var selectedTabIndex = -1
    private var lastViewController: UIViewController!
    
    private var items = [WelcomeInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        do {
            items = try (JSON.resource(named: "welcome") ?? JSON.null).arrayValue.map({try $0.decodeIt()})
        }
        catch {
            print("ERROR: \(error)")
        }
//        let isFirstTime = UserDefaults.standard.value(forKey: "firstTime") as? Bool ?? true
//        if isFirstTime {
            setSelectedTab(0)
//            UserDefaults.standard.set(false, forKey: "firstTime")
//            UserDefaults.standard.synchronize()
//        }
//        else {
//            setSelectedTab(2)
//        }
    }
    

    // hide navigation bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    /// Set selected tab
    ///
    /// - Parameter index: the index
    func setSelectedTab(_ index: Int, side: Transition? = nil) {
        selectedTabIndex = index
        
        // Page indicator
        pageControl.currentPage = index
        
        guard let vc: WelcomeInfoViewController = create(WelcomeInfoViewController.self) else { return }
        vc.item = items[index]
        vc.prevCallback = { [weak self] in
            self?.swipeRight(self!)
        }
        vc.nextCallback = { [weak self] in
            self?.swipeLeft(self!)
        }
        
        if let side = side {
            if let last = lastViewController {
                lastViewController = nil
                dismissViewControllerToSide(last, side: side, nil)
                showViewControllerFromSide(vc, inContainer: self.containerView, bounds: self.containerView.bounds, side: side.reverse(), nil)
                lastViewController = vc
            }
        }
        else {
            loadViewController(vc, containerView)
            lastViewController = vc
        }
        
        updateUI()
    }
    
    private func updateUI() {
        prevButton.isHidden = selectedTabIndex == 0
        prevButton.setTitle(NSLocalizedString("Prev", comment: "Previous tutorial page").uppercased(), for: .normal)
        nextButton.setTitle((selectedTabIndex == pageControl.numberOfPages - 1 ? NSLocalizedString("Finish", comment: "Finish tutorial") : NSLocalizedString("Next", comment: "Next tutorial page")).uppercased(), for: .normal)
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            if self!.selectedTabIndex + 1 >= 3 {
                self?.openMainScreen()
            }
            else {
                self?.setSelectedTab(self!.selectedTabIndex + 1, side: .left)
            }
        }
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            if self!.selectedTabIndex > 0 {
                self?.setSelectedTab(self!.selectedTabIndex - 1, side: .right)
            }
        }
    }
    
    @IBAction func skipAction(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            self?.openMainScreen()
        }
    }
    
    private func openMainScreen() {
        delay(0.1) { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }

}
