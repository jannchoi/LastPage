//
//  KeywordDTO.swift
//  LastPage
//
//  Created by 최정안 on 3/31/25.
//

import Foundation

struct KeywordDTO: Decodable {
    let id, object: String
    let choices: [ChoiceDTO]
}

struct ChoiceDTO: Decodable {
    let message: MessageDTO

}
struct MessageDTO: Decodable {
    let content: String
}
import Foundation

extension KeywordDTO {
    func toDomain() -> KeywordEntity? {
        guard let firstChoice = choices.first else { return nil }

        // content 내부의 JSON을 다시 파싱
        let jsonString = firstChoice.message.content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        // JSON을 디코딩하기 위한 구조체
        struct KeywordContent: Decodable {
            let keywords: [String]
        }
       
        guard let jsonData = jsonString.data(using: .utf8),
              let keywordContent = try? JSONDecoder().decode(KeywordContent.self, from: jsonData)
        else { return nil }
        return KeywordEntity(id: id, keywords: keywordContent.keywords)
    }
}
