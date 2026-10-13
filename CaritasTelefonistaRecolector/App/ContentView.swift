import SwiftUI

struct ContentView: View {
    @State private var sesionIniciada = false
    @State private var registrandoLlamada = true

    var body: some View {
        if sesionIniciada {
            NavigationStack {
                AgendarVisitaView(idDonativo: 541, registrandoLlamada: $registrandoLlamada)
            }
        } else {
            LoginView(sesionIniciada: $sesionIniciada)
        }
    }
}

#Preview {
    ContentView()
}
