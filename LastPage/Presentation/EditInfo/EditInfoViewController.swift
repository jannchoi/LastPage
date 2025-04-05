//
//  EditInfoViewController.swift
//  LastPage
//
//  Created by 최정안 on 3/29/25.
//

import UIKit
import Combine
import SnapKit

final class EditInfoViewController: BaseViewController {
    private var cancellables: Set<AnyCancellable> = []
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
    private let changeImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 4
        return button
    }()
    private let clearImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 4
        return button
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
    private let categoryField = InfoFieldView(title: TextResource.InfoTextView.categories.text, isTaggable: true)
    private let feelingsField = InfoFieldView(title: TextResource.InfoTextView.feelings.text, isTaggable: true)
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(TextResource.ButtonTitle.save.text, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    // 선택된 이미지를 저장할 변수
    private var selectedImage: UIImage?
    // 원래 이미지 경로를 저장할 변수
    private var originalImagePath: String?
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
    override func bind() {
        viewModel.$bookDetail.sink {[weak self] bookDetail in
            guard let self = self, let bookDetail = bookDetail else {return}
            self.setupUI(item: bookDetail)
        }.store(in: &cancellables)
        viewModel.$fetchError.compactMap{$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showAlert(text: errorMessage)
            }.store(in: &cancellables)
        viewModel.$popVCTrigger.compactMap{$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self = self else {return}
                self.showAlert(text: message, action: {
                    self.navigationController?.popViewController(animated: true)
                })
            }.store(in: &cancellables)
    }
    func setupUI(item: BookDetailEntity) {
        originalImagePath = item.imagePath
        ImageFormatter.shared.setImage(target: bookCoverImageView, path: originalImagePath)
        titleField.textField.text = item.title
        authorField.textField.text = item.author
        shortMemoField.textField.text = item.shortMemo

        categoryField.setTags(item.categories)
        feelingsField.setTags(item.feelings)
        readingStatusSegmentControl.selectedSegmentIndex = item.status.segmentIndex
    }
    private func setImage(_ path: String?){
        let imgPath = path ?? TextResource.Global.empty.text
        
        if imgPath.hasPrefix("https://") {
            let url = URL(string: imgPath)
            bookCoverImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person"))
            bookCoverLabel.isHidden = true
        } else if imgPath.hasPrefix("local://") {
            let localPath = imgPath.replacingOccurrences(of: "local://", with: "")
            bookCoverImageView.image = UIImage(contentsOfFile: localPath)
            bookCoverLabel.isHidden = true
        } else {
            bookCoverImageView.image = nil
                    bookCoverLabel.isHidden = false
        }
        
    }
    
    @objc private func saveButtonTapped() {
        if let newTitle = titleField.textField.text, let newAuthor = authorField.textField.text, let newMemo = shortMemoField.textField.text{
            let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedAuthor = newAuthor.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedTitle.isEmpty && !trimmedAuthor.isEmpty {
                var imagePath: String? = originalImagePath
                
                // 새 이미지가 선택되었다면 저장
                if let selectedImage = selectedImage {
                    imagePath = ImageFormatter.shared.saveImageToLocal(image: selectedImage)
                }
                
                let newValue = BookDetailEntity(
                    imagePath: imagePath,
                    title: trimmedTitle,
                    author: trimmedAuthor,
                    status: ReadingStatusEntity.from(index: readingStatusSegmentControl.selectedSegmentIndex),
                    shortMemo: newMemo,
                    categories: categoryField.getTag(),
                    feelings: feelingsField.getTag()
                )
                viewModel.saveBook(newValue: newValue)
            }
            else {
                print("set up valid Title and Author")
            }
        }
    }
    @objc private func changeImageButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    @objc private func clearImageButtonTapped() {
        bookCoverImageView.image = nil
        selectedImage = nil
        originalImagePath = nil
        bookCoverLabel.isHidden = false
    }
    // MARK: - View 계층 구조 설정
    override func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [bookCoverImageView,changeImageButton,clearImageButton, bookCoverLabel, titleField, authorField,
         readingStatusSegmentControl, shortMemoField, categoryField,
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
        changeImageButton.snp.makeConstraints { make in
            make.bottom.equalTo(bookCoverImageView.snp.bottom)
            make.leading.equalTo(bookCoverImageView.snp.trailing).offset(16)
            make.size.equalTo(32)
        }
        clearImageButton.snp.makeConstraints { make in
            make.bottom.equalTo(bookCoverImageView.snp.bottom)
            make.leading.equalTo(changeImageButton.snp.trailing).offset(16)
            make.size.equalTo(32)
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
        
        categoryField.snp.makeConstraints { make in
            make.top.equalTo(shortMemoField.snp.bottom).offset(16)
            make.height.equalTo(90)
            make.horizontalEdges.equalTo(titleField)
        }
        
        feelingsField.snp.makeConstraints { make in
            make.top.equalTo(categoryField.snp.bottom).offset(16)
            make.height.equalTo(90)
            make.horizontalEdges.equalTo(titleField)
        }
    }
    
    // MARK: - 프로퍼티 속성 설정
    override func configureView() {
        view.backgroundColor = .white
        // 필드 placeholder 설정
        titleField.setPlaceholder(TextResource.Placeholder.title.text)
        authorField.setPlaceholder(TextResource.Placeholder.author.text)
        shortMemoField.setPlaceholder(TextResource.Placeholder.memo.text)
        categoryField.setPlaceholder(TextResource.Placeholder.category.text)
        feelingsField.setPlaceholder(TextResource.Placeholder.feelings.text)
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        changeImageButton.addTarget(self, action: #selector(changeImageButtonTapped), for: .touchUpInside)
        clearImageButton.addTarget(self, action: #selector(clearImageButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        // 태그 관련 콜백 설정
        categoryField.onTagAdded = { tag in
            print("Genre tag added: \(tag)")
        }
        
        categoryField.onTagRemoved = { tag in
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
extension EditInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            bookCoverImageView.image = editedImage
            selectedImage = editedImage
            bookCoverLabel.isHidden = true
        } else if let originalImage = info[.originalImage] as? UIImage {
            bookCoverImageView.image = originalImage
            selectedImage = originalImage
            bookCoverLabel.isHidden = false
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
