//
//  MockBookRepository.swift
//  LastPage
//
//  Created by 최정안 on 3/31/25.
//

import Foundation
import Combine
let mockBookList: [BookEntity] = [
    BookEntity(
        id: nil,
        bookDetail: BookDetailEntity(
            imagePath: "https://image.aladin.co.kr/product/36117/12/coversum/k552038160_1.jpg",
            title: "걸리버 여행기 (완역본)",
            author: "조너선 스위프트 지음, 강경숙 옮김",
            status: .completed,
            shortMemo: "",
            categories: ["국내도서", "소설/시/희곡", "세계의 소설", "아일랜드소설"],
            feelings: []
        ),
        beforeMemo: MemoEntity(date: nil, memo: "세상을 보는 시각을 바꿔준다고 하더라."),
        inProgressMemo: [ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "중간중간 통계가 어려웠지만 흥미로웠어."), ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "읽으면서 많이 공감되고 위로가 된다."), ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "가볍게 읽히는 에세이 같아서 선택했어.")],
        afterMemo: MemoEntity(date: nil, memo: "끝까지 읽고 나니 세상에 대해 더 넓게 보게 됐어.")
    ),
    BookEntity(
        id: nil,
        bookDetail: BookDetailEntity(
            imagePath: "https://image.aladin.co.kr/product/35935/10/coversum/k002037708_1.jpg",
            title: "Do it! 스위프트로 아이폰 앱 만들기 : 입문 - 개정 8판, 일상생활 필수 앱을 직접 만들며 배운다!",
            author: "송호정.이범근 지음",
            status: .reading,
            shortMemo: "",
            categories: ["국내도서", "컴퓨터/모바일", "모바일 프로그래밍", "아이폰/아이패드"],
            feelings: ["행복","슬픔","공포","감동"]
        ),
        beforeMemo: MemoEntity(date: nil, memo: "세상을 보는 시각을 바꿔준다고 하더라."),
        inProgressMemo: [ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "중간중간 통계가 어려웠지만 흥미로웠어."), ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "읽으면서 많이 공감되고 위로가 된다."), ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "가볍게 읽히는 에세이 같아서 선택했어.")],
        afterMemo: MemoEntity(date: nil, memo: "끝까지 읽고 나니 세상에 대해 더 넓게 보게 됐어.")
    ),
    BookEntity(
        id: nil,
        bookDetail: BookDetailEntity(
            imagePath: "https://image.aladin.co.kr/product/35728/23/coversum/k692036432_1.jpg",
            title: "걸리버 여행기",
            author: "조너선 스위프트 지음, 마틴 우드사이드 다시 씀, 김완진 그림, 장혜진 옮김, 아서 포버",
            status: .unread,
            shortMemo: "이 책은 감정 표현이 서툰 소년의 이야기래. 시작 전부터 흥미롭다.",
            categories: ["국내도서", "어린이", "동화/명작/고전", "세계명작"],
            feelings: []
        ),
        beforeMemo: MemoEntity(date: nil, memo: "세상을 보는 시각을 바꿔준다고 하더라."),
        inProgressMemo: [ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "중간중간 통계가 어려웠지만 흥미로웠어."), ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "읽으면서 많이 공감되고 위로가 된다."), ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "가볍게 읽히는 에세이 같아서 선택했어.")],
        afterMemo: MemoEntity(date: nil, memo: "끝까지 읽고 나니 세상에 대해 더 넓게 보게 됐어.")
    ),
    BookEntity(
        id:nil,
        bookDetail: BookDetailEntity(
            imagePath: "https://image.aladin.co.kr/product/35647/70/coversum/k382036711_1.jpg",
            title: "테일러 스위프트 - 앨범별로 돌아본 우리 시대 아티스트의 삶과 노래",
            author: "캐롤린 맥휴 지음, 장정문 옮김, 김도헌 감수",
            status: .reading,
            shortMemo: "",
            categories: ["국내도서", "예술/대중문화", "음악", "음악가"],
            feelings: ["행복","슬픔","공포","감동"]
        ),
        beforeMemo: MemoEntity(date: nil, memo: "세상을 보는 시각을 바꿔준다고 하더라."),
        inProgressMemo: [ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "중간중간 통계가 어려웠지만 흥미로웠어."), ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "읽으면서 많이 공감되고 위로가 된다."), ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "가볍게 읽히는 에세이 같아서 선택했어.")],
        afterMemo: MemoEntity(date: nil, memo: "끝까지 읽고 나니 세상에 대해 더 넓게 보게 됐어.")
    ),
    BookEntity(
        id: nil,
        bookDetail: BookDetailEntity(
            imagePath: "https://image.aladin.co.kr/product/35095/35/coversum/k042934503_1.jpg",
            title: "제국의 설계자 - 테일러 스위프트의 비즈니스 레슨",
            author: "크리스토퍼 마이클 우드 지음, 플랫폼 9와 3/4 옮김",
            status: .unread,
            shortMemo: "이 책은 감정 표현이 서툰 소년의 이야기래. 시작 전부터 흥미롭다.",
            categories: ["국내도서", "경제경영", "기업/경영자 스토리", "국외 기업/경영자"],
            feelings: []
        ),
        beforeMemo: MemoEntity(date: nil, memo: "세상을 보는 시각을 바꿔준다고 하더라."),
        inProgressMemo: [ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "중간중간 통계가 어려웠지만 흥미로웠어."), ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "읽으면서 많이 공감되고 위로가 된다."), ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "가볍게 읽히는 에세이 같아서 선택했어.")],
        afterMemo: MemoEntity(date: nil, memo: "끝까지 읽고 나니 세상에 대해 더 넓게 보게 됐어.")
    ),
    BookEntity(
        id: nil,
        bookDetail: BookDetailEntity(
            imagePath: "https://image.aladin.co.kr/product/34165/94/coversum/k432931910_1.jpg",
            title: "[세트] 걸리버 유람기 + 후이늠 Houyhnhnm : 검은 인화지에 남긴 흰 그림자 - 전2권",
            author: "강화길 외 지음",
            status: .unread,
            shortMemo: "이 책은 감정 표현이 서툰 소년의 이야기래. 시작 전부터 흥미롭다.",
            categories: ["국내도서", "소설/시/희곡", "한국소설", "2000년대 이전 한국소설"],
            feelings: ["행복","슬픔","공포","감동"]
        ),
        beforeMemo: MemoEntity(date: nil, memo: "세상을 보는 시각을 바꿔준다고 하더라."),
        inProgressMemo: [ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "중간중간 통계가 어려웠지만 흥미로웠어."), ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "읽으면서 많이 공감되고 위로가 된다."), ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "가볍게 읽히는 에세이 같아서 선택했어.")],
        afterMemo: MemoEntity(date: nil, memo: "끝까지 읽고 나니 세상에 대해 더 넓게 보게 됐어.")
    ),
    BookEntity(
        id: nil,
        bookDetail: BookDetailEntity(
            imagePath: "https://image.aladin.co.kr/product/34157/31/coversum/8985231081_1.jpg",
            title: "걸리버 유람기",
            author: "김연수 지음, 강혜숙 그림, 조너선 스위프트 원작",
            status: .completed,
            shortMemo: "",
            categories: ["국내도서", "소설/시/희곡", "한국소설", "2000년대 이전 한국소설"],
            feelings: []
        ),
        beforeMemo: MemoEntity(date: nil, memo: "세상을 보는 시각을 바꿔준다고 하더라."),
        inProgressMemo: [ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "중간중간 통계가 어려웠지만 흥미로웠어."), ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "읽으면서 많이 공감되고 위로가 된다."), ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "가볍게 읽히는 에세이 같아서 선택했어.")],
        afterMemo: MemoEntity(date: nil, memo: "끝까지 읽고 나니 세상에 대해 더 넓게 보게 됐어.")
    ),
    BookEntity(
        id: nil,
        bookDetail: BookDetailEntity(
            imagePath: "https://image.aladin.co.kr/product/33888/52/coversum/k462038921_1.jpg",
            title: "딥러닝 스위프트 - iOS 앱 개발자를 위한",
            author: "조기성 지음",
            status: .unread,
            shortMemo: "이 책은 감정 표현이 서툰 소년의 이야기래. 시작 전부터 흥미롭다.",
            categories: ["국내도서", "컴퓨터/모바일", "모바일 프로그래밍", "아이폰/아이패드"],
            feelings: ["행복","슬픔","공포","감동"]
        ),
        beforeMemo: MemoEntity(date: nil, memo: "세상을 보는 시각을 바꿔준다고 하더라."),
        inProgressMemo: [ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "중간중간 통계가 어려웠지만 흥미로웠어."), ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "읽으면서 많이 공감되고 위로가 된다."), ProgressMemoEntity(startPage: "12", endPage: "21", date: nil, memo:  "가볍게 읽히는 에세이 같아서 선택했어.")],
        afterMemo: MemoEntity(date: nil, memo: "끝까지 읽고 나니 세상에 대해 더 넓게 보게 됐어.")
    )
]

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
