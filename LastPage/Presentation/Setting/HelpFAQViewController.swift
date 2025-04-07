//
//  HelpFAQViewController.swift
//  LastPage
//
//  Created by 최정안 on 4/7/25.
//

import UIKit
import SnapKit

class HelpFAQViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Help & FAQ"
        view.backgroundColor = .backgroundBase
        setupLayout()
        setupContent()
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.axis = .vertical
        contentView.spacing = 16
        contentView.alignment = .fill

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.width.equalTo(scrollView)
        }
    }

    private func setupContent() {
        let faqs: [(String, String)] = [
            ("앱을 처음 시작했어요. 어떻게 사용하나요?", "도서 검색 후 책을 추가하고, 읽기 전/중/후 감상을 기록해보세요."),
            ("키워드는 어디서 확인하나요?", "도서를 선택 후 기록 화면에서 키워드를 확인할 수 있습니다."),
            ("도서 검색이 안돼요.", "검색 API 연결에 문제가 있을 수 있어요. 잠시 후 다시 시도해주세요."),
            ("기록은 어떻게 저장되나요?", "Realm을 통해 자동으로 저장되며, 앱을 삭제하면 기록도 사라집니다."),
            ("기록한 책을 검색할 수 있나요?", "검색 탭에서 제목, 태그, 카테고리 등으로 검색할 수 있습니다."),
            ("감정 태그는 무엇인가요?", "책을 읽고 느낀 감정을 간단한 키워드로 남길 수 있는 기능입니다.")
        ]

        for (question, answer) in faqs {
            let questionLabel = UILabel()
            questionLabel.text = "Q. " + question
            questionLabel.font = .boldSystemFont(ofSize: 14)
            questionLabel.numberOfLines = 0

            let answerLabel = UILabel()
            answerLabel.text = "A. " + answer
            answerLabel.font = .systemFont(ofSize: 13)
            answerLabel.numberOfLines = 0
            answerLabel.textColor = .darkGray

            contentView.addArrangedSubview(questionLabel)
            contentView.addArrangedSubview(answerLabel)
        }
    }
}
