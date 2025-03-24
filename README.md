# amazon_clone

A new Flutter project.

## Purpose

This project aims to create a clone of the Amazon e-commerce platform, providing users with a similar shopping experience. It includes features such as user authentication, product browsing, product details, shopping cart functionality, and potentially order management.

## Technologies Used

*   Flutter
*   Dart
*   Firebase (Authentication, Firestore, Storage)
*   Riverpod (State Management)
*   GoRouter (Routing)
*   Flutter ScreenUtil, Animate Do, Carousel Slider, Cached Network Image, Shimmer (UI Libraries)

## Platforms

*   Android
*   iOS
*   macOS
*   Windows
*   Linux
*   Web

## Dependencies

*   cupertino\_icons: ^1.0.8
*   firebase\_core: ^3.12.1
*   firebase\_messaging: ^15.2.4
*   firebase\_auth: ^5.5.1
*   google\_sign\_in: ^6.3.0
*   flutter\_screenutil: ^5.9.3
*   animate\_do: ^4.2.0
*   flutter\_riverpod: ^2.6.1
*   go\_router: ^14.8.1
*   fluttertoast: ^8.2.12
*   cloud\_firestore: ^5.6.5
*   carousel\_slider: ^5.0.0
*   cached\_network\_image: ^3.4.1
*   badges: ^3.1.2
*   image\_picker: ^1.1.2
*   firebase\_storage: ^12.4.4
*   cloudinary\_public: ^0.23.1
*   path: ^1.9.1
*   shimmer: ^3.0.0
*   intl: ^0.20.2

## Assets

*   Images: assets/images/
*   Icons: assets/icons/

## Firebase Setup

The project uses Firebase for authentication, data storage (Firestore), and file storage.  Make sure to configure the Firebase project correctly and download the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files. Also, ensure that the SHA-1 and SHA-256 keys are correctly configured in the Firebase console for the Android app.

## Project Structure

*   `android`: Android-specific code.
*   `ios`: iOS-specific code.
*   `lib`: Dart code for the Flutter app.
    *   `main.dart`: Entry point of the application.
    *   `views`: Contains the different screens/views of the application.
    *   `models`: Data models.
    *   `widgets`: Reusable widgets.
    *   `data`: Repositories and data sources.
*   `macos`: macOS-specific code.
*   `windows`: Windows-specific code.
*   `linux`: Linux-specific code.
*   `web`: Web-specific code.
*   `pubspec.yaml`: Flutter project configuration file.
*   `README.md`: Project documentation.

## CI/CD Pipeline

This project uses GitHub Actions for Continuous Integration and Continuous Deployment (CI/CD). The pipeline is configured to automatically run checks and build the application on every push and pull request.

### Workflow

The CI/CD pipeline includes the following steps:

1.  **Linting:** Analyzes the Dart code for style and potential errors using `flutter analyze`.
2.  **Testing:** Runs unit and integration tests to ensure code quality and functionality.
3.  **Building:** Builds the application for different platforms (Android, iOS, Web, etc.).
4.  **Deployment (Optional):** Deploys the application to the respective app stores or hosting platforms.

### GitHub Actions Configuration

The workflow configuration files are located in the `.github/workflows` directory.

### Badges

[![Flutter CI](https://github.com/your_github_username/amazon_clone/actions/workflows/flutter.yml/badge.svg)](https://github.com/your_github_username/amazon_clone/actions/workflows/flutter.yml)

*Replace `your_github_username` with your actual GitHub username and adjust the workflow file name (`flutter.yml`) if needed.*
