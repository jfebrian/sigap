//
//  SceneDelegate.swift
//  sigap
//
//  Created by Rony Fhebrian on 31/03/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene

        self.loadBaseController()
    }
    
    func loadBaseController() {
       guard let window = self.window else { return }
       window.makeKeyAndVisible()
        let isLogin:Bool = UserDefaults.standard.bool(forKey: "isLogin")
        let isSecurity:Bool = UserDefaults.standard.bool(forKey: "isSecurity")
        if !isLogin {
            let storyboard : UIStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
            let loginVC: AuthViewController = storyboard.instantiateViewController(withIdentifier: "areaCodeSb") as! AuthViewController
            let navigationLoginVC = UINavigationController(rootViewController: loginVC)
            self.window?.rootViewController = navigationLoginVC
        } else {
            if !isSecurity {
                if UserDefaults.standard.bool(forKey: "isRegistered") {
                    let storyboard : UIStoryboard = UIStoryboard(name: "User", bundle: nil)
                    let userHomeVC: UserViewController = storyboard.instantiateViewController(withIdentifier: "userSb") as! UserViewController
                    let navigationHomeVC = UINavigationController(rootViewController: userHomeVC)
                    self.window?.rootViewController = navigationHomeVC
                } else {
                    let storyboard: UIStoryboard = UIStoryboard(name: "Authentication-Profile", bundle: nil)
                    let profileVC = storyboard.instantiateViewController(withIdentifier: "profileSb") as! AuthProfileViewController
                    let navigationProfileVC = UINavigationController(rootViewController: profileVC)
                    self.window?.rootViewController = navigationProfileVC
                }
            } else {
                let storyboard : UIStoryboard = UIStoryboard(name: "Security", bundle: nil)
                self.window?.rootViewController = storyboard.instantiateInitialViewController()
                
            }
        }
        self.window?.makeKeyAndVisible()
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
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

