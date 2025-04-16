//
//  StatisticsViewController.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import UIKit
import SnapKit
import Combine
import FSCalendar

class StatisticsViewController: BaseViewController, UIViewControllerTransitioningDelegate {
    weak var coordinator: StatsCoordinator?
    var viewModel: StatsViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var titleLabel = UILabel()
    private lazy var booksThisMonthView = UIView()
    private lazy var booksThisMonthTitleLabel = UILabel()
    private lazy var booksThisMonthCountLabel = UILabel()
    private lazy var booksThisMonthIconImageView = UIImageView()
    private lazy var totalBooksView = UIView()
    private lazy var totalBooksTitleLabel = UILabel()
    private lazy var totalBooksCountLabel = UILabel()
    private lazy var totalBooksIconImageView = UIImageView()
    private lazy var booksThisYearhView = UIView()
    private lazy var booksThisYearTitleLabel = UILabel()
    private lazy var booksThisYearCountLabel = UILabel()
    private lazy var booksThisYearIconImageView = UIImageView()
    // Calendar
    private lazy var calendarContainerView: UIView = {
         let view = UIView()
         view.backgroundColor = .systemBackground
         view.makeShadow()
         return view
     }()

    private lazy var calendarView: FSCalendar = {
        let calendar = FSCalendar()
        calendar.delegate = self
        calendar.dataSource = self
        calendar.appearance.todayColor = .btnTint.withAlphaComponent(0.3)
        calendar.appearance.selectionColor = .btnTint
        calendar.appearance.eventDefaultColor = .accentTint
        calendar.appearance.eventSelectionColor = .white
        return calendar
    }()
    // 최상단에 다음 프로퍼티 추가
    private lazy var monthYearPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()

