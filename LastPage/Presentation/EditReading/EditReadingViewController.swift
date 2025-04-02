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
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(TextResource.ButtonTitle.save.text, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    deinit {
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
    }
    @objc private func saveButtonTapped() {
        guard let newMemo = textView.text else {return}
        let newValue = MemoEntity(date: dateField.textField.text, memo: newMemo)
        viewModel.saveBook(newValue: newValue)
    }
    private func setupUI(item: MemoEntity) {
        dateField.textField.text = item.date
        textView.text = item.memo
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
        
        // Text view constraints
        textView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(containerScrollView.snp.width).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

    override func configureView() {
        view.backgroundColor = .white
        containerScrollView.backgroundColor = .yellow
        textView.backgroundColor = .lightGray
        title = "Edit Reading"
        
        // Configure date field
        dateField.setPlaceholder(TextResource.Placeholder.date.text)
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        dateField.textField.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: true)
        dateField.textField.inputAccessoryView = toolbar
 
        // Configure text view
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.isScrollEnabled = true
        textView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        // Configure container scroll view
        containerScrollView.showsVerticalScrollIndicator = true
        containerScrollView.alwaysBounceVertical = true
        
        // Add keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        let helpBtn = UIBarButtonItem(customView: helpButton)
        let saveBtn = UIBarButtonItem(customView: saveButton)
        
        navigationItem.rightBarButtonItems = [saveBtn, helpBtn]
    }

    @objc private func doneButtonTapped() {
        if let datePicker = dateField.textField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateField.textField.text = dateFormatter.string(from: datePicker.date)
        }
        view.endEditing(true)
    }
    @objc private func helpButtonTapped() {
        coordinator?.showRecommend()
    }
 
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        containerScrollView.contentInset = contentInsets
        containerScrollView.scrollIndicatorInsets = contentInsets
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        containerScrollView.contentInset = .zero
        containerScrollView.scrollIndicatorInsets = .zero
    }

}
