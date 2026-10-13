import SwiftUI

struct RegistrarVisitaView: View {
    var idCobro: Int

    var onRegistrada: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var cobro: Cobro? = nil
    @State private var historial: [PagoAnterior] = []
    @State private var cargando = true
    @State private var errorCarga: String? = nil

    @State private var resultado: ResultadoVisita = .cobrado
    @State private var montoCobrado = ""
    @State private var guardando = false

    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""

    @State private var mostrarConfirmacionCancelar = false

    var body: some View {
        Group {
            if cargando {
                ProgressView("Cargando cobro…")
            } else if let cobro {
                contenido(cobro)
            } else {
                vistaError
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.fondo)
        .navigationTitle("Registrar visita")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await cargar()
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

    private func contenido(_ cobro: Cobro) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                tarjetaCobro(cobro)

                if cobro.estatus == "PENDIENTE" {
                    seccionResultado

                    if resultado == .cobrado {
                        seccionMonto
                    }

                    botonGuardar
                } else {
                    avisoRegistrado(cobro.estatus)
                }

                seccionHistorial
            }
            .padding(16)
        }
    }

    private var vistaError: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text(errorCarga ?? "No se pudo cargar el cobro.")
                .multilineTextAlignment(.center)
            Button("Reintentar") {
                Task {
                    await cargar()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Palette.turquesa)
        }
        .padding(32)
    }

    private func tarjetaCobro(_ cobro: Cobro) -> some View {
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
                RenglonDato(etiqueta: "Fecha", valor: textoFecha(cobro.fecha))
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

    private func avisoRegistrado(_ estatus: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title2)
                .foregroundColor(Palette.turquesa)
            VStack(alignment: .leading, spacing: 4) {
                Text("Este cobro ya se registró")
                    .fontWeight(.semibold)
                Text("Estatus: \(estatus.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Palette.superficie)
        .cornerRadius(12)
    }

    private var seccionHistorial: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pagos anteriores del donante")
                .font(.headline)

            if historial.isEmpty {
                Text("Este donante no tiene pagos anteriores.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Palette.superficie)
                    .cornerRadius(12)
            } else {
                VStack(spacing: 0) {
                    ForEach(historial) { pago in
                        HStack(spacing: 12) {
                            Text(textoFecha(pago.fechaCobro))
                            Spacer()
                            Text(textoMonto(pago.estatus == "COBRADO" ? pago.importeCobrado : pago.importe))
                                .foregroundColor(.secondary)
                            EtiquetaEstatus(estatus: pago.estatus)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                        if pago.id != historial.last?.id {
                            Divider()
                        }
                    }
                }
                .background(Palette.superficie)
                .cornerRadius(12)
            }
        }
    }

    private func cargar() async {
        cargando = true
        errorCarga = nil

        do {
            let cobroCargado = try await obtenerCobro(idCobro: idCobro)
            cobro = cobroCargado
            montoCobrado = String(format: "%.0f", cobroCargado.importe)
            historial = (try? await obtenerHistorial(idCobro: idCobro)) ?? []
        } catch {
            errorCarga = "No se pudo cargar el cobro. Revisa tu conexión e inténtalo de nuevo."
        }

        cargando = false
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
                idCobro: idCobro,
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

    private func textoFecha(_ fecha: String) -> String {
        let entrada = DateFormatter()
        entrada.dateFormat = "yyyy-MM-dd"
        guard let dia = entrada.date(from: fecha) else { return fecha }

        let salida = DateFormatter()
        salida.locale = Locale(identifier: "es_MX")
        salida.dateFormat = "d MMM yyyy"
        return salida.string(from: dia)
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

struct EtiquetaEstatus: View {
    var estatus: String

    private var color: Color {
        switch estatus {
        case "COBRADO": return .green
        case "RECHAZADO": return .red
        default: return .orange
        }
    }

    var body: some View {
        Text(estatus.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .cornerRadius(6)
    }
}

#Preview {
    NavigationStack {
        RegistrarVisitaView(idCobro: 1)
    }
}
