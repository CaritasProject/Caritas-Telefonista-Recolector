import Foundation

func registrarVisita(registro: RegistroVisita) async throws -> VisitaRegistrada {
    guard let url = URL(string: "\(APIClient.urlBase)/cobros/\(registro.idCobro)/visita") else {
        print("URL incorrecto")
        throw URLError(.badURL)
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let token = APIClient.tokenSesion {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    request.httpBody = try JSONEncoder().encode(registro)

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
        print("Respuesta no válida del servidor")
        throw URLError(.badServerResponse)
    }

    guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
        print("Código de error del API: \(httpResponse.statusCode)")
        throw URLError(.badServerResponse)
    }

    let jsonDecoder = JSONDecoder()
    let visitaRegistrada = try jsonDecoder.decode(VisitaRegistrada.self, from: data)
    return visitaRegistrada
}
