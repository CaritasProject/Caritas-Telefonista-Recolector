import SwiftUI

struct ContentView: View {
    @State private var sesionIniciada = false
    @State private var rol = ""

    var body: some View {
        if sesionIniciada {
            NavigationStack {
                if rol == "TELEFONISTA" {
                    SeleccionarDonanteView()
                } else if rol == "RECOLECTOR" {
                    Text("Cobros del día")
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
