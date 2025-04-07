//
//  AboutViewController.swift
//  LastPage
//
//  Created by 최정안 on 4/7/25.
//

import UIKit
import SnapKit

class AboutViewController: UIViewController {
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"
        view.backgroundColor = .backgroundBase
        setupLayout()
        setupContent()
    }

    private func setupLayout() {
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading

        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    private func setupContent() {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "‘마지막 페이지’는 독자의 감상으로 책을 완성합니다.\n\n책의 핵심 키워드, 작가의 의도 등을 바탕으로 보다 깊은 감상을 기록할 수 있도록 도와줍니다."
        descriptionLabel.numberOfLines = 0

        let versionLabel = UILabel()
        versionLabel.text = "버전: 1.0 (iOS 16 이상)"
        versionLabel.textColor = .darkGray

        let techLabel = UILabel()
        techLabel.text = "• 도서 검색: 알라딘 API (5,000콜/일)\n• 키워드 추천: ChatGPT API\n• 데이터 관리: Realm"
        techLabel.numberOfLines = 0
        techLabel.font = .systemFont(ofSize: 14)
        techLabel.textColor = .gray

        let contactLabel = UILabel()
        contactLabel.text = "문의: gongjo3695@gmail.com"
        contactLabel.textColor = .blue

        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(versionLabel)
        stackView.addArrangedSubview(techLabel)
        stackView.addArrangedSubview(contactLabel)
    }
}
