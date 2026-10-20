import SwiftUI
import MapKit

struct AgendarVisitaView: View {
    var idDonativo: Int
    @Binding var registrandoLlamada: Bool

    @State private var compromiso: Compromiso? = nil
    @State private var municipios: [Municipio] = []

    @State private var fecha = Date()
    @State private var hora = Date()
    @State private var calle = ""
    @State private var colonia = ""
    @State private var idMunicipio = 0
    @State private var guardando = false

    @State private var ubicacion: CLLocationCoordinate2D? = nil
    @State private var posicionMapa: MapCameraPosition = .automatic

    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""

    @State private var mostrarPregunta = false
    @State private var mensajePregunta = ""

    @State private var mostrarConfirmacion = false
    @State private var mensajeConfirmacion = ""

    var body: some View {
        ScrollView {
            if let compromiso = compromiso {
                VStack(alignment: .leading, spacing: 24) {
                    TarjetaMonto(monto: textoMonto(compromiso.monto),
                                 detalle: "\(compromiso.formaPago) · \(compromiso.frecuencia)")

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Compromiso")
                            .font(.headline)

                        RenglonDato(etiqueta: "Donante", valor: compromiso.donante)
                            .background(Palette.superficie)
                            .cornerRadius(12)
                    }

                    if let visita = compromiso.visitaPendiente {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Este compromiso ya tiene una visita agendada")
                                .font(.headline)
                            Text("\(textoDia(visita.fecha)) a las \(visita.hora). Zona \(visita.zona).")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Palette.superficie)
                        .cornerRadius(12)
                    } else {
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

                            Button {
                                verEnMapa()
                            } label: {
                                Text("Ver en el mapa")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 4)
                            }
                            .buttonStyle(.bordered)
                            .tint(Palette.turquesa)

                            if let ubicacion = ubicacion {
                                Map(position: $posicionMapa) {
                                    Marker(calle, coordinate: ubicacion)
                                        .tint(Palette.turquesa)
                                }
                                .frame(height: 220)
                                .cornerRadius(12)
                            }
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
                }
                .padding(20)
            } else {
                ProgressView("Cargando compromiso…")
                    .padding(40)
            }
        }
        .background(Palette.fondo)
        .navigationTitle("Agendar visita")
        .task {
            do {
                compromiso = try await obtenerCompromiso(idDonativo: idDonativo)
                municipios = try await obtenerMunicipios()
            } catch {
                mensajeAlerta = "Ha ocurrido un error."
                mostrarAlerta.toggle()
            }
        }
        .onChange(of: calle) { oldValue, newValue in
            ubicacion = nil
        }
        .onChange(of: colonia) { oldValue, newValue in
            ubicacion = nil
        }
        .onChange(of: idMunicipio) { oldValue, newValue in
            ubicacion = nil
        }
        .alert(mensajeAlerta, isPresented: $mostrarAlerta) {
            Button("OK") {}
        }
        .alert(mensajePregunta, isPresented: $mostrarPregunta) {
            Button("Cancelar") {}
            Button("Agendar") {
                guardarVisita()
            }
        }
        .alert(mensajeConfirmacion, isPresented: $mostrarConfirmacion) {
            Button("OK") {
                registrandoLlamada = false
            }
        }
    }

    func agendar() {
        guard let compromiso = compromiso else {
            return
        }

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

        let dia = textoFecha(fecha, formato: "EEEE d 'de' MMMM")
        let horaTexto = textoFecha(hora, formato: "HH:mm")
        mensajePregunta = "¿Agendar la visita? \(compromiso.donante), \(dia) a las \(horaTexto) en \(calle), \(colonia), \(nombreMunicipio()). Cobro de \(textoMonto(compromiso.monto))."
        mostrarPregunta.toggle()
    }

    func guardarVisita() {
        guard let compromiso = compromiso else {
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
                mensajeAlerta = "Ha ocurrido un error."
                mostrarAlerta.toggle()
            }
            guardando = false
        }
    }

    func verEnMapa() {
        if calle.isEmpty || colonia.isEmpty || idMunicipio == 0 {
            mensajeAlerta = "Captura la calle, la colonia y el municipio para verlos en el mapa."
            mostrarAlerta.toggle()
            return
        }

        let direccion = "\(calle), \(colonia), \(nombreMunicipio()), Nuevo León, México"
        Task {
            do {
                let coordenada = try await buscarDireccion(direccion: direccion)
                ubicacion = coordenada
                posicionMapa = .region(MKCoordinateRegion(center: coordenada,
                                                          latitudinalMeters: 600,
                                                          longitudinalMeters: 600))
            } catch {
                mensajeAlerta = "No se encontró la dirección en el mapa."
                mostrarAlerta.toggle()
            }
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

    func nombreMunicipio() -> String {
        for municipio in municipios {
            if municipio.id == idMunicipio {
                return municipio.nombre
            }
        }
        return ""
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

    func textoDia(_ fechaISO: String) -> String {
        let lector = DateFormatter()
        lector.dateFormat = "yyyy-MM-dd"
        if let dia = lector.date(from: fechaISO) {
            return textoFecha(dia, formato: "EEEE d 'de' MMMM")
        }
        return fechaISO
    }
}

#Preview {
    LoginView(sesionIniciada: .constant(false), rol: .constant(""))
}
