import SwiftUI

struct SeleccionarDonanteView: View {
    @State private var donantes: [Donor] = []
    @State private var seleccionado: Donor?
    @State private var registrandoLlamada = false
    @State private var cargando = false
    @State private var error: String?

    var body: some View {
        List {
            if cargando {
                ProgressView("Cargando donantes…")
            } else if let error {
                Text(error)
                Button("Reintentar") { Task { await cargar() } }
            } else if donantes.isEmpty {
                Text("No hay donantes disponibles.")
            }
            ForEach(donantes) { donante in
                Button(donante.nombre) {
                    seleccionado = donante
                    registrandoLlamada = true
                }
            }
        }
        .navigationTitle("Registrar llamada")
        .navigationDestination(isPresented: $registrandoLlamada) {
            if let seleccionado {
                RegisterCallView(donorID: seleccionado.id, registrandoLlamada: $registrandoLlamada)
            }
        }
        .task { await cargar() }
    }

    @MainActor
    private func cargar() async {
        cargando = true
        error = nil
        defer { cargando = false }
        do {
            donantes = try await CallService().fetchDonors()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
