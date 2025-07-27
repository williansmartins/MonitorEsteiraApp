# 🚴‍♂️ Treadmill Heart Rate Monitor App

This iOS application, built with **SwiftUI** and **CoreBluetooth**, allows users to monitor their heart rate in real-time from a Bluetooth Low Energy (BLE) heart rate sensor while providing a simple interface to track workout duration and simulate treadmill speeds.

---

## ✨ Features

* **Real-time Heart Rate Monitoring:** Connects to standard BLE heart rate sensors (using GATT Heart Rate Service, `180D`, and Heart Rate Measurement Characteristic, `2A37`) to display BPM.
* **Workout Timer:** Tracks and displays the duration of your workout in `HH:MM:SS` format.
* **Treadmill Speed Simulation:** A set of interactive buttons (2, 4, 6, 8, 10) allows users to select and visually represent their current treadmill speed, enhancing the training experience.
* **Intuitive Navigation:** A clean two-screen flow with a "Start Workout" entry point and a "Stop Workout" option to end the session and disconnect from the sensor.
* **Robust Bluetooth Handling:** Basic handling for Bluetooth state changes and sensor disconnection.

---

## 🚀 Getting Started

To run this project, you'll need Xcode 13 or later.

### Prerequisites

* **Xcode 13+** (or newer)
* An **iOS device** (iPhone or iPad) to test the Bluetooth functionality. Simulators do not support Bluetooth.
* A **Bluetooth Low Energy (BLE) Heart Rate Sensor** (e.g., chest strap, arm band) that adheres to the standard Heart Rate Service (UUID `180D`).

### Installation

1.  **Clone the repository:**
    ```bash
    git clone <YOUR_REPOSITORY_URL>
    cd <YOUR_PROJECT_FOLDER> # e.g., cd TreadmillHRApp/TreadmillHRApp
    ```
    (Replace `<YOUR_REPOSITORY_URL>` and `<YOUR_PROJECT_FOLDER>` with your actual repository URL and project folder name).

2.  **Open the project in Xcode:**
    ```bash
    open TreadmillHRApp.xcodeproj # Replace with your .xcodeproj name
    ```

3.  **Set the Minimum Deployment Target:**
    Ensure your project's target is set to **iOS 16.0 or higher** to fully support `NavigationStack` and other modern SwiftUI features.
    * In Xcode, select your **project** in the Project Navigator.
    * Select your **Target** (e.g., `TreadmillHRApp`).
    * Go to the **"General"** tab.
    * Under **"Deployment Info"**, set "Minimum Deployments" to **iOS 16.0**.

4.  **Add Bluetooth Privacy Permissions:**
    Your app needs permission to access Bluetooth.
    * Select your **Target** in Xcode.
    * Go to the **"Info"** tab.
    * Add the following keys and descriptions under "Custom iOS Target Properties":
        * `Privacy - Bluetooth Always Usage Description` (Key: `NSBluetoothAlwaysUsageDescription`)
            * Value: `"This app needs Bluetooth access to connect to your heart rate sensor and monitor your workout."`
        * `Privacy - Bluetooth Peripheral Usage Description` (Key: `NSBluetoothPeripheralUsageDescription`)
            * Value: `"Allow the app to use Bluetooth to interact with the heart rate sensor during your workout."`

5.  **Run on a Device:**
    Select your connected iPhone or iPad as the run destination and click the "Run" button (▶️) in Xcode.

---

## 📱 Usage

1.  **Start Screen:** Tap the **"Start Workout"** button to begin.
2.  **Workout Screen:**
    * The app will automatically start scanning for your heart rate sensor.
    * Once connected, your **BPM (Beats Per Minute)** will be displayed.
    * The **"Workout Duration"** timer will begin counting up.
    * Tap any of the **speed buttons (2, 4, 6, 8, 10)** to visually indicate your treadmill speed. The selected button will highlight.
3.  **End Workout:** Tap the **"Stop Workout"** button to disconnect from the sensor, stop the timer, and return to the start screen.

---

## 🛠️ Built With

* **SwiftUI** - Apple's declarative UI framework.
* **CoreBluetooth** - Apple's framework for interacting with Bluetooth Low Energy devices.

---

## 🤝 Contributing

Feel free to fork the repository, open issues, or submit pull requests. Any contributions to improve functionality, add features, or refine the UI are welcome!

---

## 📜 License

This project is open-source and available under the [MIT License](LICENSE).

---
