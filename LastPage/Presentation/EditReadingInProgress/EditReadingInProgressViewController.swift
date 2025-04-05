//
//  EditReadingInProgressViewController.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import UIKit
import Combine
import SnapKit
import VisionKit
import Vision
import NaturalLanguage
final class EditReadingInProgressViewController: BaseViewController {
    var viewModel: EditReadingInProgressViewModel
    private var cancellables: Set<AnyCancellable> = []
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(TextResource.ButtonTitle.save.text, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
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

    private let cameraButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.viewfinder"), for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    
    private var scannedText: String = ""
    private var extractedSentences: [String] = []
    private var textSelectionViewController: TextSelectionViewController?
    
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
    @objc private func cameraButtonTapped() {
        // Check if document scanning is available
        if VNDocumentCameraViewController.isSupported {
            let scannerViewController = VNDocumentCameraViewController()
            scannerViewController.delegate = self
            present(scannerViewController, animated: true)
        } else {
            let alert = UIAlertController(
                title: "스캐닝 불가",
                message: "이 기기에서는 문서 스캐닝을 지원하지 않습니다.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
        }
    }

    // Process scanned images and extract text
    private func processImages(_ images: [UIImage]) {
        // Show loading indicator
        let loadingAlert = UIAlertController(title: "처리 중", message: "텍스트를 인식하고 있습니다...", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        let group = DispatchGroup()
        var allText = ""
        
        for image in images {
            group.enter()
            recognizeText(in: image) { text in
                if let text = text, !text.isEmpty {
                    allText += text + "\n"
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Dismiss loading indicator
            loadingAlert.dismiss(animated: true) {
                // Split the text into sentences
                self.extractedSentences = self.splitIntoSentences(allText)
                self.showTextSelectionView()
            }
        }
    }

    // Text recognition using Vision framework
    private func recognizeText(in image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("Text recognition error: \(error)")
                completion(nil)
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            completion(recognizedText)
        }
        
        // Configure for accurate text recognition
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["ko-KR", "en-US"] // 한국어와 영어 지원
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform text recognition: \(error)")
            completion(nil)
        }
    }

    // Split text into sentences using NLTokenizer
    private func splitIntoSentences(_ text: String) -> [String] {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        
        var sentences: [String] = []
        
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            let sentence = String(text[tokenRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentence.isEmpty {
                sentences.append(sentence)
            }
            return true
        }
        
        // 문장이 너무 적으면 줄바꿈을 기준으로 한번 더 분리
        if sentences.count <= 3 {
            var lineBasedSentences: [String] = []
            for sentence in sentences {
                let lines = sentence.components(separatedBy: .newlines)
                for line in lines {
                    let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmedLine.isEmpty {
                        lineBasedSentences.append(trimmedLine)
                    }
                }
            }
            return lineBasedSentences
        }
        
        return sentences
    }

    // Show text selection view
    private func showTextSelectionView() {
        if extractedSentences.isEmpty {
            let alert = UIAlertController(
                title: "텍스트 인식 실패",
                message: "스캔한 이미지에서 텍스트를 찾을 수 없습니다. 다시 시도해주세요.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let textSelectionVC = TextSelectionViewController(textItems: extractedSentences)
        textSelectionVC.delegate = self
        textSelectionVC.allowMultipleSelection = true
        textSelectionViewController = textSelectionVC
        
        let navController = UINavigationController(rootViewController: textSelectionVC)
        present(navController, animated: true)
    }

    private func setupUI(item: ProgressMemoEntity) {
        dateField.textField.text = item.date
        textView.text = item.memo
        startPage.text = "\(item.startPage!)"
        endPage.text = "\(item.endPage!)"
        
    }
    @objc private func saveButtonTapped() {
        print("saceButtonTapped")
        guard let newMemo = textView.text else {return}
        let newValue = ProgressMemoEntity(startPage: startPage.text, endPage: endPage.text, date: dateField.textField.text, memo: newMemo)
        viewModel.saveBook(newValue: newValue)
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
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: cameraButton),UIBarButtonItem(customView: saveButton)]
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
extension EditReadingInProgressViewController: TextSelectionViewControllerDelegate {
    func didSelectTexts(_ texts: [String]) {
        let selectedText = texts.joined(separator: "\n\n")
        textView.text = textView.text.isEmpty ? selectedText : textView.text + "\n\n" + selectedText
    }
}
// MARK: - VNDocumentCameraViewControllerDelegate
extension EditReadingInProgressViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        var scannedImages: [UIImage] = []
        
        for pageIndex in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageIndex)
            scannedImages.append(image)
        }
        
        controller.dismiss(animated: true) {
            self.processImages(scannedImages)
        }
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true) {
            let alert = UIAlertController(
                title: "스캐닝 오류",
                message: "문서 스캐닝 중 오류가 발생했습니다: \(error.localizedDescription)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
        }
    }
}
