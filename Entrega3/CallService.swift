import Foundation

struct Donor: Codable {
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

struct CallService {
    private let baseURL: URL
    private let session: URLSession

    init(
        baseURL: URL = URL(string: "http://127.0.0.1:5001")!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    func fetchDonor(id: Int) async throws -> Donor {
        try await request(path: "donantes/\(id)")
    }

    func fetchFormOptions() async throws -> FormOptions {
        try await request(path: "llamadas/form-options")
    }

    func registerCall(
        donorID: Int,
        request callRequest: CallRequest
    ) async throws -> CallResponse {
        var urlRequest = URLRequest(
            url: baseURL.appendingPathComponent("donantes/\(donorID)/llamadas")
        )
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpBody = try JSONEncoder().encode(callRequest)

        return try await perform(urlRequest)
    }

    private func request<Response: Decodable>(path: String) async throws -> Response {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return try await perform(request)
    }

    private func perform<Response: Decodable>(
        _ request: URLRequest
    ) async throws -> Response {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CallServiceError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let backendError = try? JSONDecoder().decode(BackendError.self, from: data)
            throw CallServiceError.server(
                statusCode: httpResponse.statusCode,
                message: backendError?.error
            )
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw CallServiceError.invalidData
        }
    }
}

enum CallServiceError: LocalizedError {
    case invalidResponse
    case invalidData
    case server(statusCode: Int, message: String?)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "El servidor devolvió una respuesta inválida."
        case .invalidData:
            return "No fue posible interpretar la respuesta del servidor."
        case let .server(statusCode, message):
            return message ?? "El servidor respondió con el código \(statusCode)."
        }
    }
}
