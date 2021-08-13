//
//  MenuViewController.swift
// TopcoderMobileApp
//
//  Created by Volkov Alexander on 12/26/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftEx83
import UIComponents
import Auth0
import Amplify
import MobileWallet
import Lock

/// flag: true - menu is opened, false - else
var MenuViewControllerOpened = false

var MenuSelectedIndex = 0

enum MenuItem: Int {
    case home, wallet, topcoder,
    myConnections, myCredentials, settings,
    login, challenges
    
    var level: Int {
        switch self {
        case .home, .wallet, .topcoder: return 0
        case .myConnections: fallthrough
        case .myCredentials: fallthrough
        case .settings: fallthrough
        case .login: fallthrough
        case .challenges: fallthrough
        default: return 1
        }
    }
    
    var childrend: [MenuItem] {
        switch self {
        case .wallet: return [.myConnections, .myCredentials, .settings]
        case .topcoder: return [.login, .challenges]
        default: return []
        }
    }
    
    var hasChildren: Bool {
        return !childrend.isEmpty
    }
    
    var title: String {
        switch self {
        case .home: return NSLocalizedString("Home", comment: "Home")
        case .wallet: return NSLocalizedString("Wallet", comment: "Wallet")
            case .myConnections: return NSLocalizedString("My Connections", comment: "My Connections")
            case .myCredentials: return NSLocalizedString("My Credentials", comment: "My Credentials")
            case .settings: return NSLocalizedString("Settings", comment: "Settings")
        case .topcoder: return NSLocalizedString("Topcoder", comment: "Topcoder")
        case .login: return AuthenticationUtil.isAuthenticated() ? NSLocalizedString("Logout", comment: "Logout") : NSLocalizedString("Login", comment: "Login")
            case .challenges: return NSLocalizedString("Challenges", comment: "Challenges")
        }
    }
    
    var icon: UIImage! {
        switch self {
        case .home: return UIImage(named: "m1")
        case .wallet: return UIImage(named: "m2")
        case .myConnections: return UIImage(named: "m2.1")
        case .myCredentials: return UIImage(named: "m2.2")
        case .settings: return UIImage(named: "m2.3")
        case .topcoder: return UIImage(named: "m3")
        case .login: return UIImage(systemName: "person")
        case .challenges: return UIImage(named: "m3.2")
        }
    }
}

class MenuViewController: UIViewController {

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var profileIconView: UIImageView!
    
    /// the table model
    private var table = InfiniteTableViewModel<MenuItem, MenuItemCell>()
    
    private var items = [MenuItem]()
    
