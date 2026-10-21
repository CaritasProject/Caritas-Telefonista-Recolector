import SwiftUI

struct ContentView: View {
    @AppStorage("sesionIniciada") private var sesionIniciada = false
    @AppStorage("rol") private var rol = ""

    var body: some View {
        if sesionIniciada {
            NavigationStack {
                if rol == "TELEFONISTA" {
                    LlamadasDelDiaView(sesionIniciada: $sesionIniciada)
                } else if rol == "RECOLECTOR" {
                    CobrosDelDiaView(sesionIniciada: $sesionIniciada)
                } else {
                    Text("Este usuario no tiene acceso a la app.")
                }
            }
        } else {
            LoginView(sesionIniciada: $sesionIniciada, rol: $rol)
        }
    }
}

#Preview {
    ContentView()
}
