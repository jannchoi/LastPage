//
//  MockKeywordRepository.swift
//  LastPage
//
//  Created by 최정안 on 3/31/25.
//

import Foundation
import Combine

import Foundation
import Combine

class MockKeywordRepository: KeywordRepositoryProtocol {
    // 외부 JSON 파일에서 응답 데이터를 로드
    private var mockSuccessResponse: [String: Any]?
    private var shouldFail: Bool
    private var delayInSeconds: TimeInterval
    
    init(jsonFileName: String = "gpt", shouldFail: Bool = false, delayInSeconds: TimeInterval = 0.0) {
        self.shouldFail = shouldFail
        self.delayInSeconds = delayInSeconds
        loadMockDataFromFile(named: jsonFileName)
    }
    
    private func loadMockDataFromFile(named fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("⚠️ JSON 파일을 찾을 수 없습니다: \(fileName).json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            mockSuccessResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("⚠️ JSON 파일 로드 실패: \(error.localizedDescription)")
        }
    }
    
    func fetchKeywords(prompt: String) -> AnyPublisher<KeywordEntity, NetworkError> {
        // 실패해야 하는 경우
        if shouldFail {
            print("InvalidData")
            return Fail(error: NetworkError.badRequest)
                .delay(for: .seconds(delayInSeconds), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
        
        // JSON 파일 로드 실패 체크
        guard let mockSuccessResponse = mockSuccessResponse else {
            print("InvalidData")
            return Fail(error: NetworkError.badRequest)
                .delay(for: .seconds(delayInSeconds), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
        
        // 임의로 KeywordDTO 생성
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: mockSuccessResponse, options: [])
            let decoder = JSONDecoder()
            let keywordDTO = try decoder.decode(ChatGPTDTO.self, from: jsonData)
            
            // toDomain을 통해 Entity로 변환
            if let keywordEntity = keywordDTO.toDomain() {
                return Just(keywordEntity)
                    .delay(for: .seconds(delayInSeconds), scheduler: RunLoop.main)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            } else {
                // 변환 실패시 빈 키워드 반환
                return Just(KeywordEntity(id: keywordDTO.id, keywords: []))
                    .delay(for: .seconds(delayInSeconds), scheduler: RunLoop.main)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            }
        } catch {
            print("⚠️ JSON 파싱 실패: \(error.localizedDescription)")
            return Fail(error: NetworkError.badRequest)
                .delay(for: .seconds(delayInSeconds), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }
    
    // 실시간으로 설정 변경 가능
    func setShouldFail(_ shouldFail: Bool) {
        self.shouldFail = shouldFail
    }
    
    // 딜레이 시간 설정 가능
    func setDelay(_ seconds: TimeInterval) {
        self.delayInSeconds = seconds
    }
    
    // JSON 파일 다시 로드
    func reloadMockData(fromFile fileName: String = "gpt") {
        loadMockDataFromFile(named: fileName)
    }
    
    // 하드코딩된 결과값만 빠르게 반환하는 간소화된 메서드
    func fetchParsedKeywords() -> AnyPublisher<KeywordEntity, NetworkError> {
        // 정적 키워드 리스트 생성 (gpt.json에서 추출한 값)
        let keywords = [
            "주인공이 역겨운 인물로 느껴지는 이유는 무엇인가?",
            "주인공의 성격과 행동에 공감할 수 있는 부분이 있는가?",
            "주인공의 결정들과 행동들이 전체 이야기에 미치는 영향은 무엇인가?",
            "주인공의 삶에서 어떤 교훈을 얻을 수 있는가?",
            "이야기 속에서 비극적인 측면을 찾을 수 있는가?",
            "주인공의 삶에서 잘못된 선택이 있었다면, 어떤 선택이 그랬는가?",
            "주인공과 타인 사이의 상호작용에서 어떤 관계 패턴을 발견할 수 있는가?",
            "이야기를 통해 전하는 주요 메시지는 무엇인가?",
            "주인공의 가치관과 사회적 가치관 간의 갈등이 어떻게 나타나는가?",
            "이야기 속 인물들의 행동을 둘러싼 도덕적 판단은 어떻게 변화하는가?"
        ]
        
        let entity = KeywordEntity(id: "chatcmpl-BGraPawIG8lIoLdDsimPESflwgcK7", keywords: keywords)
        
        return Just(entity)
            .delay(for: .seconds(delayInSeconds), scheduler: RunLoop.main)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}
