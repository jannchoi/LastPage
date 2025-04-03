//
//  BookMemoMapperProtocol.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
// BookMemoMapper.swift
protocol BookMemoMapperProtocol {
    func mapToDomain(realmModel: BookMemo) -> BookEntity
    func mapToRealm(domainModel: BookEntity) -> BookMemo
    func updateBookEntity<T>(existing: BookEntity, newValue: T?, field: UpdateTarget, index: Int?) -> BookEntity
    
}
