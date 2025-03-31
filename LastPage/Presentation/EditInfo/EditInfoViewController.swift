//
//  EditInfoViewController.swift
//  LastPage
//
//  Created by 최정안 on 3/29/25.
//

import UIKit
import SnapKit

final class EditInfoViewController: BaseViewController {
    var viewModel: EditInfoViewModel
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let bookCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let bookCoverLabel: UILabel = {
        let label = UILabel()
        label.text = TextResource.Global.none.text
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
   
    private let titleField = InfoFieldView(title: TextResource.InfoTextView.title.text)
    private let authorField = InfoFieldView(title: TextResource.InfoTextView.author.text)
    
    private let readingStatusSegmentControl: UISegmentedControl = {
        let items = [TextResource.ReadingStatus.before.text, TextResource.ReadingStatus.inProgress.text, TextResource.ReadingStatus.after.text]
        let segmentControl = UISegmentedControl(items: items)
        segmentControl.selectedSegmentIndex = 0
        return segmentControl
    }()
    
    private let shortMemoField = InfoFieldView(title: TextResource.InfoTextView.shortMemo.text)
    private let genreField = InfoFieldView(title: TextResource.InfoTextView.categories.text)
    private let feelingsField = InfoFieldView(title: TextResource.InfoTextView.feelings.text)
    
    init(viewModel: EditInfoViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - View 계층 구조 설정
    override func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [bookCoverImageView, bookCoverLabel, titleField, authorField,
         readingStatusSegmentControl, shortMemoField, genreField,
         feelingsField].forEach {
            contentView.addSubview($0)
        }
    }
    
    // MARK: - View 레이아웃 설정
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.width.equalTo(scrollView)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        bookCoverImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(145)
        }
        
        bookCoverLabel.snp.makeConstraints { make in
            make.centerX.equalTo(bookCoverImageView)
            make.centerY.equalTo(bookCoverImageView)
        }
        
        titleField.snp.makeConstraints { make in
            make.top.equalTo(bookCoverImageView.snp.bottom).offset(24)
            make.height.equalTo(50)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        authorField.snp.makeConstraints { make in
            make.top.equalTo(titleField.snp.bottom).offset(16)
            make.height.equalTo(50)
            make.horizontalEdges.equalTo(titleField)
        }
        
        readingStatusSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(authorField.snp.bottom).offset(18)
            make.horizontalEdges.equalTo(titleField)
        }
        
        shortMemoField.snp.makeConstraints { make in
            make.top.equalTo(readingStatusSegmentControl.snp.bottom).offset(6)
            make.height.equalTo(50)
            make.horizontalEdges.equalTo(titleField)
        }
        
        genreField.snp.makeConstraints { make in
            make.top.equalTo(shortMemoField.snp.bottom).offset(16)
            make.height.equalTo(90)
            make.horizontalEdges.equalTo(titleField)
        }
        
        feelingsField.snp.makeConstraints { make in
            make.top.equalTo(genreField.snp.bottom).offset(16)
            make.height.equalTo(90)
            make.horizontalEdges.equalTo(titleField)
        }
    }
    
    // MARK: - 프로퍼티 속성 설정
    override func configureView() {
        view.backgroundColor = .white
        // 초기 태그 설정
        genreField.setTags(["공포", "스릴러", "유머", "코미디"])
        feelingsField.setTags(["무서움", "짜릿함", "통쾌"])

        // 필드 placeholder 설정
        titleField.setPlaceholder(TextResource.Placeholder.title.text)
        authorField.setPlaceholder(TextResource.Placeholder.author.text)
        shortMemoField.setPlaceholder(TextResource.Placeholder.memo.text)
        genreField.setPlaceholder(TextResource.Placeholder.category.text)
        feelingsField.setPlaceholder(TextResource.Placeholder.feelings.text)
        
        // 태그 관련 콜백 설정
        genreField.onTagAdded = { tag in
            print("Genre tag added: \(tag)")
        }
        
        genreField.onTagRemoved = { tag in
            print("Genre tag removed: \(tag)")
        }
        
        feelingsField.onTagAdded = { tag in
            print("Feeling tag added: \(tag)")
        }
        
        feelingsField.onTagRemoved = { tag in
            print("Feeling tag removed: \(tag)")
        }
    }
}
