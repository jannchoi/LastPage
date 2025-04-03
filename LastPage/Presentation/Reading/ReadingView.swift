//
//  ReadingView.swift
//  LastPage
//
//  Created by 최정안 on 4/2/25.
//

import UIKit
import SnapKit
// MARK: - ReadingView
class ReadingView: UIScrollView {
    private let highlightContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    
    private let memoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureHierachy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateMemo(item: MemoEntity?) {
        guard let item = item else {return}
        dateLabel.text = item.date
        memoLabel.text = item.memo
    }
    private func configureView() {
        backgroundColor = .darkGray
        isScrollEnabled = true
    }
    private func configureHierachy() {
        addSubview(highlightContainerView)
        
        highlightContainerView.addSubview(dateLabel)
        highlightContainerView.addSubview(memoLabel)
    }
    
    private func configureLayout() {

        highlightContainerView.snp.makeConstraints { make in
            make.top.equalTo(contentLayoutGuide).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(16)
            make.bottom.equalTo(contentLayoutGuide).offset(-16)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
}