    private lazy var pickerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.makeShadow()
        view.isHidden = true
        return view
    }()

    private lazy var pickerDoneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.accentTint, for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    private let yearLabel = UILabel()
    private let separatorLine = UIView()
    private var years: [Int] = []
    
    private var selectedYear = Calendar.current.component(.year, from: Date())
    private var selectedMonth = Calendar.current.component(.month, from: Date()) - 1 // 0-based index
    
    private var contentViewOriginalCenter: CGPoint?
    
    init(viewModel: StatsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self

    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Statistics"
        setupYearsArray()
        updateYearLabel()
        

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //booksThisMonthView.silverFrame()
        //booksThisYearhView.silverFrame()
        //totalBooksView.silverFrame()
        //calendarContainerView.silverFrame()
        
    }
    override func bind() {
        let input = StatsViewModel.Input()
        let output = viewModel.transform(input: input)
        viewModel.$bookStats
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                guard let self = self, let stats = stats else {return}
                self.setupUI(stats: stats)
            }
            .store(in: &cancellables)
        viewModel.$bookDetail
             .receive(on: DispatchQueue.main)
             .sink { [weak self] books in
                 guard let self = self, let books = books, !books.isEmpty else { return }
                 self.showBooksInDate(books: books)
             }
             .store(in: &cancellables)
        viewModel.$fetchError.compactMap{$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showAlert(text: errorMessage)
            }.store(in: &cancellables)
        
        viewModel.$datesWithBooks
                   .receive(on: DispatchQueue.main)
                   .sink { [weak self] _ in
                       self?.calendarView.reloadData()
                   }
                   .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: NSNotification.Name("BooksInDateViewDismissed"))
            .sink { [weak self] _ in
                self?.resetContentViewPosition()
            }
            .store(in: &cancellables)
    }

    @objc private func headerTapped() {
        print(#function)
        showMonthYearPicker()
    }
    private func showMonthYearPicker() {
        // 현재 캘린더 페이지의 월과 연도 가져오기
        let currentPage = calendarView.currentPage
        selectedYear = Calendar.current.component(.year, from: currentPage)
        selectedMonth = Calendar.current.component(.month, from: currentPage) - 1 // 0-based
        
        // 피커 초기 선택 설정
        let yearIndex = years.firstIndex(of: selectedYear) ?? 0
        monthYearPickerView.selectRow(yearIndex, inComponent: 0, animated: false)
        monthYearPickerView.selectRow(selectedMonth, inComponent: 1, animated: false)
        
        // 피커 표시
        pickerContainerView.isHidden = false
    }
    @objc private func doneButtonTapped() {
        // 선택된 월과 년도로 달력 이동
        let targetMonth = selectedMonth + 1 // Convert back to 1-based month
        if let date = Calendar.current.date(from: DateComponents(year: selectedYear, month: targetMonth, day: 1)) {
            calendarView.setCurrentPage(date, animated: true)
        }
        
        // 피커 숨기기
        pickerContainerView.isHidden = true
    }
    private func setupYearsArray() {
        let currentYear = Calendar.current.component(.year, from: Date())
        years = Array((currentYear-10)...(currentYear+1))
    }
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PartialPresentationController(presentedViewController: presented, presenting: presenting)
    }
    private func showBooksInDate(books: [HomeBookEntity]) {
        // Save the original position of content view
        contentViewOriginalCenter = contentView.center
        
        // Animate the content view upward
        UIView.animate(withDuration: 0.3) {
            self.contentView.center.y -= 180
        }
        
        // Use coordinator to present the BooksInDateViewController
        coordinator?.showBooksInDate(books: books)
    }
    private func resetContentViewPosition() {
        if let originalCenter = contentViewOriginalCenter {
            UIView.animate(withDuration: 0.3) {
                self.contentView.center = originalCenter
            }
        }
    }
    private func setupUI(stats: BookStats) {
        booksThisMonthCountLabel.text = String(stats.monthCount)
        totalBooksCountLabel.text = String(stats.totalCount)
        booksThisYearCountLabel.text = String(stats.yearCount)
    }
    // MARK: - View 계층 구조 설정
    override func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add components to content view
        contentView.addSubview(titleLabel)
        
        // Add stats cards
        contentView.addSubview(booksThisMonthView)
        booksThisMonthView.addSubview(booksThisMonthTitleLabel)
        booksThisMonthView.addSubview(booksThisMonthCountLabel)
        booksThisMonthView.addSubview(booksThisMonthIconImageView)
        
        contentView.addSubview(booksThisYearhView)
        booksThisYearhView.addSubview(booksThisYearTitleLabel)
        booksThisYearhView.addSubview(booksThisYearCountLabel)
        booksThisYearhView.addSubview(booksThisYearIconImageView)
        
        contentView.addSubview(totalBooksView)
        totalBooksView.addSubview(totalBooksTitleLabel)
        totalBooksView.addSubview(totalBooksCountLabel)
        totalBooksView.addSubview(totalBooksIconImageView)
        
       
        contentView.addSubview(separatorLine)
        // Add calendar
        contentView.addSubview(calendarContainerView)
        calendarContainerView.addSubview(calendarView)
        contentView.addSubview(yearLabel)
        view.addSubview(pickerContainerView)
        pickerContainerView.addSubview(monthYearPickerView)
        pickerContainerView.addSubview(pickerDoneButton)
    }
    
    // MARK: - View 레이아웃 설정
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
            // Height will be determined by content
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(20)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
        }
        
        // Books this month view
        booksThisMonthView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(100)
        }
        
        booksThisMonthTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(booksThisMonthView).offset(20)
            make.leading.equalTo(booksThisMonthView).offset(20)
        }
        
        booksThisMonthCountLabel.snp.makeConstraints { make in
            make.top.equalTo(booksThisMonthTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(booksThisMonthView).offset(20)
        }
        
        booksThisMonthIconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(booksThisMonthView)
            make.trailing.equalTo(booksThisMonthView).offset(-20)
            make.width.height.equalTo(40)
        }
        
        // Total books view
        booksThisYearhView.snp.makeConstraints { make in
            make.top.equalTo(booksThisMonthView.snp.bottom).offset(16)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(100)
        }
        booksThisYearTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(booksThisYearhView).offset(20)
            make.leading.equalTo(booksThisYearhView).offset(20)
        }
        booksThisYearCountLabel.snp.makeConstraints { make in
            make.top.equalTo(booksThisYearTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(booksThisYearhView).offset(20)
        }
        
        booksThisYearIconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(booksThisYearhView)
            make.trailing.equalTo(booksThisYearhView).offset(-20)
            make.width.height.equalTo(40)
        }
        totalBooksView.snp.makeConstraints { make in
            make.top.equalTo(booksThisYearhView.snp.bottom).offset(16)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(100)
        }
        totalBooksTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(totalBooksView).offset(20)
            make.leading.equalTo(totalBooksView).offset(20)
        }
        
        totalBooksCountLabel.snp.makeConstraints { make in
            make.top.equalTo(totalBooksTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(totalBooksView).offset(20)
        }
        
        totalBooksIconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(totalBooksView)
            make.trailing.equalTo(totalBooksView).offset(-20)
            make.width.height.equalTo(40)
        }

        separatorLine.snp.makeConstraints { make in
            
            make.horizontalEdges.equalTo(totalBooksView)
            make.top.equalTo(totalBooksView.snp.bottom).offset(12)
            make.height.equalTo(1)
        }
        
        yearLabel.snp.makeConstraints {
            $0.top.equalTo(separatorLine.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }

        calendarContainerView.snp.makeConstraints { make in
            make.top.equalTo(yearLabel.snp.bottom).offset(8)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(350)
            make.bottom.equalTo(contentView).offset(-20)
        }

        calendarView.snp.makeConstraints { make in
            make.top.equalTo(calendarContainerView).offset(10)
            make.leading.equalTo(calendarContainerView).offset(10)
            make.trailing.equalTo(calendarContainerView).offset(-10)
            make.bottom.equalTo(calendarContainerView).offset(-10)
        }

        // 피커 컨테이너 레이아웃
        pickerContainerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(280)
            make.height.equalTo(260)
        }
        
        // 피커 뷰 레이아웃
        monthYearPickerView.snp.makeConstraints { make in
            make.top.equalTo(pickerContainerView).offset(20)
            make.left.right.equalTo(pickerContainerView)
            make.height.equalTo(180)
        }
        
        // 완료 버튼 레이아웃
        pickerDoneButton.snp.makeConstraints { make in
            make.top.equalTo(monthYearPickerView.snp.bottom).offset(10)
            make.centerX.equalTo(pickerContainerView)
            make.height.equalTo(44)
        }
    }
    
    // MARK: - 프로퍼티 속성 설정
    override func configureView() {
        view.backgroundColor = .backgroundBase // 쿨톤 밝은 회색 배경
        
        titleLabel.text = "Reading Statistics"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .mainText
        
        [booksThisMonthView, totalBooksView, booksThisYearhView, calendarContainerView].forEach {
            $0.backgroundColor = UIColor.white
            $0.layer.cornerRadius = 16
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.05
            $0.layer.shadowRadius = 6
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        }
        
        booksThisMonthTitleLabel.text = TextResource.Stats.forMonth.text
        booksThisMonthTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        booksThisMonthTitleLabel.textColor = .textSecondary
        
        booksThisMonthCountLabel.font = .systemFont(ofSize: 32, weight: .bold)
        booksThisMonthCountLabel.textColor = .mainText
        
        booksThisMonthIconImageView.image = UIImage(systemName: "calendar")
        booksThisMonthIconImageView.tintColor = .accentTint
        booksThisMonthIconImageView.contentMode = .scaleAspectFit

        totalBooksTitleLabel.text = TextResource.Stats.total.text
        totalBooksTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        totalBooksTitleLabel.textColor = .textSecondary

        totalBooksCountLabel.font = .systemFont(ofSize: 32, weight: .bold)
        totalBooksCountLabel.textColor = .mainText
        
        totalBooksIconImageView.image = UIImage(systemName: "books.vertical")
        totalBooksIconImageView.tintColor = .accentTint
        totalBooksIconImageView.contentMode = .scaleAspectFit

        booksThisYearTitleLabel.text = TextResource.Stats.forYear.text
        booksThisYearTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        booksThisYearTitleLabel.textColor = .textSecondary

        booksThisYearCountLabel.font = .systemFont(ofSize: 32, weight: .bold)
        booksThisYearCountLabel.textColor = .mainText
        
        booksThisYearIconImageView.image = UIImage(systemName: "clock.arrow.circlepath")
        booksThisYearIconImageView.tintColor = .accentTint
        booksThisYearIconImageView.contentMode = .scaleAspectFit
        
        calendarContainerView.backgroundColor = .white
        calendarView.appearance.headerTitleColor = .mainText
        calendarView.appearance.weekdayTextColor = .textSecondary
        calendarView.appearance.titleDefaultColor = .mainText
        calendarView.appearance.headerDateFormat = "M월"
        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        calendarView.tintColor = .accentTint
        
        yearLabel.font = UIFont.boldSystemFont(ofSize: 20)
        yearLabel.textAlignment = .left
        yearLabel.textColor = .mainText

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        yearLabel.isUserInteractionEnabled = true
        yearLabel.addGestureRecognizer(tapGesture)
        separatorLine.backgroundColor = .textSecondary

    }
    func updateYearLabel() {
        let currentDate = calendarView.currentPage
        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentDate)
        yearLabel.text = "\(year)"
    }
}
extension StatisticsViewController: FSCalendarDelegate, FSCalendarDataSource{
    // MARK: - FSCalendar DataSource
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        // Check if this date has books
        let startOfDay = Calendar.current.startOfDay(for: date)
        return viewModel.datesWithBooks.contains(startOfDay) ? 1 : 0
    }
    
    // MARK: - FSCalendar Delegate
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        viewModel.getBooksInDate(target: date)
    }
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateYearLabel()
    }
}
extension StatisticsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? years.count : TextDataStorage.months.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? "\(years[row])" : TextDataStorage.months[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedYear = years[row]
        } else {
            selectedMonth = row
        }
    }
}
class PartialPresentationController: UIPresentationController {
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.alpha = 0
        return view
    }()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }

        let height: CGFloat = 300
        
        return CGRect(
            x: 0,
            y: containerView.frame.height - height,
            width: containerView.frame.width,
            height: height
        )
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        // 배경 dimView 추가
        dimView.frame = containerView.bounds
        containerView.insertSubview(dimView, at: 0)
        
        // 탭 제스처 추가 (dimView 탭시 dismiss)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        dimView.addGestureRecognizer(tapGesture)
        
        // 애니메이션
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimView.alpha = 0.0
        })
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true) {
            // Notify that view was dismissed
            NotificationCenter.default.post(name: NSNotification.Name("BooksInDateViewDismissed"), object: nil)
        }
    }
    
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func containerViewDidLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}
