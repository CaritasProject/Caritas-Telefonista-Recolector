import Foundation

func obtenerLlamadasDelDia() async throws -> LlamadasDelDia {
    guard let url = URL(string: "\(APIClient.urlBase)/llamadas/hoy") else {
        print("URL incorrecto")
        throw URLError(.badURL)
    }

    var request = URLRequest(url: url)
    if let token = APIClient.tokenSesion {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
        print("Respuesta no válida del servidor")
        throw URLError(.badServerResponse)
    }

    guard httpResponse.statusCode == 200 else {
        print("Código de error del API: \(httpResponse.statusCode)")
        throw URLError(.badServerResponse)
    }

    let jsonDecoder = JSONDecoder()
    let llamadas = try jsonDecoder.decode(LlamadasDelDia.self, from: data)
    return llamadas
}
