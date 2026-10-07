import SwiftUI

struct AgendarVisitaView: View {
    var compromiso: Compromiso
    @Binding var registrandoLlamada: Bool

    @State private var municipios: [Municipio] = []

    @State private var fecha = Date()
    @State private var hora = Date()
    @State private var calle = ""
    @State private var colonia = ""
    @State private var idMunicipio = 0
    @State private var guardando = false

    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""

    @State private var mostrarConfirmacion = false
    @State private var mensajeConfirmacion = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Compromiso")
                        .font(.headline)

                    VStack(spacing: 0) {
                        RenglonDato(etiqueta: "Donante", valor: compromiso.donante)
                        Divider()
                        RenglonDato(etiqueta: "Monto", valor: textoMonto(compromiso.monto))
                        Divider()
                        RenglonDato(etiqueta: "Forma de pago", valor: compromiso.formaPago)
                        Divider()
                        RenglonDato(etiqueta: "Frecuencia", valor: compromiso.frecuencia)
                    }
                    .background(Palette.superficie)
                    .cornerRadius(12)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Visita")
                        .font(.headline)

                    VStack(spacing: 0) {
                        DatePicker(selection: $fecha, displayedComponents: .date) {
                            Text("Fecha")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                        Divider()

                        DatePicker(selection: $hora, displayedComponents: .hourAndMinute) {
                            Text("Hora acordada")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .background(Palette.superficie)
                    .cornerRadius(12)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Dirección")
                        .font(.headline)

                    VStack(spacing: 0) {
                        TextField("Calle y número", text: $calle)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                        Divider()

                        TextField("Colonia", text: $colonia)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                        Divider()

                        HStack {
                            Text("Municipio")
                            Spacer()
                            Picker(selection: $idMunicipio, label: Text("Municipio")) {
                                Text("Seleccionar").tag(0)
                                ForEach(municipios) { municipio in
                                    Text(municipio.nombre).tag(municipio.id)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                    }
                    .background(Palette.superficie)
                    .cornerRadius(12)

                    Text("Zona de recolección: \(zonaElegida())")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                Button {
                    agendar()
                } label: {
                    Text(guardando ? "Agendando…" : "Agendar visita")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(Palette.turquesa)
                .controlSize(.large)
            }
            .padding(20)
        }
        .background(Palette.fondo)
        .navigationTitle("Agendar visita")
        .task {
            do {
                municipios = try await obtenerMunicipios()
            } catch {
                mensajeAlerta = "No se pudieron cargar los municipios. Revisa tu conexión."
                mostrarAlerta.toggle()
            }
        }
        .alert(mensajeAlerta, isPresented: $mostrarAlerta) {
            Button("OK") {}
        }
        .alert(mensajeConfirmacion, isPresented: $mostrarConfirmacion) {
            Button("OK") {
                registrandoLlamada = false
            }
        }
    }

    func agendar() {
        if textoFecha(fecha, formato: "yyyy-MM-dd") < textoFecha(Date(), formato: "yyyy-MM-dd") {
            mensajeAlerta = "La visita debe ser de hoy en adelante."
            mostrarAlerta.toggle()
            return
        }

        if calle.isEmpty {
            mensajeAlerta = "Falta un dato: captura la calle y el número."
            mostrarAlerta.toggle()
            return
        }

        if colonia.isEmpty {
            mensajeAlerta = "Falta un dato: captura la colonia."
            mostrarAlerta.toggle()
            return
        }

        if idMunicipio == 0 {
            mensajeAlerta = "Falta un dato: selecciona el municipio."
            mostrarAlerta.toggle()
            return
        }

        if guardando {
            return
        }
        guardando = true

        let nuevaVisita = NuevaVisita(idDonativo: compromiso.idDonativo,
                                      fecha: textoFecha(fecha, formato: "yyyy-MM-dd"),
                                      hora: textoFecha(hora, formato: "HH:mm"),
                                      calle: calle,
                                      colonia: colonia,
                                      idMunicipio: idMunicipio)
        Task {
            do {
                let visita = try await agendarVisita(nuevaVisita: nuevaVisita)
                let dia = textoFecha(fecha, formato: "EEEE d 'de' MMMM")
                mensajeConfirmacion = "Visita agendada: \(compromiso.donante), \(dia) a las \(visita.hora). Zona \(visita.zona)."
                mostrarConfirmacion.toggle()
            } catch {
                mensajeAlerta = "No se pudo agendar la visita. Revisa tu conexión e intenta de nuevo."
                mostrarAlerta.toggle()
            }
            guardando = false
        }
    }

    func zonaElegida() -> String {
        for municipio in municipios {
            if municipio.id == idMunicipio {
                return municipio.zona
            }
        }
        return "elige un municipio"
    }

    func textoMonto(_ monto: Double) -> String {
        return monto.formatted(.currency(code: "MXN").precision(.fractionLength(0)))
    }

    func textoFecha(_ fecha: Date, formato: String) -> String {
        let formateador = DateFormatter()
        formateador.dateFormat = formato
        formateador.locale = Locale(identifier: "es_MX")
        return formateador.string(from: fecha)
    }
}

#Preview {
    NavigationStack {
        AgendarVisitaView(compromiso: Compromiso(idDonativo: 1,
                                                 donante: "Patricia Elizondo Salinas",
                                                 monto: 1500,
                                                 formaPago: "Efectivo",
                                                 frecuencia: "Permanente · Mensual"),
                          registrandoLlamada: .constant(true))
    }
}
