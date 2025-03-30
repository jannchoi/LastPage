//
//  MockBookRepository.swift
//  LastPage
//
//  Created by 최정안 on 3/31/25.
//

import Foundation
import Combine

class MockBookRepository: BookRepositoryProtocol {
    // 테스트용 JSON 파일 데이터
    private let mockFileName: String
    
    init(mockFileName: String = "searchbook.json") {
        self.mockFileName = mockFileName
    }
    
    func fetchBooks(query: String) -> AnyPublisher<BookInfo, NetworkError> {
        // 파일에서 JSON 데이터 로드
        guard let url = Bundle.main.url(forResource: mockFileName, withExtension: nil),
              let data = try? Data(contentsOf: url) else {
            return Fail(error: NetworkError.badRequest)
                .eraseToAnyPublisher()
        }
        
        do {
            // JSON 디코딩
            let decoder = JSONDecoder()
            let bookInfoDTO = try decoder.decode(BookInfoDTO.self, from: data)
            // DTO를 도메인 모델로 변환
            return Just(bookInfoDTO.toDomain())
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: NetworkError.badRequest)
                .eraseToAnyPublisher()
        }
    }
}
