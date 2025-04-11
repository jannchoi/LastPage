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
    weak var coordinator: EditInfoCoordinator?
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let bookCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let bookCoverLabel: UILabel = {
        let label = UILabel()
        label.text = TextResource.Global.none.text
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = .mainText
        return label
    }()
    private let changeImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .btnTint
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 4
        return button
    }()
    private let clearImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .btnTint
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 4
        return button
    }()
    
    private let titleField = InfoFieldView(title: TextResource.InfoTextView.title.text)
    private let authorField = InfoFieldView(title: TextResource.InfoTextView.author.text)
    private let shortMemoField = InfoFieldView(title: TextResource.InfoTextView.shortMemo.text)
    let categoryField = InfoFieldView(title: TextResource.InfoTextView.categories.text, isTaggable: true)
    private let feelingsField = InfoFieldView(title: TextResource.InfoTextView.feelings.text, isTaggable: true)
    
    private let readingStatusSegmentControl: UISegmentedControl = {
        let items = [TextResource.ReadingStatus.before.text, TextResource.ReadingStatus.inProgress.text, TextResource.ReadingStatus.after.text]
        let segmentControl = UISegmentedControl(items: items)
        segmentControl.selectedSegmentIndex = 0
        return segmentControl
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(TextResource.ButtonTitle.save.text, for: .normal)
        button.setTitleColor(.btnTint, for: .normal)
        return button
    }()
    private var selectedImage: UIImage?
    private var originalImagePath: String?
    
    // Keyboard handling properties
    private var initialScrollViewInsets: UIEdgeInsets?
    private var activeTextField: UITextField?
    private var keyboardHeight: CGFloat = 0
    private let keyboardTopPadding: CGFloat = 20
    private var isKeyboardVisible = false
    
    // Store the original content offset to restore later
    private var originalContentOffset: CGPoint = .zero

    init(viewModel: EditInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardObservers()
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
            make.bottom.equalToSuperview()
        }
        
        bookCoverImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
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
            make.bottom.equalToSuperview().inset(32)
        }
    }
    
    private func setupKeyboardObservers() {
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // Add tap gesture to dismiss keyboard when tapping outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Set delegates for text fields to track the active field
        [titleField, authorField, shortMemoField, categoryField, feelingsField].forEach {
            $0.textField.delegate = self
        }
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              // Skip if the active field is category or feelings
              activeTextField != categoryField.textField &&
              activeTextField != feelingsField.textField else {
            return
        }
        
        // Save initial scroll insets if not already saved
        if initialScrollViewInsets == nil {
            initialScrollViewInsets = scrollView.contentInset
        }
        
        // Calculate keyboard height in view coordinates
        keyboardHeight = keyboardFrame.height
        isKeyboardVisible = true
        
        // Adjust view for currently active text field if exists
        if let activeField = activeTextField {
            adjustScrollViewForTextField(activeField)
        }
    }

    private func adjustScrollViewForTextField(_ textField: UITextField) {
        guard isKeyboardVisible,
              let activeInfoField = getInfoFieldView(for: textField) else {
            return
        }
        
        // Calculate the bottom of the active field in window coordinates
        let activeFieldBottom = activeInfoField.convert(activeInfoField.bounds, to: nil).maxY
        
        // Calculate keyboard top position in window coordinates
        let keyboardTop = UIScreen.main.bounds.height - keyboardHeight
        
        // Check if the active field is covered by keyboard
        if activeFieldBottom > keyboardTop - keyboardTopPadding {
            // Calculate how much we need to scroll to make the field visible
            let scrollPoint = activeFieldBottom - (keyboardTop - keyboardTopPadding)
            
            // Set content inset to ensure scrollability
            let bottomInset = keyboardHeight
            scrollView.contentInset = UIEdgeInsets(
                top: initialScrollViewInsets?.top ?? 0,
                left: initialScrollViewInsets?.left ?? 0,
                bottom: bottomInset,
                right: initialScrollViewInsets?.right ?? 0
            )
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            
            // Scroll to make the field visible with padding
            let contentOffset = CGPoint(
                x: 0,
                y: scrollView.contentOffset.y + scrollPoint
            )
            scrollView.setContentOffset(contentOffset, animated: true)
        }
    }
    
    // New method to adjust view for category presentation
    private func adjustViewForCategoryPresentation() {
        // Store the current content offset to restore later
        originalContentOffset = scrollView.contentOffset
        
        // Calculate the position to show categoryField with 16pt gap above presented VC
        let categoryFieldBottom = categoryField.convert(categoryField.bounds, to: nil).maxY
        let targetY = categoryFieldBottom - view.frame.height + 16
        
        // Only scroll if needed
        if targetY > scrollView.contentOffset.y {
            let contentOffset = CGPoint(x: 0, y: targetY)
            scrollView.setContentOffset(contentOffset, animated: true)
        }
    }
    
    // New method to adjust view for feelings presentation
    private func adjustViewForFeelingsPresentation() {
        // Store the current content offset to restore later
        originalContentOffset = scrollView.contentOffset
        
        // Calculate the position to show feelingsField with 16pt gap above presented VC
        let feelingsFieldBottom = feelingsField.convert(feelingsField.bounds, to: nil).maxY
        let targetY = feelingsFieldBottom - view.frame.height + 16
        
        // Only scroll if needed
        if targetY > scrollView.contentOffset.y {
            let contentOffset = CGPoint(x: 0, y: targetY)
            scrollView.setContentOffset(contentOffset, animated: true)
        }
    }
    
    // Method to restore view position when category/feelings VC is dismissed
    func restoreViewPosition() {
        scrollView.setContentOffset(originalContentOffset, animated: true)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        // Skip restoration if we're presenting category or feelings
        if activeTextField == categoryField.textField || activeTextField == feelingsField.textField {
            return
        }
        
        // Restore original insets
        if let insets = initialScrollViewInsets {
            scrollView.contentInset = insets
            scrollView.scrollIndicatorInsets = insets
        }
        
        // Reset keyboard state
        isKeyboardVisible = false
        keyboardHeight = 0
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // Helper method to get the InfoFieldView parent of a text field
    private func getInfoFieldView(for textField: UITextField) -> InfoFieldView? {
        var view = textField.superview
        while view != nil {
            if let infoFieldView = view as? InfoFieldView {
                return infoFieldView
            }
            view = view?.superview
        }
        return nil
    }

    // Clean up observers when view controller is deallocated
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
   
    func setupUI(item: BookDetailEntity) {
        originalImagePath = item.imagePath
        ImageFormatter.shared.setImage(target: bookCoverImageView, path: originalImagePath)
        isValidImage()
        navigationItem.title = item.title
        titleField.textField.text = item.title
        authorField.textField.text = item.author
        shortMemoField.textField.text = item.shortMemo

        categoryField.setTags(item.categories)
        feelingsField.setTags(item.feelings)
        readingStatusSegmentControl.selectedSegmentIndex = item.status.segmentIndex
    }
    
    private func isValidImage(){
        
        bookCoverLabel.isHidden = bookCoverImageView.image == nil ? false : true

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
                    imagePath: imagePath, addedDate: viewModel.bookDetail?.addedDate,
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
    

    // MARK: - 프로퍼티 속성 설정
    override func configureView() {
        view.backgroundColor = .backgroundBase
        // 필드 placeholder 설정
        titleField.setPlaceholder(TextResource.Placeholder.title.text)
        authorField.setPlaceholder(TextResource.Placeholder.author.text)
        shortMemoField.setPlaceholder(TextResource.Placeholder.memo.text)
        categoryField.setPlaceholder(TextResource.Placeholder.category.text)
        feelingsField.setPlaceholder(TextResource.Placeholder.feelings.text)
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        changeImageButton.addTarget(self, action: #selector(changeImageButtonTapped), for: .touchUpInside)
        clearImageButton.addTarget(self, action: #selector(clearImageButtonTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)

    }
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
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

extension EditInfoViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        
        // Special handling for category and feelings fields
        if textField == categoryField.textField {
            // Dismiss keyboard to avoid conflicts
            textField.resignFirstResponder()
            // Present the category list VC
            coordinator?.showCategories()
            adjustViewForCategoryPresentation()
        } else if textField == feelingsField.textField {
            // Dismiss keyboard to avoid conflicts
            textField.resignFirstResponder()
            // Similar handling for feelings if needed
            coordinator?.showFeelings() // Change to showFeelings() when available
            adjustViewForFeelingsPresentation()
        } else if isKeyboardVisible {
            // For other fields, keep the keyboard adjustment
            adjustScrollViewForTextField(textField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Focus가 끝난 텍스트필드가 현재 액티브 필드면 초기화
        if activeTextField == textField {
            activeTextField = nil
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleField.textField {
            authorField.textField.becomeFirstResponder()
        } else if textField == authorField.textField {
            shortMemoField.textField.becomeFirstResponder()
        } else if textField == shortMemoField.textField {
            // 여기서 categoryField는 직접 포커스를 주지 말고 키보드 닫기
            textField.resignFirstResponder()
            return true
        }

        return true
    }
}


protocol EditInfoViewControllerDelegate: AnyObject {
    func updateTags(_ view: CategoryListViewController, categories: [String], type: TagType)
}
extension EditInfoViewController: EditInfoViewControllerDelegate {

    func updateTags(_ view: CategoryListViewController, categories: [String], type: TagType) {
        switch type {
        case .category:
            for category in categories {
                categoryField.addTag(category)
            }
        case .feeling:
            for category in categories {
                feelingsField.addTag(category)
            }
        }
        
    }
    
    
}
