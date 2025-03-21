# Verifying SHA-1 and SHA-256 Keys in Firebase Console

The error "The supplied auth credential is incorrect, malformed or has expired" can occur if the SHA-1 and SHA-256 keys are not correctly configured in the Firebase console for the Android app. Follow these steps to verify the keys:

1.  **Open your project in the Firebase console:** Go to [https://console.firebase.google.com/](https://console.firebase.google.com/) and select your project.

2.  **Navigate to Project Settings:** In the left sidebar, click the gear icon to open the "Project settings".

3.  **Go to your app settings:** Scroll down to the "Your apps" section and select your Android app.

4.  **Check SHA certificates:** Scroll down to the "SHA certificate fingerprints" section.

5.  **Verify SHA-1 and SHA-256 keys:** Ensure that the SHA-1 and SHA-256 keys listed here match the ones used to sign your Android app.

    *   **If you are using Play App Signing:**
        *   Go to Google Play Console: [https://play.google.com/console](https://play.google.com/console)
        *   Select your app.
        *   Navigate to "Release" -> "Setup" -> "App integrity".
        *   Here you will find the SHA-1, SHA-256, and SHA-3 keys used by Google Play App Signing.  Make sure these are added to your Firebase project.

    *   **If you are managing your own signing key:**
        *   You can use the `keytool` command to list the SHA-1 and SHA-256 keys from your keystore file.  For example:

            ```bash
            keytool -list -v -keystore your_keystore_file.jks
            ```

            Replace `your_keystore_file.jks` with the actual path to your keystore file.  You will be prompted for the keystore password.

6.  **Add missing keys:** If any keys are missing, add them to the "SHA certificate fingerprints" section in your Firebase project settings.

7.  **Download the `google-services.json` file:** After adding or modifying the SHA keys, download the `google-services.json` file again from the Firebase console and replace the existing one in your Android project (`android/app/google-services.json`).

8.  **Clean and rebuild your Android project:** In your Flutter project, run the following commands:

    ```bash
    flutter clean
    flutter build apk
    ```

    or

    ```bash
    flutter clean
    flutter run
    ```

By following these steps, you can ensure that the SHA-1 and SHA-256 keys are correctly configured in the Firebase console, which may resolve the "The supplied auth credential is incorrect, malformed or has expired" error.
