// StartView.swift
import SwiftUI

struct StartView: View {
    @State private var showContentView: Bool = false

    var body: some View {
        // MUDA AQUI: Usamos NavigationView em vez de NavigationStack
        NavigationView {
            VStack(spacing: 30) {
                Spacer()

                Text("Bem-vindo ao Monitor de Esteira")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()

                Text("Pronto para começar seu treino?")
                    .font(.title2)
                    .foregroundColor(.gray)

                Spacer()

                Button(action: {
                    showContentView = true
                }) {
                    Text("Iniciar Treino")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                
                // MUDA AQUI: Usamos NavigationLink invisível ou sheets com o NavigationView
                // Para a navegação push, podemos usar um NavigationLink
                NavigationLink(destination: ContentView(), isActive: $showContentView) {
                    EmptyView() // Oculta o link visível, pois o botão já o aciona
                }
                .hidden() // Garante que o NavigationLink não seja visível
                
                Spacer()
            }
            .navigationTitle("Início")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
