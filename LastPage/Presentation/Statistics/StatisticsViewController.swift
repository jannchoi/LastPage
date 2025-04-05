//
//  StatisticsViewController.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import UIKit
import SnapKit
import Combine


class StatisticsViewController: BaseViewController {
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
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reading Statistics"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    // Book count this month view
    private lazy var booksThisMonthView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var booksThisMonthTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Books This Month"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var booksThisMonthCountLabel: UILabel = {
        let label = UILabel()
        label.text = "5"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private lazy var booksThisMonthIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "book")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // Total books view
    private lazy var totalBooksView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var totalBooksTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Books"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var totalBooksCountLabel: UILabel = {
        let label = UILabel()
        label.text = "10"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private lazy var totalBooksIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chart.bar.fill")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // Reading streak view
    private lazy var booksThisYearhView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var booksThisYearTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reading Streak"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var booksThisYearhCountLabel: UILabel = {
        let label = UILabel()
        label.text = "7 days"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private lazy var readingStreakIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "calendar")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // Calendar
    private lazy var calendarContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var calendarTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "June 2023"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private lazy var calendarPrevButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var calendarNextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var calendarView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.addTarget(self, action: #selector(dateSelected), for: .valueChanged)
        return datePicker
    }()
    
    // Chart
    private lazy var chartContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var chartTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reading Progress"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    private let chartview = UIView()
//    private lazy var barChartView: BarChartView = {
//        let chartView = BarChartView()
//        chartView.rightAxis.enabled = false
//        
//        let leftAxis = chartView.leftAxis
//        leftAxis.labelFont = .systemFont(ofSize: 10)
//        leftAxis.labelTextColor = .label
//        leftAxis.axisMinimum = 0
//        
//        let xAxis = chartView.xAxis
//        xAxis.labelPosition = .bottom
//        xAxis.labelFont = .systemFont(ofSize: 10)
//        xAxis.labelTextColor = .label
//        
//        chartView.legend.enabled = false
//        chartView.animate(yAxisDuration: 1.0)
//        
//        return chartView
//    }()
    
    init(viewModel: StatsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Statistics"
        //setupBarChart()
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
    }
    private func setupUI(stats: BookStats) {
        booksThisMonthCountLabel.text = String(stats.monthCount)
        totalBooksCountLabel.text = String(stats.totalCount)
        booksThisYearhCountLabel.text = String(stats.yearCount)
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
        
        contentView.addSubview(totalBooksView)
        totalBooksView.addSubview(totalBooksTitleLabel)
        totalBooksView.addSubview(totalBooksCountLabel)
        totalBooksView.addSubview(totalBooksIconImageView)
        
        contentView.addSubview(booksThisYearhView)
        booksThisYearhView.addSubview(booksThisYearTitleLabel)
        booksThisYearhView.addSubview(booksThisYearhCountLabel)
        booksThisYearhView.addSubview(readingStreakIconImageView)
        
        // Add calendar
        contentView.addSubview(calendarContainerView)
        calendarContainerView.addSubview(calendarTitleLabel)
        calendarContainerView.addSubview(calendarPrevButton)
        calendarContainerView.addSubview(calendarNextButton)
        calendarContainerView.addSubview(calendarView)
        
        // Add chart
        contentView.addSubview(chartContainerView)
        chartContainerView.addSubview(chartTitleLabel)
        //chartContainerView.addSubview(barChartView)
        chartContainerView.addSubview(chartview)
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
        totalBooksView.snp.makeConstraints { make in
            make.top.equalTo(booksThisMonthView.snp.bottom).offset(16)
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
        
        // Reading streak view
        booksThisYearhView.snp.makeConstraints { make in
            make.top.equalTo(totalBooksView.snp.bottom).offset(16)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(100)
        }
        
        booksThisYearTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(booksThisYearhView).offset(20)
            make.leading.equalTo(booksThisYearhView).offset(20)
        }
        
        booksThisYearhCountLabel.snp.makeConstraints { make in
            make.top.equalTo(booksThisYearTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(booksThisYearhView).offset(20)
        }
        
        readingStreakIconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(booksThisYearhView)
            make.trailing.equalTo(booksThisYearhView).offset(-20)
            make.width.height.equalTo(40)
        }
        
        // Calendar container
        calendarContainerView.snp.makeConstraints { make in
            make.top.equalTo(booksThisYearhView.snp.bottom).offset(20)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(350)
        }
        
        calendarTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(calendarContainerView).offset(16)
            make.centerX.equalTo(calendarContainerView)
        }
        
        calendarPrevButton.snp.makeConstraints { make in
            make.centerY.equalTo(calendarTitleLabel)
            make.leading.equalTo(calendarContainerView).offset(20)
            make.width.height.equalTo(30)
        }
        
        calendarNextButton.snp.makeConstraints { make in
            make.centerY.equalTo(calendarTitleLabel)
            make.trailing.equalTo(calendarContainerView).offset(-20)
            make.width.height.equalTo(30)
        }
        
        calendarView.snp.makeConstraints { make in
            make.top.equalTo(calendarTitleLabel.snp.bottom).offset(10)
            make.leading.equalTo(calendarContainerView).offset(10)
            make.trailing.equalTo(calendarContainerView).offset(-10)
            make.bottom.equalTo(calendarContainerView).offset(-10)
        }
        
        // Chart container
        chartContainerView.snp.makeConstraints { make in
            make.top.equalTo(calendarContainerView.snp.bottom).offset(20)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(300)
            make.bottom.equalTo(contentView).offset(-20)
        }
        
        chartTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(chartContainerView).offset(16)
            make.leading.equalTo(chartContainerView).offset(16)
        }
        chartview.snp.makeConstraints { make in
            make.top.equalTo(chartTitleLabel.snp.bottom).offset(16)
            make.leading.equalTo(chartContainerView).offset(16)
            make.trailing.equalTo(chartContainerView).offset(-16)
            make.bottom.equalTo(chartContainerView).offset(-16)
        }
