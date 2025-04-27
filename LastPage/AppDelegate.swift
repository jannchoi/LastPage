//
//  AppDelegate.swift
//  LastPage
//
//  Created by 최정안 on 3/27/25.
//

import UIKit
import RealmSwift
import FirebaseCore
@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        migration()
        
        let realm = try! Realm()
        // 현재 사용자가 쓰고 있는 DB Schema Version
        do {
            let version = try schemaVersionAtURL(realm.configuration.fileURL!)
            print("Schema Version", version)
        } catch {
            print("Schema Failed")
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.backgroundBase // 배경색
        appearance.titleTextAttributes = [.foregroundColor: UIColor.mainText] // 제목 텍스트 색상
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.mainText] // 큰 제목 텍스트 색상
        
        // 적용 대상 설정
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .mainText // back 버튼 및 bar button item 색상
        return true
    }
    func migration() {
        let config = Realm.Configuration(schemaVersion: 1) { // 첫 번째 마이그레이션이므로 schemaVersion은 1
            migration, oldSchemaVersion in
            
            // 0 -> 1: BookMemo에 keywords 추가
            if oldSchemaVersion < 1 {
                // 단순히 필드를 추가하는 것이므로 추가 코드는 필요 없음
                // Realm이 자동으로 새 필드를 추가하고 기본값(빈 List)으로 초기화함
            }
        }
        
        Realm.Configuration.defaultConfiguration = config
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

