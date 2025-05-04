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
        let config = Realm.Configuration(schemaVersion: 2) { migration, oldSchemaVersion in
            
            if oldSchemaVersion < 1 {
                // 0 -> 1: keywords 필드 추가 (기존 주석 그대로 유지)
            }
            
            if oldSchemaVersion < 2 {
                // 1 -> 2: BookMemo에 backColor (BackColorObject) 추가
                // EmbeddedObject를 추가하는 것이므로 특별한 로직 없이 Realm이 기본적으로 nil로 처리함
                // 하지만 명시적으로 처리하고 싶다면 아래와 같이 작성 가능
                migration.enumerateObjects(ofType: BookMemo.className()) { oldObject, newObject in
                    newObject?["backColor"] = nil
                }
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

