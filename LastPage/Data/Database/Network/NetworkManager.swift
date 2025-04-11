//
//  NetworkManager.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()

    private init() {}

    func callRequest<T: Decodable>(target: NetworkRouter, model: T.Type) -> AnyPublisher<T, NetworkError> {
        guard NetworkMonitor.shared.isConnected else {
            return Fail(error: NetworkError.customError(code: -1009, message: "인터넷 연결이 끊어졌습니다.")).eraseToAnyPublisher()
        }

        let request = target.asURLRequest()

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { [weak self] data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.customError(code: 500, message: "Invalid response")
                }

                guard 200..<300 ~= httpResponse.statusCode else {
                    throw self?.getError(code: httpResponse.statusCode) ?? .customError(code: httpResponse.statusCode, message: "HTTP Error \(httpResponse.statusCode)")
                }

                // 2️⃣ Data → String 변환 (UTF-8 시도 + fallback)
                var jsonString: String
                if let decoded = String(data: data, encoding: .utf8) {
                    jsonString = decoded

                } else {

                    jsonString = String(decoding: data, as: UTF8.self)

                }

                // 4️⃣ sanitize 이전 상태 출력

                let invalidControlChars = jsonString.filter { char in
                    let scalars = String(char).unicodeScalars
                    return scalars.contains { $0.value < 0x20 && $0.value != 0x09 && $0.value != 0x0A && $0.value != 0x0D }
                }

                if !invalidControlChars.isEmpty {
                    print("🚫 [비정상 제어 문자 포함]: \(invalidControlChars.count)개 감지됨 — 예시: \(invalidControlChars.prefix(10))")}
                jsonString = self?.sanitizeJSON(jsonString) ?? jsonString


                // 7️⃣ JSON 구조 검증 (선택)
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: Data(jsonString.utf8), options: [])
                } catch {
                    if let match = error.localizedDescription.range(of: #"column (\d+)"#, options: .regularExpression) {
                        let numberString = String(error.localizedDescription[match])
                            .replacingOccurrences(of: "column ", with: "")
                            .filter("0123456789".contains)

                        if let column = Int(numberString) {
                            let start = max(0, column - 20)
                            let preview = jsonString.dropFirst(start).prefix(50)
                            print("🔍 [자동 추출된 column \(column) 부근 문자열]: \(preview)")
                        }
                    }
                }

                // 8️⃣ 문자열 → Data 재변환
                guard let sanitizedData = jsonString.data(using: .utf8) else {
                    print("❌ [문자열 → Data 변환 실패]")
                    throw NetworkError.customError(code: 500, message: "문자열을 Data로 변환하는 데 실패했습니다.")
                }

                print("📤 [최종 반환될 Data size]: \(sanitizedData.count) bytes")

                return sanitizedData
            }
            .decode(type: T.self, decoder: Self.makeDecoder())
            .mapError { error in
                print("[❌ 디코딩 에러]: \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    print("🔍 상세 디코딩 에러:\n\(decodingError)")
                }
                return NetworkError.customError(code: 500, message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    func sanitizeJSON(_ jsonString: String) -> String {
        var cleaned = jsonString


        cleaned = cleaned.replacingOccurrences(of: #"\\'"#, with: "'")


        let invalidEscapeRegex = try! NSRegularExpression(pattern: #"\\[^"\\/bfnrtu]"#, options: [])
        cleaned = invalidEscapeRegex.stringByReplacingMatches(in: cleaned, options: [], range: NSRange(0..<cleaned.utf16.count), withTemplate: "")
        // 🔥 3. 개행 문자 제거 or 이스케이프
            cleaned = cleaned.replacingOccurrences(of: "\n", with: "\\n")
            cleaned = cleaned.replacingOccurrences(of: "\r", with: "\\r")
        if cleaned.hasSuffix(";") {
            cleaned.removeLast()
            }
        return cleaned
    }


    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }


    private func getError(code: Int) -> NetworkError {
        switch code {
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 429:
            return .rateLimited
        case 500, 503:
            return .serverError
        default:
            return .customError(code: code, message: "\(code) error")
        }
    }
}

