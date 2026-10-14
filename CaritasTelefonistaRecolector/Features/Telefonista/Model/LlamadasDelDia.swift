import Foundation

struct LlamadasDelDia: Codable {
    var iniciales: String
    var porLlamar: [LlamadaPendiente]
    var contactados: [LlamadaRealizada]
}

struct LlamadaPendiente: Codable, Identifiable {
    var id: Int
    var idDonante: Int
    var donante: String
    var telefono: String
    var motivo: String
}

struct LlamadaRealizada: Codable, Identifiable {
    var id: Int
    var idDonante: Int
    var donante: String
    var telefono: String
    var resultado: String
}
