import UIKit
import FSCalendar
import FirebaseFirestore
import FirebaseAuth

class CalendarViewController: UIViewController {
    
    var assignments: [Assignment] = []
    
    var userID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    var selectedDate = Date()
    
    @IBOutlet weak var mainCalendar: FSCalendar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var addAssignmentFloatButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCalendar(myCalendar: mainCalendar)
        setTableView()
        setFloatButton()
        fetchAssignment(dateStr: selectedDate.str)
    }

    
    func setCalendar(myCalendar: FSCalendar) {
        // Assign delegate and dataSource
        myCalendar.delegate = self
        myCalendar.dataSource = self
        
        // Scroll configuration
        myCalendar.scrollEnabled = true
        myCalendar.scrollDirection = .horizontal
        
        // Calendar appearance
        myCalendar.backgroundColor = .white
        
        // Header (Month) appearance
        myCalendar.appearance.headerTitleFont = .systemFont(ofSize: 15.0)
        myCalendar.appearance.headerTitleColor = .black
        myCalendar.calendarHeaderView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // Weekday appearance
        myCalendar.appearance.weekdayFont = .systemFont(ofSize: 15.0)
        myCalendar.appearance.weekdayTextColor = UIColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0)
        
        // Week start
        myCalendar.firstWeekday = 2 // Monday
        
        // Day titles appearance
        myCalendar.appearance.titleFont = .systemFont(ofSize: 15.0)
//        myCalendar.appearance.titleTodayColor = .yellow
        myCalendar.appearance.todayColor = .red
//        myCalendar.appearance.todaySelectionColor = .clear
//        myCalendar.appearance.selectionColor = .purple
//        myCalendar.appearance.titleSelectionColor = .yellow
//        myCalendar.appearance.titlePlaceholderColor = .gray
        myCalendar.appearance.titleDefaultColor = .black
        myCalendar.appearance.titleWeekendColor = .red // Fixed: Set title color for weekends
    }
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let calendarAssignmentTableViewCell = UINib(
            nibName: String(describing: CalendarAssignmentTableViewCell.self),
            bundle: nil
        )
        tableView.register(
            calendarAssignmentTableViewCell,
            forCellReuseIdentifier: String(
                describing: CalendarAssignmentTableViewCell.self
            )
        )
        let calendarAssignmentEmptyTableViewCell = UINib(
            nibName: String(
                describing: CalendarAssignmentEmptyTableViewCell.self
            ),
            bundle: nil
        )
        tableView.register(
            calendarAssignmentEmptyTableViewCell,
            forCellReuseIdentifier: String(
                describing: CalendarAssignmentEmptyTableViewCell.self
            )
        )
    }
    
    private func setFloatButton() {
        addAssignmentFloatButton.layer.cornerRadius = addAssignmentFloatButton.frame.height / 2
    }
    
    private func fetchAssignment(dateStr: String) {
        guard let userID = userID else {
            return
        }
        let query = Firestore.firestore().collection("users").document(userID).collection("assignments")
            .whereField("dueDate", isEqualTo: dateStr)
        query.getDocuments { snapshot, error in
            if let error = error {
                print("\(type(of: self)) - \(#function)", error)
            }
            print("\(type(of: self)) - \(#function) snapshot?.documents.coun", snapshot?.documents.count)
            self.assignments = snapshot?.documents.compactMap { doc -> Assignment? in
                let data = doc.data()
                return Assignment(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "",
                    dueDate: data["dueDate"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    teammates: data["teammates"] as? [String] ?? [],
                    isCompleted: data["isCompleted"] as? Bool ?? false,
                    categories: data["categories"] as? [String] ?? []
                )
            } ?? []
            print("\(type(of: self)) - \(#function) assignments.count", self.assignments.count)
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addAssignmentButtonTapped(_ sender: Any) {
        let addAssignmentViewControllerVC = self.storyboard?.instantiateViewController(
            identifier: String(
                describing: AddAssignmentViewController.self
            )
        ) as! AddAssignmentViewController
        addAssignmentViewControllerVC.delegate = self
        addAssignmentViewControllerVC.setData(date: mainCalendar.selectedDate)
        self.present(addAssignmentViewControllerVC, animated: true)
    }
}

// MARK: - FSCalendar
extension CalendarViewController: FSCalendarDelegate, FSCalendarDelegateAppearance, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("\(type(of: self)), \(#function), date:", date)
        self.selectedDate = date
        fetchAssignment(dateStr: selectedDate.str)
    }
}

// MARK: - UITableView
extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        max(assignments.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("\(type(of: self)), \(#function), indexPath:", indexPath)

        if assignments.indices.contains(indexPath.row) {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(
                    describing: CalendarAssignmentTableViewCell.self
                )
            ) as! CalendarAssignmentTableViewCell
            cell.setData(assignment: assignments[indexPath.row])
            tableView.separatorStyle = .singleLine
            return cell
        }
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(
                describing: CalendarAssignmentEmptyTableViewCell.self
            )
        ) as! CalendarAssignmentEmptyTableViewCell
        tableView.separatorStyle = .none
        return cell
    }
}

extension CalendarViewController: AddAssignmentViewControllerDelegate {
    func addAssignmentDone(updatedAssignment: Assignment) {
        fetchAssignment(dateStr: selectedDate.str)
    }
}
