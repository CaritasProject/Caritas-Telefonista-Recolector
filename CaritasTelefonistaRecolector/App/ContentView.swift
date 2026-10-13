import SwiftUI

struct ContentView: View {
    @State private var sesionIniciada = false

    var body: some View {
        if sesionIniciada {
            NavigationStack {
                SeleccionarDonanteView()
            }
        } else {
            LoginView(sesionIniciada: $sesionIniciada)
        }
    }
}

#Preview {
    ContentView()
}
