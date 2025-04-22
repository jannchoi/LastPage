//
//  BookInfoDTO.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import Foundation

// MARK: - BookInfoDTO
struct BookInfoDTO: Decodable {
    let totalResults, startIndex, itemsPerPage: Int
    let query: String
    let item: [BookDetailDTO]
}

// MARK: - BookDetailDTO
struct BookDetailDTO: Decodable {
    let title: String
    let link: String
    let author: String
    let description: String
    let itemId: Int
    let cover: String
    let categoryName: String
}



// MARK: - DTO → 도메인 모델 변환
extension BookInfoDTO {
    func toDomain() -> BookInfo {
        return BookInfo(
            totalResults: totalResults,
            startIndex: startIndex,
            itemsPerPage: itemsPerPage,
            query: query,
            item: item.map { $0.toDomain() }
        )
    }
}

extension BookDetailDTO {
    func toDomain() -> BookDetail {
        var categoryList : [String]
        let components = categoryName.components(separatedBy: ">")
            
            // 최소한 2개 이상 요소가 있어야 첫 번째 ">" 다음 값을 찾을 수 있음
        if components.count < 1 {
            categoryList = []
        } else {
            // 첫 번째 ">" 다음 값 (예: "소설/시/희곡", "예술/대중문화")을 "/"로 다시 분리
            let idx = min(components.count - 1, 1)
            let secondComponent = components[idx]
            categoryList = secondComponent.components(separatedBy: "/")
        }

        return BookDetail(
            title: title,
            link: link,
            author: author,
            description: description,
            itemId: itemId,
            cover: cover,
            categoryName: categoryList
        )
    }
}


/*
 
 struct BookInfoDTO: Decodable {
     let version: String
     let title: String
     let link: String
     let pubDate: String
     let imageUrl: String
     let totalResults, startIndex, itemsPerPage: Int
     let query: String
     let searchCategoryId: Int
     let searchCategoryName: String
     let item: [BookDetailDTO]
 }

 // MARK: - BookDetailDTO
 struct BookDetailDTO: Decodable {
     let title: String
     let link: String
     let author: String
     let pubDate: String
     let description: String
     let creator: String
     let isbn: String
     let isbn13: String
     let itemId: Int
     let priceSales: Int
     let priceStandard: Int
     let stockStatus: String
     let mileage: Int
     let cover: String
     let categoryId: Int
     let categoryName: String
     let publisher: String
     let customerReviewRank: Int
 }

 
 */
