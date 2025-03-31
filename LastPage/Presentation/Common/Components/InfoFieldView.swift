//
//  InfoFieldView.swift
//  LastPage
//
//  Created by 최정안 on 3/29/25.
//

import UIKit
import SnapKit

final class InfoFieldView: UIView {
    private let infoLabel = UILabel()
    var textField = UITextField()
    private let tagsScrollView = UIScrollView()
    private let tagsStackView = UIStackView()
    
    private var tags: [String] = []
    
    
    var onTagAdded: ((String) -> Void)?
    var onTagRemoved: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        isUserInteractionEnabled = true
    }
    
    init(title: String) {
        super.init(frame: .zero)
        infoLabel.text = title
        configureView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        infoLabel.font = .systemFont(ofSize: 14, weight: .medium)
        infoLabel.textColor = .black
        
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)
        
        tagsScrollView.showsHorizontalScrollIndicator = false
        tagsScrollView.alwaysBounceHorizontal = true
        
        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 8
        tagsStackView.alignment = .leading
        
        tagsScrollView.addSubview(tagsStackView)
        
        addSubview(infoLabel)
        addSubview(textField)
        addSubview(tagsScrollView)
        
        infoLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
        
        tagsScrollView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        tagsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    func setPlaceholder(_ placeholder: String) {
        textField.placeholder = placeholder
    }
    
    func addTag(_ tag: String) {
        guard !tag.isEmpty, !tags.contains(tag) else { return }
        
        tags.append(tag)
        updateTagsView()
        onTagAdded?(tag)
    }
    
    func removeTag(_ tag: String) {
        guard let index = tags.firstIndex(of: tag) else { return }
        
        tags.remove(at: index)
        updateTagsView()
        onTagRemoved?(tag)
    }
    
    func setTags(_ newTags: [String]) {
        tags = newTags
        updateTagsView()
    }
    
    private func updateTagsView() {
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for tag in tags {
            let tagButton = createTagButton(with: tag)
            tagsStackView.addArrangedSubview(tagButton)
        }
        
        let totalWidth = tagsStackView.arrangedSubviews.reduce(0) { $0 + $1.intrinsicContentSize.width + 8 }
        
        tagsStackView.snp.remakeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(totalWidth)
        }
        
        
        tagsScrollView.contentSize = CGSize(width: totalWidth, height: 40)
        tagsStackView.superview?.layoutIfNeeded()
    }
    
    
    private func createTagButton(with title: String) -> UIButton {
        let button = TagButton(title: title)
        button.addTarget(self, action: #selector(tagButtonTapped), for: .touchUpInside)
        return button
    }
    
    
    @objc private func tagButtonTapped(_ sender: UIButton) {
        guard let title = sender.configuration?.title else { return }
        print(title)
        removeTag(title)
    }
    
    @objc private func textFieldDidReturn(_ sender: UITextField) {
        guard let text = sender.text, !text.isEmpty else { return }
        
        let newTags = text.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        for tag in newTags {
            if !tag.isEmpty {
                addTag(tag)
            }
        }
        
        sender.text = TextResource.Global.empty.text
    }
}
extension InfoFieldView {
    private final class TagButton: UIButton {
        private let padding = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        private let imagePadding: CGFloat = 6
        private let imageSize: CGFloat = 13
        
        init(title: String) {
            super.init(frame: .zero)
            
            var config = UIButton.Configuration.filled()
            config.title = title
            config.baseForegroundColor = .white
            config.baseBackgroundColor = .systemGray
            config.cornerStyle = .capsule
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            
            let imageConfig = UIImage.SymbolConfiguration(pointSize: imageSize, weight: .bold)
            let xImage = UIImage(systemName: "xmark", withConfiguration: imageConfig)
            
            config.image = xImage
            config.imagePlacement = .trailing
            config.imagePadding = imagePadding
            
            self.configuration = config
            self.setAttributedTitle(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.white]), for: .normal)
            
            self.setContentHuggingPriority(.required, for: .horizontal)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}
