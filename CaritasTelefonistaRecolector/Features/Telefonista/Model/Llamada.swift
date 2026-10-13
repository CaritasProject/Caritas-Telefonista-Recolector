import Foundation

struct Donor: Codable, Identifiable {
    let id: Int
    let nombre: String
}

struct CatalogOption: Codable, Identifiable, Hashable {
    let id: Int
    let nombre: String

    var isSinglePayment: Bool {
        nombre.folding(options: .diacriticInsensitive, locale: .current)
            .localizedCaseInsensitiveContains("pago unico")
    }
}

struct FormOptions: Codable {
    let paymentMethods: [CatalogOption]
    let frequencies: [CatalogOption]
    let frequencyTypes: [CatalogOption]

    enum CodingKeys: String, CodingKey {
        case paymentMethods = "formas_pago"
        case frequencies = "frecuencias"
        case frequencyTypes = "tipos_frecuencia"
    }
}

struct CallResponse: Codable {
    let callID: Int
    let commitmentID: Int?

    enum CodingKeys: String, CodingKey {
        case callID = "id_llamada"
        case commitmentID = "id_donativo"
    }
}

struct BackendError: Codable {
    let error: String
}

struct CallRequest: Codable {
    let resultado: String
    let comentarios: String?
    let compromiso: CommitmentRequest?
}

struct CommitmentRequest: Codable {
    let importe: Double
    let id_forma_pago: Int
    let pago_unico: Bool
    let id_frecuencia: Int?
    let id_tipo_frecuencia: Int?
}
