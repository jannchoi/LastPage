//
//  TextResource.swift
//  LastPage
//
//  Created by 최정안 on 3/31/25.
//

import Foundation

enum TextResource {
    
    enum Global {
        case cancel
        case none
        case empty
        case customError(code: Int)
        case emptyData
        case alert
        
        var text: String {
            switch self {
            case .cancel:
                "취소"
            case .none: // 추가
                "none"
            case .empty: // 추가
                ""
            case .customError(let code):
                "알 수 없는 오류가 발생했습니다. (코드: \(code))"
            case .emptyData:
                "검색 결과가 없습니다."
            case .alert :
                "알림"
            }
        }
    }
    enum DataError {
        case fetchError
        case updateError
        case deleteError
        var text: String {
            switch self {
            case .fetchError:
                "데이터를 가져오는 데 실패했습니다."
            case .updateError:
                "데이터를 업데이트 하는 데 실패했습니다."
            case .deleteError:
                "데이터를 삭제하는 데 실패했습니다."
            }
        }
    }
    enum ButtonTitle {
        case edit
        case add
        case reconmmend
        case save
        case scan
        
        var text: String {
            switch self {
            case .edit:
                "Edit"
            case .add:
                "Add"
            case .reconmmend:
                "추천 키워드 보기"
            case .save :
                "Save"
            case .scan :
                "구절 스캔하기"
            }
        }
    }
    enum ReadingStatus {
        case before
        case inProgress
        case after
        
        var text: String {
            switch self {
            case .before:
                "읽기전"
            case .inProgress:
                "읽는중"
            case .after:
                "읽은후"
            }
        }
        
    }
    enum NavTitle {
        
    }
    
    enum Placeholder {
        case bookSearch
        case memoSearch
        case title
        case author
        case memo
        case category
        case feelings
        case date
        case page
        
        var text: String {
            switch self {
            case .bookSearch:
                "도서의 제목 또는 저자를 입력하세요."
            case .memoSearch:
                "메모를 검색하세요."
            case .title:
                "도서의 제목을 입력하세요."
            case .author:
                "도서의 저자를 입력하세요."
            case .memo:
                "이 책을 표현할 한 문장"
            case .category:
                "너의 취향, 이렇게 멋질 일?"
            case .feelings:
                "책이 건드린 너의 마음"
            case .date:
                "날짜를 선택하세요."
            case .page:
                "쪽 수"
            }
        }
        
    }
    enum InfoTextView {
        case title
        case author
        case shortMemo
        case categories
        case feelings
        case date
        case page
        case separator
        
        var text: String {
            switch self {
            case .title:
                "Title"
            case .author:
                "Author"
            case .shortMemo:
                "Short Memo"
            case .categories:
                "Categories"
            case .feelings:
                "Feelings"
            case .date:
                "Date"
            case .page:
                "Page"
            case .separator :
                "~"
            }
        }
    }
    enum SectionHeader {
        case bookKeywrod
        case commonKeyword
        
        var text: String {
            switch self {
            case .bookKeywrod:
                "책 추천 키워드"
            case .commonKeyword:
                "공통 추천 키워드"
            }
        }
    }
    enum Stats {
        case forMonth
        case forYear
        case total
        
        var text: String {
            switch self {
            case .forMonth:
                "이 달에 너의 문장이 태어난 책들"
            case .forYear:
                "올해도 꽤 멋지게 써내려왔어"
            case .total:
                "지금까지 네가 남긴 감상의 역사"
            }
        }
    }
}
    
