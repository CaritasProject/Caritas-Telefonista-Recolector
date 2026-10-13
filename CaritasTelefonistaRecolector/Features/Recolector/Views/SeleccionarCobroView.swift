import SwiftUI

struct SeleccionarCobroView: View {
    @State private var cobros: [Cobro] = []

    var body: some View {
        List(cobros) { cobro in
            NavigationLink(cobro.donante) {
                RegistrarVisitaView(cobro: cobro)
            }
        }
        .navigationTitle("Registrar visita")
        .task {
            do {
                cobros = try await obtenerCobros()
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SeleccionarCobroView()
    }
}
