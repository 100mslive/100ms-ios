//
//  AppDelegate.swift
//  HMSVideo
//
//  Copyright (c) 2020 100ms. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseInteractor()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        let view = UIView(frame: window?.frame ?? CGRect(x: 0, y: 0, width: Int.max, height: Int.max))
        view.backgroundColor = .black
        view.tag = 1
        window?.rootViewController?.view.addSubview(view)
        window?.rootViewController?.view.bringSubviewToFront(view)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if let view = window?.rootViewController?.view.subviews.first(where: { $0.tag == 1 }) {
            view.removeFromSuperview()
        }
    }

}