    private var selectedIndex = MenuSelectedIndex
    
    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        delay(0.3) { [weak self] in
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.view.backgroundColor = UIColor.black.alpha(alpha: 0.5)
            }, completion: nil)
        }
        profileIconView.round()
        setupMenu()
        updateUI()
        loadProfile()
    }
    
    private func setupMenu() {
        // Table
        table.showLoadingIndicator = false
        table.configureCell = { [weak self] indexPath, item, _, cell in
            cell.configure(item, isSelected: item.rawValue == MenuSelectedIndex || item.rawValue == self?.selectedIndex || item.childrend.map({$0.rawValue}).contains(MenuSelectedIndex))
        }
        table.onSelect = { [weak self] _, item in
            self?.handleMenuClick(item)
        }
        table.loadItems = { [weak self] callback, failure in
            guard self != nil else { return }
            callback(self?.items ?? [])
        }
        table.bindData(to: tableView)
        
        // Menu items
        loadMenuItems(selected: MenuItem(rawValue: MenuSelectedIndex))
    }
    
    private func loadMenuItems(selected: MenuItem?) {
        items.removeAll()
        items.append(.home)
        items.append(.wallet)
        let submenu1 = MenuItem.wallet.childrend
        if submenu1.map({$0.rawValue}).contains(selectedIndex) || selectedIndex == MenuItem.wallet.rawValue {
            items.append(contentsOf: submenu1)
        }
        items.append(.topcoder)
        let submenu2 = MenuItem.topcoder.childrend
        if submenu2.map({$0.rawValue}).contains(selectedIndex) || selectedIndex == MenuItem.topcoder.rawValue {
            items.append(contentsOf: submenu2)
        }
        table.loadData()
    }
    
    private func handleMenuClick(_ item: MenuItem) {
        // Tap on selected
        if MenuSelectedIndex == item.rawValue {
            if item.hasChildren {
                // collapse
                loadMenuItems(selected: nil)
            }
            else if item == .login {
                openContent(for: item)
            }
            else {
                dismissMenu {}
            }
        }
        else {
            if item.hasChildren {
                
                // Initialize wallet if tapped for the first time: https://github.com/topcoder-platform/evernym-tc-wallet/issues/33
                if item == .wallet {
                    CMConfig.shared.tryInitialize(deviceToken: AppDelegate.deviceToken!, handle:AuthenticationUtil.handle!)
                }
                
                selectedIndex = item.rawValue
                // expand the menu
                loadMenuItems(selected: item)
            }
            else {
                openContent(for: item)
            }
        }
    }
    
    /// Update UI
    private func updateUI() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        
        versionLabel.text = "version \(version) (build \(build))"
    }
    
    /// Load profile image
    private func loadProfile() {
        guard let handle = AuthenticationUtil.handle else { return }
        API.getProfileImage(handle: handle)
            .subscribe(onNext: { [weak self] value in
                
                // Load image
                UIImage.load(value) { (image) in
                    if let image = image {
                        self?.profileIconView.image = image
                    }
                }
                return
            }, onError: { e in
                showError(errorMessage: e.localizedDescription)
            }).disposed(by: rx.disposeBag)
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        self.dismissMenu({})
    }

    private func openContent(for item: MenuItem) {
        guard !item.hasChildren else { fatalError("Incorrect parameter openContent(\(item))") }
        if item == .login {
            if AuthenticationUtil.isAuthenticated() {
                self.showAlert("", "The app will logout you from Topcoder") { [weak self] in
                    LoginViewController.tryLogout() {
                        self?.dismissMenu {}
                    }
                }
                return
            }
            else {
//                LoginViewController.tryLogin() { [weak self] in
//                    self?.dismissMenu {}
//                }
            }
        }
        MenuSelectedIndex = item.rawValue
        selectedIndex = item.rawValue
        updateUI()
        dismissMenu { [weak self] in
            guard let navVc = Current as? UINavigationController else { return }
            var viewController: UIViewController?
            switch item {
            case .login:
                assert(!AuthenticationUtil.isAuthenticated())
                viewController = self?.getWebviewLoginViewController()
            case .home:
                guard let vc = self?.create(HomeViewController.self) else { return }
                viewController = vc
            case .myConnections:
                guard let vc = self?.create(ConnectionsViewController.self) else { return }
                viewController = vc
            case .myCredentials:
                guard let vc = self?.create(CredentialsViewController.self) else { return }
                viewController = vc
            case .settings:
                guard let vc = self?.create(SettingsViewController.self) else { return }
                viewController = vc
            case .challenges:
                guard let vc = self?.create(WebViewController.self) else { return }
                vc.title = NSLocalizedString("Challenges", comment: "Challenges").uppercased()
                vc.urlString = Configuration.urlChallenges
                viewController = vc
            default: break
            }
            guard let vc = viewController else { return }
            navVc.setViewControllers([vc], animated: false)
        }
    }
    
    /// Dismiss menu and call a callback
    private func dismissMenu(_ callback: @escaping ()->()) {
        MenuViewControllerOpened = false
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = .clear
        }, completion: nil)
        self.dismissViewControllerToSide(self, side: .left, callback)
    }
    
    private func getWebviewLoginViewController() -> UIViewController {
        let url = Configuration.urlLogin
        let vc = self.create(WebViewController.self)!
        vc.title = NSLocalizedString("Login", comment: "Login").uppercased()
        vc.urlString = url
        return vc
    }
    
    private func getNativeLoginViewController() -> UIViewController {
        var callback: ((Credentials)->())? = { creds in
            
            self.openContent(for: .challenges)
        }
        let vc = Lock
            .classic()
            .withOptions {
                $0.oidcConformant = true
                $0.autoClose = false
                $0.audience = "https://topcoder-dev.auth0.com/userinfo"
                $0.scope = "openid profile"
        }
        .onAuth { credentials in
            guard let accessToken = credentials.accessToken else { return }
            print("accessToken: \(accessToken)")
            AuthenticationUtil.processCredentials(credentials: credentials)
            
            // Open challenges page
            callback?(credentials)
            callback = nil
        }.controller
        vc.title = NSLocalizedString("Login", comment: "Login").uppercased()
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu-8"), style: .plain, target: self, action: #selector(menuAction(_:)))
        return vc
    }
    
    
}

/// Cell for table in this view controller
class MenuItemCell: ClearCell {
    
    /// outlets
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var collapseIcon: UIImageView!
    
    /// the related item
    private var item: MenuItem!
    
    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    /// Update UI with given data
    ///
    /// - Parameters:
    ///   - item: the data to show in the cell
    ///   - isSelected: true - if selected
    func configure(_ item: MenuItem, isSelected: Bool) {
        self.item = item
        button.setTitle(item.title, for: .normal)
        button.setImage(item.icon, for: .normal)
        button.contentEdgeInsets.left = item.level == 0 ? 34 : 73
        button.isSelected = isSelected && !item.hasChildren
        collapseIcon.isHidden = !item.hasChildren
        collapseIcon.image = isSelected ? #imageLiteral(resourceName: "arrowCollapse") : #imageLiteral(resourceName: "arrowExpand")
    }
}
