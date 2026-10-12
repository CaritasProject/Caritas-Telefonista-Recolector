import SwiftUI

// Pantalla de prueba: inicia sesión y después abre Agendar visita con el
// compromiso 541 de la base. Se borra cuando exista el Login.
struct PruebaAgendarVisitaView: View {
    @State private var sesionIniciada = false
    @State private var registrandoLlamada = true
    @State private var mostrarAlerta = false

    var body: some View {
        NavigationStack {
            if sesionIniciada {
                AgendarVisitaView(idDonativo: 541, registrandoLlamada: $registrandoLlamada)
            } else {
                ProgressView("Iniciando sesión de prueba…")
            }
        }
        .task {
            do {
                try await iniciarSesionDePrueba()
                sesionIniciada = true
            } catch {
                mostrarAlerta.toggle()
            }
        }
        .alert("Ha ocurrido un error.", isPresented: $mostrarAlerta) {
            Button("OK") {}
        }
    }
}

#Preview {
    PruebaAgendarVisitaView()
}
