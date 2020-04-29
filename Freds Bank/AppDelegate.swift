//
//  AppDelegate.swift
//  Freds Bank
//
//  Created by Jason Jobe on 4/28/20.
//  Copyright © 2020 Jason Jobe. All rights reserved.
//

import UIKit
import SQiftViewModel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appViewModel: AppViewModel = try! AppViewModel()
    var baseViewModel: BaseViewModel { appViewModel }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        appViewModel.delegate = self
        modelWillCommit(baseViewModel)
        return true
    }
}

extension AppDelegate: BaseViewModelDelegate {
    func modelWillCommit(_ vm: BaseViewModel) {
        guard let window = window else { return }
        window.rootViewController?.visit {
            $0.refresh(from: vm)
        }
    }
}

