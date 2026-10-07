import Foundation

struct Compromiso {
    var idDonativo: Int
    var donante: String
    var monto: Double
    var formaPago: String
    var frecuencia: String
}

struct Municipio: Codable, Identifiable {
    var id: Int
    var nombre: String
    var zona: String
}

struct NuevaVisita: Codable {
    var idDonativo: Int
    var fecha: String
    var hora: String
    var calle: String
    var colonia: String
    var idMunicipio: Int
}

struct Visita: Codable, Identifiable {
    var id: Int
    var fecha: String
    var hora: String
    var zona: String
}
