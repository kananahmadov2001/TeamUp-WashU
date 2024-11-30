import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDelegateAppearance, FSCalendarDataSource {
    
    @IBOutlet weak var mainCalendar: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCalendar(myCalendar: mainCalendar)
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
        myCalendar.appearance.headerTitleColor = UIColor(red: 0.4, green: 0.2, blue: 0.4, alpha: 1.0)
        myCalendar.calendarHeaderView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        myCalendar.appearance.headerMinimumDissolvedAlpha = 0
        
        // Weekday appearance
        myCalendar.appearance.weekdayFont = .systemFont(ofSize: 15.0)
        myCalendar.appearance.weekdayTextColor = UIColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0)
        
        // Week start
        myCalendar.firstWeekday = 2 // Monday
        
        // Day titles appearance
        myCalendar.appearance.titleFont = .systemFont(ofSize: 15.0)
        myCalendar.appearance.titleTodayColor = .yellow
        myCalendar.appearance.todayColor = .green
        myCalendar.appearance.todaySelectionColor = .clear
        myCalendar.appearance.selectionColor = .purple
        myCalendar.appearance.titleSelectionColor = .yellow
        myCalendar.appearance.titlePlaceholderColor = .gray
        myCalendar.appearance.titleDefaultColor = .black
        myCalendar.appearance.titleWeekendColor = .red // Fixed: Set title color for weekends
    }
}
