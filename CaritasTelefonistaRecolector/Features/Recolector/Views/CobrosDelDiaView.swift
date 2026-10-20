import SwiftUI

struct CobrosDelDiaView: View {
    @Binding var sesionIniciada: Bool

    @State private var cobros: [Cobro] = []
    @State private var textoFecha = " "
    @State private var cargando = false
    @State private var mensajeError = ""

    var body: some View {
        ZStack {
            Palette.fondo
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Spacer()
                        AvatarPerfil(sesionIniciada: $sesionIniciada)
                    }
                    Text("Cobros del día")
                        .font(.largeTitle)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .background(Palette.superficie)

                Text(textoFecha)
                    .font(.headline)
                    .fontWeight(.regular)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 26)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                if cargando {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView("Cargando cobros...")
                        Spacer()
                    }
                    Spacer()
                } else if mensajeError != "" {
                    Spacer()
                    VStack(spacing: 12) {
                        Text(mensajeError)
                            .foregroundColor(.gray)
                        Button("Reintentar") {
                            Task {
                                await cargar()
                            }
                        }
                        .frame(height: 44)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else if cobros.isEmpty {
                    Spacer()
                    Text("No tienes cobros para hoy.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(cobros) { cobro in
                                NavigationLink {
                                    RegistrarVisitaView(idCobro: cobro.id) {
                                        cobros.removeAll { $0.id == cobro.id }
                                    }
                                } label: {
                                    RenglonCobro(cobro: cobro)
                                }
                                if cobro.id != cobros.last?.id {
                                    Divider()
                                        .padding(.leading, 20)
                                }
                            }
                        }
                        .background(Palette.superficie)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .refreshable {
                        await cargar()
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await cargar()
        }
    }

    func cargar() async {
        cargando = true
        mensajeError = ""
        do {
            // La fecha y el filtro de "hoy" los decide el API, no el reloj del teléfono.
            let fechaDelDia = try await obtenerFechaDeHoy()
            textoFecha = fechaDelDia.texto
            cobros = try await obtenerCobrosDeHoy()
        } catch {
            mensajeError = "No se pudieron cargar los cobros."
        }
        cargando = false
    }
}

#Preview {
    NavigationStack {
        CobrosDelDiaView(sesionIniciada: .constant(true))
    }
}
