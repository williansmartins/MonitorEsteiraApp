import SwiftUI
import CoreBluetooth

// Your HeartRateManager (no changes here, we just added the disconnect method previously)
class HeartRateManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var heartRatePeripheral: CBPeripheral?

    @Published var heartRate: Int = 0

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is On: Scanning...")
            centralManager.scanForPeripherals(withServices: [CBUUID(string: "180D")], options: nil)
        } else {
            print("Bluetooth is not available")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Sensor found: \(peripheral.name ?? "Unknown")")
        heartRatePeripheral = peripheral
        heartRatePeripheral?.delegate = self
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to sensor")
        peripheral.discoverServices([CBUUID(string: "180D")])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print("Service found: \(service.uuid)")
            peripheral.discoverCharacteristics([CBUUID(string: "2A37")], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == CBUUID(string: "2A37") {
                print("Heart rate characteristic found. Subscribing...")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == CBUUID(string: "2A37"), let data = characteristic.value {
            let bpm = parseHeartRate(from: data)
            DispatchQueue.main.async {
                self.heartRate = bpm
            }
        }
    }

    private func parseHeartRate(from data: Data) -> Int {
        let byteArray = [UInt8](data)
        if (byteArray[0] & 0x01) == 0 {
            return Int(byteArray[1])
        } else {
            return Int(UInt16(byteArray[1]) | UInt16(byteArray[2]) << 8)
        }
    }
    
    // Method to disconnect the peripheral and stop scanning
    func disconnect() {
        if let peripheral = heartRatePeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            print("Disconnected from sensor.")
        }
        centralManager.stopScan()
        heartRate = 0
        heartRatePeripheral = nil
    }
}

// Main screen with SwiftUI
struct ContentView: View {
    @StateObject var hrManager = HeartRateManager()
    
    @State private var selectedSpeed: Int? = nil

    let speeds = [2, 4, 6, 8, 10]
    
    @Environment(\.dismiss) var dismiss
    
    // --- NEW PROPERTIES FOR THE TIMER ---
    @State private var timeElapsed: TimeInterval = 0 // Stores time in seconds
    @State private var timer: Timer? = nil // The actual timer
    // --- END NEW PROPERTIES ---

    var body: some View {
        VStack(spacing: 20) {
            Text("Heart Rate")
                .font(.title)
            
            Text("\(hrManager.heartRate) BPM")
                .font(.system(size: 50))
                .bold()
                .foregroundColor(.red)
            
            // --- TIMER DISPLAY ---
            Text("Workout Duration: \(formattedTime)")
                .font(.title2)
                .padding(.top, 10)
            // --- END TIMER DISPLAY ---
            
            Spacer()
            
            // --- Speed Buttons Section ---
            Text("Set Treadmill Speed:")
                .font(.headline)
            
            HStack(spacing: 10) {
                ForEach(speeds, id: \.self) { speed in
                    Button(action: {
                        self.selectedSpeed = speed
                        print("Speed selected: \(speed)")
                    }) {
                        Text("\(speed)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(width: 60, height: 60)
                            .background(
                                self.selectedSpeed == speed ? Color.blue.opacity(0.8) : Color.blue.opacity(0.5)
                            )
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
            }
            
            if let speed = selectedSpeed {
                Text("Current Speed: \(speed)")
                    .font(.title3)
                    .padding(.top, 10)
            }
            // --- End Speed Buttons Section ---
            
            Spacer()
            
            // Stop Button
            Button(action: {
                stopTimer() // Stop the timer
                hrManager.disconnect()
                dismiss()
            }) {
                Text("Stop Workout")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            
        }
        .padding()
        .navigationTitle("Active Workout")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: startTimer) // Start timer when the screen appears
        .onDisappear(perform: stopTimer) // Stop timer when the screen disappears
    }
    
    // --- NEW METHODS FOR THE TIMER ---
    private func startTimer() {
        // Invalidate any existing timer before creating a new one
        stopTimer()
        timeElapsed = 0 // Reset time upon starting
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.timeElapsed += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate() // Stop the timer
        timer = nil // Clear the timer reference
    }
    
    private var formattedTime: String {
        let hours = Int(timeElapsed) / 3600
        let minutes = (Int(timeElapsed) % 3600) / 60
        let seconds = Int(timeElapsed) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    // --- END NEW METHODS ---
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // The preview needs a NavigationStack to simulate the navigation environment
        NavigationView { // Or NavigationStack if your target is iOS 16+
            ContentView()
        }
    }
}