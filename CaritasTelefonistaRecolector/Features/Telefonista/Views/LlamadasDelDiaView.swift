import SwiftUI

struct LlamadasDelDiaView: View {
    @State private var llamadas: LlamadasDelDia? = nil
    @State private var cargando = true

    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Spacer()
                    if let llamadas = llamadas {
                        AvatarIniciales(iniciales: llamadas.iniciales)
                    }
                }
                .frame(height: 44)

                Text("Llamadas del día")
                    .font(.largeTitle)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            .background(Palette.superficie)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(textoHoy())
                        .foregroundColor(.secondary)

                    if let llamadas = llamadas {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Por llamar")
                                .font(.headline)
                                .padding(.leading, 16)

                            VStack(spacing: 0) {
                                if llamadas.porLlamar.isEmpty {
                                    Text("No tienes llamadas pendientes.")
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(16)
                                } else {
                                    ForEach(llamadas.porLlamar) { llamada in
                                        RenglonLlamadaPendiente(llamada: llamada)
                                        if llamada.id != llamadas.porLlamar.last?.id {
                                            Divider()
                                                .padding(.leading, 16)
                                        }
                                    }
                                }
                            }
                            .background(Palette.superficie)
                            .cornerRadius(12)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Contactados hoy")
                                .font(.headline)
                                .padding(.leading, 16)

                            VStack(spacing: 0) {
                                if llamadas.contactados.isEmpty {
                                    Text("Todavía no registras llamadas hoy.")
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(16)
                                } else {
                                    ForEach(llamadas.contactados) { llamada in
                                        RenglonLlamadaRealizada(llamada: llamada)
                                        if llamada.id != llamadas.contactados.last?.id {
                                            Divider()
                                                .padding(.leading, 16)
                                        }
                                    }
                                }
                            }
                            .background(Palette.superficie)
                            .cornerRadius(12)
                        }
                    } else if cargando {
                        ProgressView("Cargando llamadas…")
                            .frame(maxWidth: .infinity)
                            .padding(40)
                    } else {
                        Button {
                            cargarLlamadas()
                        } label: {
                            Text("Volver a intentar")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Palette.turquesaOscuro)
                        .controlSize(.large)
                    }
                }
                .padding(20)
            }
        }
        .background(Palette.fondo)
        .toolbar(.hidden)
        .onAppear {
            cargarLlamadas()
        }
        .alert(mensajeAlerta, isPresented: $mostrarAlerta) {
            Button("OK") {}
        }
    }

    func cargarLlamadas() {
        cargando = true
        Task {
            do {
                llamadas = try await obtenerLlamadasDelDia()
            } catch {
                mensajeAlerta = "No se pudieron cargar las llamadas. Revisa tu conexión e intenta de nuevo."
                mostrarAlerta.toggle()
            }
            cargando = false
        }
    }

    func textoHoy() -> String {
        let formateador = DateFormatter()
        formateador.dateFormat = "EEEE, d 'de' MMMM"
        formateador.locale = Locale(identifier: "es_MX")
        formateador.formattingContext = .beginningOfSentence
        return formateador.string(from: Date())
    }
}

#Preview {
    NavigationStack {
        LlamadasDelDiaView()
    }
}
