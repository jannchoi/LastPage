//
//  RecommendViewController.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import UIKit
import Combine
import SnapKit

final class RecommendViewController: BaseViewController {
    var viewModel: RecommendViewModel
    private var cancellables: Set<AnyCancellable> = []
    private var activityIndicator = LoadingIndicator(frame: .zero)
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let bookRecommendView = UIView()

    
    private let bookLabel: UILabel = {
        let label = UILabel()
        label.text = TextResource.SectionHeader.bookKeywrod.text
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let bookKeywordStackView = KeywordStackView()
    
    private let commonLabel: UILabel = {
        let label = UILabel()
        label.text = TextResource.SectionHeader.commonKeyword.text
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let commonKeywordStackView = KeywordStackView(isVertical: true)
    
    init(viewModel: RecommendViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        print(#function)
        configureKeywords()
    }

    override func bind() {
        viewModel.$keywordData.receive(on: DispatchQueue.main)
            .sink { [weak self] keywords in
            guard let self = self, let keywords = keywords else {return}
            self.bookKeywordStackView.configure(with: keywords)
                self.activityIndicator.stopAnimating()
        }.store(in: &cancellables)
        
        viewModel.$bookTitle.sink {[weak self] booktitle in
            guard let self = self else {return}
            self.setNavTiitle(title: booktitle)
        }.store(in: &cancellables)
        
        
        viewModel.$error.compactMap{$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] networkError in
                self?.showAlert(text: networkError.errorMessage)
            }.store(in: &cancellables)
        
        viewModel.$fetchError.compactMap{$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showAlert(text: errorMessage)
            }.store(in: &cancellables)
    }
    private func setNavTiitle(title: String?) {
        navigationItem.title = title != nil ? title : "Edit Reading"
    }
    override func configureHierarchy() {
        view.addSubview(scrollView)
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(bookLabel)
        contentView.addSubview(bookRecommendView)
        bookRecommendView.addSubview(bookKeywordStackView)
        contentView.addSubview(commonLabel)
        contentView.addSubview(commonKeywordStackView)
    }
    
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        bookLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(16)
        }
        
        bookRecommendView.snp.makeConstraints { make in
            make.top.equalTo(bookLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
        }
        
        bookKeywordStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        }
        
        commonLabel.snp.makeConstraints { make in
            make.top.equalTo(bookRecommendView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
        }
        
        commonKeywordStackView.snp.makeConstraints { make in
            make.top.equalTo(commonLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    override func configureView() {
        view.backgroundColor = .backgroundBase
        activityIndicator.center = view.center
        bookRecommendView.backgroundColor = .backgroundBase
        bookRecommendView.layer.cornerRadius = 10
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
    }
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    private func configureKeywords() {
        commonKeywordStackView.configure(with: TextDataStorage.commonKeywordMockData)
    }
}

extension RecommendViewController {
   private class KeywordStackView: UIStackView {
        private let isVertical: Bool
        
        init(isVertical: Bool = false) {
            self.isVertical = isVertical
            super.init(frame: .zero)
            self.axis = .vertical
            self.spacing = 10
            self.alignment = .leading
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configure(with keywords: [String]) {
            self.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            if isVertical {
                for keyword in keywords {
                    let keywordView = KeywordView(text: keyword)
                    self.addArrangedSubview(keywordView)
                }
            } else {
                let horizontalSpacing: CGFloat = 8
                let maxWidth = UIScreen.main.bounds.width - 32
                
                var currentLineStack = UIStackView()
                currentLineStack.axis = .horizontal
                currentLineStack.spacing = horizontalSpacing
                currentLineStack.alignment = .leading
                
                var currentLineWidth: CGFloat = 0
                
                for keyword in keywords {
                    let keywordView = KeywordView(text: keyword)
                    let keywordWidth = keywordView.intrinsicContentSize.width
                    
                    if currentLineWidth + keywordWidth + (currentLineStack.arrangedSubviews.isEmpty ? 0 : horizontalSpacing) > maxWidth {
                        self.addArrangedSubview(currentLineStack)
                        currentLineStack = UIStackView()
                        currentLineStack.axis = .horizontal
                        currentLineStack.spacing = horizontalSpacing
                        currentLineStack.alignment = .leading
                        currentLineWidth = 0
                    }
                    
                    currentLineStack.addArrangedSubview(keywordView)
                    currentLineWidth += keywordWidth + (currentLineStack.arrangedSubviews.isEmpty ? 0 : horizontalSpacing)
                }
                
                if !currentLineStack.arrangedSubviews.isEmpty {
                    self.addArrangedSubview(currentLineStack)
                }
            }
        }
    }

    private class KeywordView: UIView {
        private let label = UILabel()
        
        init(text: String) {
            super.init(frame: .zero)
            label.text = text
            label.font = .systemFont(ofSize: 14)
            label.textAlignment = .left
            label.textColor = .mainText
            label.numberOfLines = 0
            label.setContentHuggingPriority(.required, for: .horizontal)
            self.backgroundColor = .tagBackground
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor.tagBorder.cgColor
            self.layer.cornerRadius = 15
            
            self.addSubview(label)
            label.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12))
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var intrinsicContentSize: CGSize {
            return CGSize(width: label.intrinsicContentSize.width + 24, height: label.intrinsicContentSize.height + 12)
        }
    }

}
