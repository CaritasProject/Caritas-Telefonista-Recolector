import SwiftUI

struct CobrosDelDiaView: View {
    @Binding var sesionIniciada: Bool

    @State private var cobros: [Cobro] = []
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

                Text(fechaDeHoy())
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
            let pendientes = try await obtenerPendientes()
            let hoy = fechaCorta()
            var deHoy: [Cobro] = []
            for cobro in pendientes {
                if cobro.fecha.hasPrefix(hoy) {
                    deHoy.append(cobro)
                }
            }
            cobros = deHoy.sorted { $0.hora < $1.hora }
        } catch {
            mensajeError = "No se pudieron cargar los cobros."
        }
        cargando = false
    }

    func fechaDeHoy() -> String {
        let formato = DateFormatter()
        formato.locale = Locale(identifier: "es_MX")
        formato.dateFormat = "EEEE, d 'de' MMMM"
        let texto = formato.string(from: Date())
        return texto.prefix(1).uppercased() + texto.dropFirst()
    }

    func fechaCorta() -> String {
        let formato = DateFormatter()
        formato.dateFormat = "yyyy-MM-dd"
        return formato.string(from: Date())
    }
}

#Preview {
    NavigationStack {
        CobrosDelDiaView(sesionIniciada: .constant(true))
    }
}
