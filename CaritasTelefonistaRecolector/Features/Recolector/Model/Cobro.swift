import Foundation

struct Cobro: Codable, Identifiable {
    var id: Int
    var hora: String
    var donante: String
    var direccion: String
    var importe: Double
    var formaPago: String
}

enum ResultadoVisita: String, Codable, CaseIterable, Identifiable {
    case cobrado = "Cobrado"
    case ausente = "Donante ausente"
    case cancelado = "Cancelado"

    var id: String { rawValue }
}

struct RegistroVisita: Codable {
    var idCobro: Int
    var resultado: String
    var montoCobrado: Double?
    var fecha: String
}

struct VisitaRegistrada: Codable, Identifiable {
    var id: Int
    var idCobro: Int
    var resultado: String
}
