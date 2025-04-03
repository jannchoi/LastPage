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
        case help
        case save
        
        var text: String {
            switch self {
            case .edit:
                "Edit"
            case .add:
                "Add"
            case .help:
                "Help"
            case .save :
                "Save"
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
        case BookSearch
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
            case .BookSearch:
                "도서의 제목 또는 저자를 입력하세요."
            case .memoSearch:
                "메모를 검색하세요."
            case .title:
                "도서의 제목을 입력하세요."
            case .author:
                "도서의 저자를 입력하세요."
            case .memo:
                "메모를 입력하세요."
            case .category:
                "카테고리를 ','와 함께 입력하세요."
            case .feelings:
                "감정을 ','와 함께 입력하세요."
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
                "책 추천 키워드"
            }
        }
    }
}
    
