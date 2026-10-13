import SwiftUI

struct SeleccionarCobroView: View {
    @State private var cobros: [Cobro] = []
    @State private var cargando = false
    @State private var error: String?

    var body: some View {
        List {
            if cargando {
                ProgressView("Cargando cobros…")
            } else if let error {
                Text(error)
                Button("Reintentar") { Task { await cargar() } }
            } else if cobros.isEmpty {
                Text("No hay cobros pendientes.")
            }
            ForEach(cobros) { cobro in
                NavigationLink {
                    RegistrarVisitaView(idCobro: cobro.id) {
                        cobros.removeAll { $0.id == cobro.id }
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(cobro.donante)
                                .fontWeight(.semibold)
                            Text("\(cobro.fecha) · \(cobro.hora)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        EtiquetaFormaPago(formaPago: cobro.formaPago)
                    }
                }
            }
        }
        .navigationTitle("Cobros pendientes")
        .refreshable { await cargar() }
        .task { await cargar() }
    }

    private func cargar() async {
        cargando = true
        error = nil
        defer { cargando = false }
        do {
            cobros = try await obtenerPendientes()
        } catch {
            self.error = "No se pudieron cargar los cobros."
        }
    }
}
