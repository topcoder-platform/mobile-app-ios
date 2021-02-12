//
//  HelpFunctions.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 12/26/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftEx83
import Combine

extension Date {
    
    public static let shortDate: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()
    
    public static let connectionStateDateTime: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy | h:mm a"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()
}

extension URL {
    
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

var Current: UIViewController? {
    return UIViewController.getNavigationController() ?? UIViewController.getCurrentViewController()
}

var cancellable: AnyCancellable?
var cancellableDids: AnyCancellable?

extension UIViewController {
    
    @IBAction func menuAction(_ sender: Any) {
        guard let vc = create(MenuViewController.self) else { return }
        
        if let parent = Current {
            parent.showViewControllerFromSide(vc, inContainer: parent.view, bounds: parent.view.bounds, side: .left, nil)
        }
    }
    
    func showHomeScreen(animated: Bool) {
        guard let vc = create(MainNavigationViewController.self) else { return }
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .flipHorizontal
        self.present(vc, animated: animated, completion: { [weak self] in
            self?.tryShowTutorial()
        })
    }
    
    func tryShowTutorial() {
        guard let vc = create(WelcomeViewController.self) else { return }
        vc.modalPresentationStyle = .fullScreen
        Current?.present(vc, animated: true, completion: nil)
    }
    
    func showInvitation(invitation: JSON) {
        guard let vc = create(NewConnectionViewController.self) else { return }
        let name = invitation["label"].string ?? "-"
        let connection = Connection(relation: name, info: "You connected with \(name).", date: Date(), serializedConnection: nil)
        vc.connection = connection
        vc.callback = { [weak self] in
            self?.connect(withInvitation: invitation)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    private func connect(withInvitation invitation: JSON) {
        let loadingIndicator = ActivityIndicator(parentView: nil).start()
        var connectionHandle: Int!
        let util = VcxUtil.shared
        // Creating a connection
        cancellable = util.connect(withInviteDetails: invitation.dictionaryObject ?? [:])
            .flatMap({ handle -> Future<Void, Error> in
                connectionHandle = handle
                return util.connect(handle: handle)
            })
            .map { _ in
                sleep(4)
        }
        .flatMap({ handle in
            util.connectionGetState(handle: connectionHandle)
        })
            .flatMap({ handle in
                util.connectionUpdateState(handle: connectionHandle)
            })
            .flatMap({ _ in
                util.connectionSerialize(handle: connectionHandle)
            })
            .map { [weak self] serializedConnection in
                _ = util.connectionRelease(handle: connectionHandle)
                guard self != nil else { return }
                
                // Save connection
                let connectionName = invitation["label"].string ?? "-"
                let didRemote = invitation["recipientKeys"].arrayValue.first?.string ?? "-"
                let connection = Connection(relation: connectionName, info: "You connected with \(connectionName).", date: Date(), serializedConnection: serializedConnection)
                connection.didRemote = didRemote
                self?.addConnection(connection: connection)
        }
        .sink(receiveCompletion: { completion in
            loadingIndicator.stop()
            switch completion {
            case .finished: break
            case .failure(let error): showError(errorMessage: error.localizedDescription)
            }
        }, receiveValue: { _ in })
    }
    
    func addConnection(connection: Connection) {
        API.add(connection: connection)
            .addActivityIndicator(on: UIViewController.getCurrentViewController() ?? self)
            .subscribe(onNext: { [weak self] value in
                self?.tryShowApnRequest()
                return
                }, onError: { _ in
            }).disposed(by: self.rx.disposeBag)
        
        let util = VcxUtil.shared
        
        // DIDs
        guard let serializedConnection = connection.serializedConnection else { return }
        print("Getting dids...")
        cancellableDids = util.connectionDeserialize(serializedConnection: serializedConnection)
            .flatMap({ handle in
                util.connectionDids(handle: handle)
            })
            .map({ (pwdid, theirdid) in
                print("pwdid=\(pwdid) theirdid=\(theirdid)")
                connection.didCurrent = pwdid
            })
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error): showError(errorMessage: error.localizedDescription)
                }
            }, receiveValue: { _ in })
    }
    
    private func tryShowApnRequest() {
        guard !UserDefaults.askedApn else { return }
        guard let vc = create(AllowPushNotificationsViewController.self) else { return }
        guard let parent = Current else { return }
        parent.showViewControllerFromSide(vc, inContainer: parent.view, bounds: parent.view.bounds, side: .bottom, nil)
    }
    
    func setupDefaultNavigationBar() {
        setupNavigationBar(bgColor: UIColor(0x2a2a2a))
        let f = UIFont(name: "Barlow-SemiBold", size: 24)!
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: f]
    }
}
