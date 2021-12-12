//
//  SceneDelegate.swift
//  BLEPractice
//
//  Created by 贾捷飞 on 2021/12/6.
//

import UIKit
import CoreBluetooth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var bluetoothManager: CBCentralManager!


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        bluetoothManager = CBCentralManager()
        let rootViewController = window!.rootViewController as! UINavigationController
        let deviceScanViewController = rootViewController.topViewController as! BleScanViewController
        deviceScanViewController.manager = bluetoothManager
        print(#function)
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print(#function)
        
        //在连接界面退到后台再进入APP也会触发本方法，就不在这里启动扫描了
//        self.bluetoothManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
//        print("开始扫描")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        print(#function)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print(#function)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print(#function)
        //在扫描页面按 Home 键，不会触发 ViewController 的 viewDidDisappear 方法，所以在这里也停止一下扫描
        bluetoothManager.stopScan()
        print("停止扫描")
    }


}