//        barChartView.snp.makeConstraints { make in
//            make.top.equalTo(chartTitleLabel.snp.bottom).offset(16)
//            make.leading.equalTo(chartContainerView).offset(16)
//            make.trailing.equalTo(chartContainerView).offset(-16)
//            make.bottom.equalTo(chartContainerView).offset(-16)
//        }
    }
    
    // MARK: - 프로퍼티 속성 설정
    override func configureView() {
        view.backgroundColor = .white
        tabBarItem = UITabBarItem(title: "Statistics", image: UIImage(systemName: "chart.bar"), tag: 2)
        
    }

    
    // MARK: - Chart Setup
//    private func setupBarChart() {
//        // Initial setup with dummy data
//        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
//        let values = [5, 2, 0, 0, 0, 5]
//        
//        var dataEntries: [BarChartDataEntry] = []
//        
//        for i in 0..<months.count {
//            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
//            dataEntries.append(dataEntry)
//        }
//        
//        let dataSet = BarChartDataSet(entries: dataEntries, label: "Books read")
//        dataSet.colors = [.systemBlue]
//        dataSet.valueTextColor = .label
//        dataSet.valueFont = .systemFont(ofSize: 10)
//        
//        let data = BarChartData(dataSet: dataSet)
//        barChartView.data = data
//        
//        // X-axis value formatter
//        let xAxisFormatter = IndexAxisValueFormatter(values: months)
//        barChartView.xAxis.valueFormatter = xAxisFormatter
//        barChartView.xAxis.granularity = 1
//    }
//    
//    private func updateBarChart(with data: [(month: String, count: Int)]) {
//        var dataEntries: [BarChartDataEntry] = []
//        var months: [String] = []
//        
//        for (index, item) in data.enumerated() {
//            let dataEntry = BarChartDataEntry(x: Double(index), y: Double(item.count))
//            dataEntries.append(dataEntry)
//            months.append(item.month)
//        }
//        
//        let dataSet = BarChartDataSet(entries: dataEntries, label: "Books read")
//        dataSet.colors = [.systemBlue]
//        dataSet.valueTextColor = .label
//        dataSet.valueFont = .systemFont(ofSize: 10)
//        
//        let data = BarChartData(dataSet: dataSet)
//        barChartView.data = data
//        
//        // X-axis value formatter
//        let xAxisFormatter = IndexAxisValueFormatter(values: months)
//        barChartView.xAxis.valueFormatter = xAxisFormatter
//        barChartView.xAxis.granularity = 1
//        
//        barChartView.notifyDataSetChanged()
//    }
    
//    private func updateCalendarTitle() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMMM yyyy"
//        calendarTitleLabel.text = dateFormatter.string(from: calendarView.date)
//    }
//    
    // MARK: - Actions
    @objc private func dateSelected(_ sender: UIDatePicker) {
        //viewModel.selectedDate = sender.date
    }
    
    @objc private func previousMonthTapped() {
        guard let currentDate = Calendar.current.date(byAdding: .month, value: -1, to: calendarView.date) else { return }
        calendarView.setDate(currentDate, animated: true)
        //viewModel.selectedDate = currentDate
    }
    
    @objc private func nextMonthTapped() {
        guard let currentDate = Calendar.current.date(byAdding: .month, value: 1, to: calendarView.date) else { return }
        calendarView.setDate(currentDate, animated: true)
        //viewModel.selectedDate = currentDate
    }
}
