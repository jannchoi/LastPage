//
//  EditReadingInProgressViewController.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import UIKit
import SnapKit

final class EditReadingInProgressViewController: BaseViewController {
    var viewModel: EditReadingInProgressViewModel
    private let dateField = InfoFieldView(title: TextResource.InfoTextView.date.text)
    private let pageLabel : UILabel = {
        let label = UILabel()
        label.text = TextResource.InfoTextView.page.text
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    private let startPage = UITextField()
    let separatorLabel : UILabel = {
        let label = UILabel()
        label.text = TextResource.InfoTextView.separator.text
        label.textAlignment = .center
        return label
    }()

    private let endPage = UITextField()
    private let containerScrollView = UIScrollView()
    private let textView = UITextView()
    init(viewModel: EditReadingInProgressViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func configureHierarchy() {
        view.addSubview(dateField)
        view.addSubview(pageLabel)
        view.addSubview(startPage)
        view.addSubview(separatorLabel)
        view.addSubview(endPage)
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
        
        // Page label constraints
        pageLabel.snp.makeConstraints { make in
            make.top.equalTo(dateField.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(40)
            make.height.equalTo(30)
        }
        // End page constraints
        endPage.snp.makeConstraints { make in
            make.centerY.equalTo(pageLabel)
            make.trailing.equalToSuperview().inset(16)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        // separatorLabel
        separatorLabel.snp.makeConstraints { make in
            make.centerY.equalTo(endPage)
            make.trailing.equalTo(endPage.snp.leading).inset(8)
            make.width.equalTo(40)
        }
        // Start page constraints
        startPage.snp.makeConstraints { make in
            make.centerY.equalTo(pageLabel)
            make.trailing.equalTo(separatorLabel.snp.leading).inset(8)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }

        // Container scroll view constraints
        containerScrollView.snp.makeConstraints { make in
            make.top.equalTo(pageLabel.snp.bottom).offset(16)
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
        
        // Add toolbar with done button for date picker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: true)
        dateField.textField.inputAccessoryView = toolbar
        
        // Configure page fields
        startPage.placeholder = TextResource.Placeholder.page.text
        startPage.borderStyle = .roundedRect
        startPage.keyboardType = .numberPad
        startPage.font = .systemFont(ofSize: 14)
        
        endPage.placeholder = TextResource.Placeholder.page.text
        endPage.borderStyle = .roundedRect
        endPage.keyboardType = .numberPad
        endPage.font = .systemFont(ofSize: 14)
        
        
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
    }

    // MARK: - Actions and Helpers
    @objc private func doneButtonTapped() {
        if let datePicker = dateField.textField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateField.textField.text = dateFormatter.string(from: datePicker.date)
        }
        view.endEditing(true)
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

    // Clean up
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

}
