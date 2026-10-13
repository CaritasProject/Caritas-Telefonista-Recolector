import SwiftUI

struct ContentView: View {
    @State private var sesionIniciada = false
    @State private var rol = ""

    var body: some View {
        if sesionIniciada {
            NavigationStack {
                if rol == "TELEFONISTA" {
                    LlamadasDelDiaView()
                } else if rol == "RECOLECTOR" {
                    SeleccionarCobroView()
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
