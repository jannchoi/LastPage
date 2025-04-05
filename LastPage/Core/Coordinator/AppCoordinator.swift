//
//  AppCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] {get set}
    func start()
}
extension Coordinator {
   func removeChildCoordinator(_ child: Coordinator) {
       for (index, coordinator) in childCoordinators.enumerated() {
           if coordinator === child {
               childCoordinators.remove(at: index)
               break
           }
       }
   }
}
