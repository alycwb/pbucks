# PBucks

PBucks is a motivational and educational mobile app designed for parents and their children (ages 6–16). It enables parents to assign tasks or responsibilities to their children and rewards them with a virtual currency called PBucks (Parent Bucks). Children can use their earned PBucks to redeem real-life rewards such as toys, experiences, or privileges.

## Features

- **Role-based Authentication**
  - Parent and Child user roles
  - Secure login system
  - Parent-child account linking

- **Task Management (Parents)**
  - Create and assign tasks
  - Set PBuck values for tasks
  - Monitor task completion
  - Approve completed tasks

- **Task List (Children)**
  - View assigned tasks
  - Mark tasks as complete
  - Track earned PBucks
  - View task history

- **Reward Store**
  - Parents can create and manage rewards
  - Children can browse available rewards
  - Redeem PBucks for rewards
  - Track reward history

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode for mobile deployment
- A modern web browser for web deployment

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/pbucks.git
   ```

2. Navigate to the project directory:
   ```bash
   cd pbucks
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Create the necessary asset directories:
   ```bash
   mkdir -p assets/images assets/icons assets/fonts
   ```

5. Download and add the Poppins font files to `assets/fonts/`:
   - Poppins-Regular.ttf
   - Poppins-Medium.ttf
   - Poppins-SemiBold.ttf
   - Poppins-Bold.ttf

6. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── constants/
│   └── app_theme.dart
├── models/
│   ├── user.dart
│   ├── task.dart
│   └── reward.dart
├── screens/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── parent/
│   │   └── parent_dashboard.dart
│   ├── child/
│   │   └── child_dashboard.dart
│   └── store/
│       └── store_screen.dart
├── widgets/
│   ├── task_card.dart
│   └── reward_card.dart
└── main.dart
```

## Design

The app features a clean, modern, and distraction-free UI with:
- Rounded corners
- Soft color palette (creams, navy blues, and accent colors)
- Medium-weight fonts for readability
- Age-appropriate visuals for children 6-16

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- The open-source community for inspiration and resources
