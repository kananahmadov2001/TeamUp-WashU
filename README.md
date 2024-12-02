# TeamUp WashU

TeamUp WashU is a project management and collaboration app designed for Washington University in St. Louis students. 
The app streamlines teamwork with features like project tracking, calendar integration, and customizable profiles, making it an essential tool for managing student activities and assignments.

---

## 📋 **Features**

### 🔐 **Authentication**
- **Login and Registration**: Secure authentication using Firebase.
- **Restricted Access**: Only allows `@wustl.edu` email addresses to register.
- **Password Validation**: Enforces secure passwords with a minimum of 8 characters.

### 🛠️ **Dashboard**
- Displays a list of all user projects.
- Includes filtering options:
  - **By Category**: Homework, Side-Projects, and more.
  - **By Status**: Completed or In Progress.
- Allows users to:
  - **Add New Projects**: Specify title, description, due date, teammates, and category.
  - **Edit Projects**: Navigate to a detailed view for updates.
  - **Track Status**: Projects marked as completed show a green checkmark.

### 📅 **Calendar Integration**
- Interactive calendar view for visualizing project deadlines.
- Syncs seamlessly with Firebase to reflect real-time updates.

### 👤 **Profile Customization**
- Personalized profile features include:
  - **Basic Information**: Name, major, and contact details.
  - **Skill Management**: Add, remove, and display skills dynamically.
- All profile data is securely saved and loaded using Firebase Firestore.

### ☁️ **Firebase Integration**
- **Authentication**: Handles secure login, registration, and validation.
- **Firestore Database**: Stores project data, user profiles, and updates in real-time.
- **Scalability**: Ensures smooth performance for multiple users.

---

## 👥 **Collaborators**

* [Ahmadov Kanan] - UI Design, Main Dashboard and Project Management, Firebase Integration
* [Sam Gil] -
* [Ted Kim] - UI Design, Calendar Integration, Firebase Integration
* [Abdou Sow] - UI Design, Firebase Setup, Authentication System, Profile Customization, Firebase Integration

---

## 🚀 **Technology Stack**

- **Languages**: Swift (UIKit Framework)
- **Backend**: Firebase (Authentication, Firestore Database)
- **UI Libraries**: UIKit, FSCalendar
- **Development Environment**: Xcode
- **Dependency Management**: CocoaPods

---

## 🗄️ **Database Structure**

### **Firestore Collections**

#### **Users Collection** (`users`):
- **Fields**:
  - `name`: String
  - `email`: String
  - `phone`: String
  - `major`: String
  - `skills`: Array of Strings (e.g., `["Swift", "Firebase"]`)

#### **Projects Collection** (`assignments`):
- **Fields**:
  - `name`: String
  - `description`: String
  - `dueDate`: String
  - `isCompleted`: Boolean
  - `teammates`: Array of Strings (User IDs)
  - `categories`: Array of Strings

---

## 🗂️ **File Structure**


- 📁 TeamUp WashU
  - 📂 Extensions
    - `Date+.swift`
    - `UIViewController+.swift`
  - 📂 Models
    - `Assignment.swift`
  - 📂 Resources
    - `Assets.xcassets`
    - `LaunchScreen.storyboard`
  - 📂 App
    - `AppDelegate.swift`
    - `SceneDelegate.swift`
  - 📂 Cells
    - 📂 CalendarAssignment
      - `CalendarAssignmentTableViewCell.swift`
      - `CalendarAssignmentEmptyTableViewCell.swift`
    - `AssignmentCollectionViewCell.swift`
  - 📂 ViewControllers
    - `DashboardViewController.swift`
    - `AssignmentDetailsViewController.swift`
    - `ProfileViewController.swift`
    - `CalendarViewController.swift`
    - `MainTabBarController.swift`
    - `ChatViewController.swift`
    - `AddAssignmentViewController.swift`
  - 📂 Firebase
    - `GoogleService-Info.plist`
  - 📂 Pods
    - `Podfile`
  - 📁 TeamUpWashUTests
  - 📁 TeamUpWashUITests


---

## 🛠️ **Setup Instructions**

### **Prerequisites**

- **Xcode**: Version 14 or higher.
- **CocoaPods**: Dependency manager for Firebase.
- **Firebase Project**: Ensure you have access to a Firebase project.

### **Steps to Setup**

1. Clone the repository:
   ```bash
   git clone https://github.com/asow211/438-finalProject.git
   cd TeamUpWashU

