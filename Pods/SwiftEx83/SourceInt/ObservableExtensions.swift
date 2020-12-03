//
//  ObservableExtensions.swift
//  SwiftExUI
//
//  Created by Volkov Alexander on 2/15/19.
//

import RxSwift
import Alamofire
import RxAlamofire
import UIKit
import ObjectiveC

// MARK: - shorcut to call from ViewController
extension Observable {
    
    /// Call Observable and show activity indicator if needed
    ///
    /// - Parameters:
    ///   - viewController: the view controller
    ///   - usingActivityIndicator: true - will show loading indicator, false - else
    ///   - callback: the callback to invoke
    public func call(on viewController: UIViewController, usingActivityIndicator: Bool = true, _ callback: @escaping (Element)->(), failure: ((Error)->())? = nil) {
        let observer = usingActivityIndicator ? addActivityIndicator(on: viewController) : self
        observer.subscribe(onNext: { value in
            callback(value)
            return
        }, onError: { (error) in
            DispatchQueue.main.async { failure?(error) }
        }).disposed(by: viewController.rx.disposeBag)
    }
    
    /// Add activity indicator
    ///
    /// - Parameters:
    ///   - viewController: the view controller
    ///   - skipError: true - will skip error and will not show an alert, false - else
    /// - Returns: Observable
    public func addActivityIndicator(on viewController: UIViewController, skipError: Bool = false) -> Observable<Element> {
        let loader = ActivityIndicator(parentView: viewController.view).start()
        return self.do(onNext: { _ in
        }, onError: { (error) in
            DispatchQueue.main.async {
                loader.stop()
                if !skipError {
                    showError(errorMessage: error as? String ?? error.localizedDescription)
                }
            }
        }, onCompleted: {
            DispatchQueue.main.async { loader.stop() }
        })
    }
    
    /// Convert to a sequence with empty objects
    public func void() -> Observable<Void> { return self.map { _ in } }
}

fileprivate var disposeBagContext: UInt8 = 0

extension Reactive where Base: AnyObject {
    func synchronizedBag<T>( _ action: () -> T) -> T {
        objc_sync_enter(self.base)
        let result = action()
        objc_sync_exit(self.base)
        return result
    }
}

public extension Reactive where Base: AnyObject {

    /// a unique DisposeBag that is related to the Reactive.Base instance only for Reference type
    var disposeBag: DisposeBag {
        get {
            return synchronizedBag {
                if let disposeObject = objc_getAssociatedObject(base, &disposeBagContext) as? DisposeBag {
                    return disposeObject
                }
                let disposeObject = DisposeBag()
                objc_setAssociatedObject(base, &disposeBagContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return disposeObject
            }
        }
        
        set {
            synchronizedBag {
                objc_setAssociatedObject(base, &disposeBagContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}
