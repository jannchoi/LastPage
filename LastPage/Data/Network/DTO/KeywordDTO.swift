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


/*
 struct Welcome: Codable {
 let id, object: String
 let created: Int
 let model: String
 let choices: [Choice]
 let usage: Usage
 let serviceTier: String
 let systemFingerprint: JSONNull?

 enum CodingKeys: String, CodingKey {
     case id, object, created, model, choices, usage
     case serviceTier = "service_tier"
     case systemFingerprint = "system_fingerprint"
 }
}

// MARK: - Choice
struct Choice: Codable {
 let index: Int
 let message: Message
 let logprobs: JSONNull?
 let finishReason: String

 enum CodingKeys: String, CodingKey {
     case index, message, logprobs
     case finishReason = "finish_reason"
 }
}

// MARK: - Message
struct Message: Codable {
 let role, content: String
 let refusal: JSONNull?
 let annotations: [JSONAny]
}

// MARK: - Usage
struct Usage: Codable {
 let promptTokens, completionTokens, totalTokens: Int
 let promptTokensDetails: PromptTokensDetails
 let completionTokensDetails: CompletionTokensDetails

 enum CodingKeys: String, CodingKey {
     case promptTokens = "prompt_tokens"
     case completionTokens = "completion_tokens"
     case totalTokens = "total_tokens"
     case promptTokensDetails = "prompt_tokens_details"
     case completionTokensDetails = "completion_tokens_details"
 }
}

// MARK: - CompletionTokensDetails
struct CompletionTokensDetails: Codable {
 let reasoningTokens, audioTokens, acceptedPredictionTokens, rejectedPredictionTokens: Int

 enum CodingKeys: String, CodingKey {
     case reasoningTokens = "reasoning_tokens"
     case audioTokens = "audio_tokens"
     case acceptedPredictionTokens = "accepted_prediction_tokens"
     case rejectedPredictionTokens = "rejected_prediction_tokens"
 }
}

// MARK: - PromptTokensDetails
struct PromptTokensDetails: Codable {
 let cachedTokens, audioTokens: Int

 enum CodingKeys: String, CodingKey {
     case cachedTokens = "cached_tokens"
     case audioTokens = "audio_tokens"
 }
}*/
