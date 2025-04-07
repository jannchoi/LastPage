//
//  EditReadingViewController.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import UIKit
import Combine
import SnapKit

final class EditReadingViewController: BaseViewController {
    weak var coordinator: EditReadingCoordinator?
    var viewModel: EditReadingViewModel
    private var cancellables: Set<AnyCancellable> = []
    private let dateField = InfoFieldView(title: TextResource.InfoTextView.date.text)

    private let containerScrollView = UIScrollView()
    private let textView = UITextView()
    private let helpButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(TextResource.ButtonTitle.help.text, for: .normal)
        button.setTitleColor(.btnTint, for: .normal)
        return button
    }()
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(TextResource.ButtonTitle.save.text, for: .normal)
        button.setTitleColor(.btnTint, for: .normal)
        return button
    }()
    
    // Track cursor position
    private var activeTextView: UITextView?
    private var currentCursorPosition: CGRect?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        coordinator?.popVC()
    }
    
    init(viewModel: EditReadingViewModel) {
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
        viewModel.$bookDetail.sink {[weak self] memoDetail in
            guard let self = self, let memoDetail = memoDetail else {return}
            self.setupUI(item: memoDetail)
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
    
    @objc private func saveButtonTapped() {
        guard let newMemo = textView.text else {return}
        let newValue = MemoEntity(date: DateFormattManager.shared.strToDate(dateField.textField.text) , memo: newMemo)
        viewModel.saveBook(newValue: newValue)
    }
    
    private func setupUI(item: MemoEntity) {
        dateField.textField.text = DateFormattManager.shared.dateToStr(item.date)
        textView.text = item.memo
        // Trigger text view height update when setting text initially
        textViewDidChange(textView)
    }
    
    override func configureHierarchy() {
        view.addSubview(dateField)
        view.addSubview(containerScrollView)
        containerScrollView.addSubview(textView)
    }
    
    override func configureLayout() {
        // Date field constraints
        dateField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }

        // Container scroll view constraints
        containerScrollView.snp.makeConstraints { make in
            make.top.equalTo(dateField.snp.bottom).offset(16)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        // Text view constraints - remove fixed height to allow for dynamic sizing
        textView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(containerScrollView.snp.width).inset(16)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-16) // Add bottom padding
        }
    }

    override func configureView() {
        view.backgroundColor = .backgroundBase
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        containerScrollView.backgroundColor = .white
        textView.backgroundColor = .white
        textView.makeShadow()
        title = "Edit Reading"
        
        // Configure date field
        dateField.setPlaceholder(TextResource.Placeholder.date.text)
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        dateField.textField.inputView = datePicker

        // Configure text view
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.isScrollEnabled = false // Disable scrolling within textView
        textView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.delegate = self // Set delegate to handle text changes
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        doneButton.tintColor = .btnTint
        let toolbar1 = UIToolbar()
        toolbar1.sizeToFit()
        toolbar1.setItems([doneButton], animated: true)
        
        
    
        textView.inputAccessoryView = toolbar1
        dateField.textField.inputAccessoryView = toolbar1
        
        // Configure container scroll view
        containerScrollView.showsVerticalScrollIndicator = true
        containerScrollView.alwaysBounceVertical = true
        containerScrollView.keyboardDismissMode = .interactive
        
        // Add keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Add text selection notification
        NotificationCenter.default.addObserver(self, selector: #selector(textViewTextDidChange), name: UITextView.textDidChangeNotification, object: nil)
        
        helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        let helpBtn = UIBarButtonItem(customView: helpButton)
        let saveBtn = UIBarButtonItem(customView: saveButton)
        
        
        if viewModel.status == .unread {
            navigationItem.rightBarButtonItem = saveBtn
        } else {
            navigationItem.rightBarButtonItems = [saveBtn, helpBtn]
        }
    }
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    @objc private func doneButtonTapped() {
        if let datePicker = dateField.textField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd"
            dateField.textField.text = dateFormatter.string(from: datePicker.date)
        }
        view.endEditing(true)
    }
    
    @objc private func helpButtonTapped() {
        guard let bookId = viewModel.bookId else {return}
        coordinator?.showRecommend(bookId: bookId)
    }
    
    @objc private func textViewTextDidChange(_ notification: Notification) {
        if let textView = notification.object as? UITextView, textView == self.textView {
            updateCursorPosition()
        }
    }
    
    private func updateCursorPosition() {
        guard let selectedRange = textView.selectedTextRange else { return }
        let cursorPosition = textView.caretRect(for: selectedRange.start)
        currentCursorPosition = textView.convert(cursorPosition, to: containerScrollView)
        
        // If keyboard is shown, ensure cursor is visible
        if let keyboardHeight = keyboardHeight {
            adjustScrollPositionIfNeeded(keyboardHeight: keyboardHeight)
        }
    }
 
    private var keyboardHeight: CGFloat?
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        keyboardHeight = keyboardSize.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        containerScrollView.contentInset = contentInsets
        containerScrollView.scrollIndicatorInsets = contentInsets
        
        // Make sure cursor is visible
        updateCursorPosition()
        adjustScrollPositionIfNeeded(keyboardHeight: keyboardSize.height)
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = nil
        containerScrollView.contentInset = .zero
        containerScrollView.scrollIndicatorInsets = .zero
    }
    
    private func adjustScrollPositionIfNeeded(keyboardHeight: CGFloat) {
        guard let cursorPositionInScrollView = currentCursorPosition else { return }
        
        // Calculate the position of cursor relative to window
        let cursorPositionInWindow = containerScrollView.convert(cursorPositionInScrollView, to: nil)
        
        // Calculate keyboard top position (screen height - keyboard height)
        let keyboardTopPosition = UIScreen.main.bounds.height - keyboardHeight
        
        // Add padding so cursor isn't right at the keyboard edge
        let padding: CGFloat = 16
        
        // Check if cursor position is below keyboard top position
        if cursorPositionInWindow.maxY > keyboardTopPosition - padding {
            // Calculate how much we need to scroll to show cursor
            let scrollOffset = cursorPositionInWindow.maxY - (keyboardTopPosition - padding)
            
            // Adjust content offset
            let newOffset = containerScrollView.contentOffset.y + scrollOffset
            containerScrollView.setContentOffset(CGPoint(x: 0, y: newOffset), animated: true)
        }
    }
}

// MARK: - UITextViewDelegate
extension EditReadingViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // Calculate the new height of the text view based on its content
        let sizeThatFits = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        // Update the height constraint of the text view
        textView.snp.updateConstraints { make in
            make.height.equalTo(max(100, sizeThatFits.height)) // Set minimum height to 100
        }
        
        // Update the content size of the container scroll view
        containerScrollView.layoutIfNeeded()
        
        // Update cursor position for keyboard visibility
        updateCursorPosition()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
        updateCursorPosition()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = nil
    }
}
