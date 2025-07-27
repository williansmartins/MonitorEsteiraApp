import SwiftUI
import CoreBluetooth

// Seu HeartRateManager (sem alterações neste trecho, apenas adicionamos o disconnect antes)
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
            print("Bluetooth Ligado: Escaneando...")
            centralManager.scanForPeripherals(withServices: [CBUUID(string: "180D")], options: nil)
        } else {
            print("Bluetooth não disponível")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Sensor encontrado: \(peripheral.name ?? "Desconhecido")")
        heartRatePeripheral = peripheral
        heartRatePeripheral?.delegate = self
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Conectado ao sensor")
        peripheral.discoverServices([CBUUID(string: "180D")])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print("Serviço encontrado: \(service.uuid)")
            peripheral.discoverCharacteristics([CBUUID(string: "2A37")], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == CBUUID(string: "2A37") {
                print("Característica de batimento encontrada. Subscribing...")
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
    
    // Método para desconectar o periférico e parar o escaneamento
    func disconnect() {
        if let peripheral = heartRatePeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            print("Desconectado do sensor.")
        }
        centralManager.stopScan()
        heartRate = 0
        heartRatePeripheral = nil
    }
}

// Tela principal com SwiftUI
struct ContentView: View {
    @StateObject var hrManager = HeartRateManager()
    
    @State private var selectedSpeed: Int? = nil

    let speeds = [2, 4, 6, 8, 10]
    
    @Environment(\.dismiss) var dismiss
    
    // --- NOVAS PROPRIEDADES PARA O TIMER ---
    @State private var timeElapsed: TimeInterval = 0 // Armazena o tempo em segundos
    @State private var timer: Timer? = nil // O timer real
    // --- FIM NOVAS PROPRIEDADES ---

    var body: some View {
        VStack(spacing: 20) {
            Text("Batimentos Cardíacos")
                .font(.title)
            
            Text("\(hrManager.heartRate) BPM")
                .font(.system(size: 50))
                .bold()
                .foregroundColor(.red)
            
            // --- EXIBIÇÃO DO TIMER ---
            Text("Duração do Treino: \(formattedTime)")
                .font(.title2)
                .padding(.top, 10)
            // --- FIM EXIBIÇÃO DO TIMER ---
            
            Spacer()
            
            // --- Seção de Botões de Velocidade ---
            Text("Definir Velocidade:")
                .font(.headline)
            
            HStack(spacing: 10) {
                ForEach(speeds, id: \.self) { speed in
                    Button(action: {
                        self.selectedSpeed = speed
                        print("Velocidade selecionada: \(speed)")
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
                Text("Velocidade atual: \(speed)")
                    .font(.title3)
                    .padding(.top, 10)
            }
            // --- Fim da Seção de Botões de Velocidade ---
            
            Spacer()
            
            // Botão de Parar
            Button(action: {
                stopTimer() // Para o timer
                hrManager.disconnect()
                dismiss()
            }) {
                Text("Parar Treino")
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
        .navigationTitle("Treino Ativo")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: startTimer) // Inicia o timer quando a tela aparece
        .onDisappear(perform: stopTimer) // Para o timer quando a tela desaparece
    }
    
    // --- NOVOS MÉTODOS PARA O TIMER ---
    private func startTimer() {
        // Invalida qualquer timer existente antes de criar um novo
        stopTimer()
        timeElapsed = 0 // Reseta o tempo ao iniciar
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.timeElapsed += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate() // Para o timer
        timer = nil // Limpa a referência
    }
    
    private var formattedTime: String {
        let hours = Int(timeElapsed) / 3600
        let minutes = (Int(timeElapsed) % 3600) / 60
        let seconds = Int(timeElapsed) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    // --- FIM NOVOS MÉTODOS ---
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // O Preview precisa de um NavigationStack para simular o ambiente de navegação
        NavigationView { // Ou NavigationStack se seu target for iOS 16+
            ContentView()
        }
    }
}
