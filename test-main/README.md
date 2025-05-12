# RFID Prototype Project
This project is a prototype for RFID-based asset management. It integrates various components to track and manage assets in a streamlined manner using RFID technology. The project supports mobile platforms (Android and iOS), desktop (Windows, Linux, macOS), and web platforms.

## Technologies Used

- **Flutter**: Used for cross-platform app development, supporting Android, iOS, and web platforms.
- **Dart**: The primary programming language used for app development.
- **SQLite**: Used for local data storage and management.
- **RFID Technology**: Used for asset identification and tracking.

## Project Structure

```
RFID_prototype_project/
├── android/            # Android-specific files
├── ios/                # iOS-specific files
├── web/                # Web-specific files
├── lib/                # Main Dart code files
├── assets/             # Images and other static assets
├── test/               # Unit and Widget tests
├── windows/            # Windows-specific files
├── macos/              # macOS-specific files
├── linux/              # Linux-specific files
└── .gitignore          # Git ignore file
```

## Installation

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/Russidan-Nadee/RFID_prototype_project.git
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. For mobile platforms, you can run the app on an emulator or a physical device:
   ```bash
   flutter run
   ```

4. For web, you can use the following command to serve the app:
   ```bash
   flutter run -d chrome
   ```

## Features

- Asset tracking using RFID technology
- Cross-platform support (Android, iOS, Web)
- Local data storage with SQLite
- Real-time asset location updates

## Contribution

Feel free to fork this project and create pull requests. Contributions are welcome!
