import SwiftUI

struct RegistrarVisitaView: View {
    var cobro: Cobro

    var onRegistrada: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var resultado: ResultadoVisita = .cobrado
    @State private var montoCobrado = ""
    @State private var guardando = false

    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""

    @State private var mostrarConfirmacionCancelar = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                tarjetaCobro
                seccionResultado

                if resultado == .cobrado {
                    seccionMonto
                }

                botonGuardar
            }
            .padding(16)
        }
        .background(Palette.fondo)
        .navigationTitle("Registrar visita")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            montoCobrado = String(format: "%.0f", cobro.importe)
        }
        .confirmationDialog(
            "¿Cancelar el cobro?",
            isPresented: $mostrarConfirmacionCancelar,
            titleVisibility: .visible
        ) {
            Button("Cancelar cobro", role: .destructive) {
                guardar(resultado: .cancelado, monto: nil)
            }
            Button("Volver", role: .cancel) { }
        } message: {
            Text("El cobro se marcará como cancelado y saldrá de tu lista.")
        }
        .alert("Aviso", isPresented: $mostrarAlerta) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(mensajeAlerta)
        }
    }

    private var tarjetaCobro: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cobro")
                .font(.headline)

            VStack(spacing: 0) {
                RenglonDato(etiqueta: "Donante", valor: cobro.donante)
                Divider()
                RenglonDato(etiqueta: "Dirección", valor: cobro.direccion)
                Divider()
                HStack {
                    Text("Forma de pago")
                    Spacer()
                    EtiquetaFormaPago(formaPago: cobro.formaPago)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                Divider()
                RenglonDato(etiqueta: "Hora", valor: cobro.hora)
                Divider()

                HStack {
                    Text("Importe a cobrar")
                    Spacer()
                    Text(textoMonto(cobro.importe))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Palette.turquesa)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Palette.superficie)
            .cornerRadius(12)
        }
    }

    private var seccionResultado: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Resultado")
                .font(.headline)

            Picker("Resultado", selection: $resultado) {
                ForEach(ResultadoVisita.allCases) { opcion in
                    Text(opcion.rawValue).tag(opcion)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var seccionMonto: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Monto cobrado")
                .font(.headline)

            HStack(spacing: 8) {
                Text("$")
                    .foregroundColor(.secondary)
                TextField("0.00", text: $montoCobrado)
                    .keyboardType(.decimalPad)
                    .onChange(of: montoCobrado) { _, nuevo in
                        montoCobrado = nuevo.filter { $0.isNumber || $0 == "." || $0 == "," }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Palette.superficie)
            .cornerRadius(12)
        }
    }

    private var botonGuardar: some View {
        Button {
            validarYGuardar()
        } label: {
            if guardando {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 50)
            } else {
                Text("Guardar")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
        }
        .background(Palette.turquesa)
        .foregroundColor(.white)
        .cornerRadius(12)
        .disabled(guardando)
    }

    private func validarYGuardar() {
        switch resultado {
        case .cobrado:
            guard let monto = montoComoNumero(), monto > 0 else {
                mensajeAlerta = "Captura el monto cobrado."
                mostrarAlerta = true
                return
            }
            guardar(resultado: .cobrado, monto: monto)

        case .cancelado:
            mostrarConfirmacionCancelar = true

        case .ausente:
            guardar(resultado: .ausente, monto: nil)
        }
    }

    private func guardar(resultado: ResultadoVisita, monto: Double?) {
        guardando = true

        Task {
            let registro = RegistroVisita(
                idCobro: cobro.id,
                resultado: resultado.rawValue,
                montoCobrado: monto,
                fecha: fechaDeHoy()
            )

            do {
                _ = try await registrarVisita(registro: registro)
                guardando = false
                onRegistrada?()
                dismiss()
            } catch {
                guardando = false
                mensajeAlerta = "No se pudo registrar la visita. Revisa tu conexión e inténtalo de nuevo."
                mostrarAlerta = true
            }
        }
    }

    private func montoComoNumero() -> Double? {
        Double(montoCobrado.replacingOccurrences(of: ",", with: ""))
    }

    private func textoMonto(_ valor: Double) -> String {
        let formato = NumberFormatter()
        formato.numberStyle = .currency
        formato.currencyCode = "MXN"
        formato.currencySymbol = "$"
        formato.locale = Locale(identifier: "es_MX")
        formato.maximumFractionDigits = valor.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        return formato.string(from: NSNumber(value: valor)) ?? "$0"
    }

    private func fechaDeHoy() -> String {
        let formato = DateFormatter()
        formato.dateFormat = "yyyy-MM-dd"
        return formato.string(from: Date())
    }
}

struct EtiquetaFormaPago: View {
    var formaPago: String

    private var esEfectivo: Bool { formaPago.lowercased() == "efectivo" }
    private var esCheque: Bool { formaPago.lowercased() == "cheque" }

    private var icono: String {
        if esEfectivo { return "banknote.fill" }
        if esCheque { return "doc.text.fill" }
        return "creditcard.fill"
    }

    private var color: Color {
        if esEfectivo { return .green }
        if esCheque { return .orange }
        return .gray
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icono)
            Text(formaPago)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.15))
        .cornerRadius(8)
    }
}

#Preview("Efectivo") {
    NavigationStack {
        RegistrarVisitaView(
            cobro: Cobro(
                id: 1,
                hora: "09:00",
                donante: "Rosa Elena Garza Treviño",
                direccion: "Río Guadalquivir 412, Col. Del Valle, San Pedro Garza García",
                importe: 1500,
                formaPago: "Efectivo"
            )
        )
    }
}

#Preview("Cheque") {
    NavigationStack {
        RegistrarVisitaView(
            cobro: Cobro(
                id: 2,
                hora: "11:30",
                donante: "Jorge Alberto Salinas Cantú",
                direccion: "Av. Vasconcelos 150, Col. Residencial San Agustín, San Pedro Garza García",
                importe: 2000,
                formaPago: "Cheque"
            )
        )
    }
}
