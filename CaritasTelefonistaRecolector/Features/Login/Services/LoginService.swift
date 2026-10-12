import Foundation

func iniciarSesion(correo: String, password: String) async throws {
    guard let url = URL(string: "\(APIClient.urlBase)/auth/login") else {
        print("URL incorrecto")
        throw URLError(.badURL)
    }

    let credenciales = Credenciales(correo: correo, password: password)

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(credenciales)

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
    let sesion = try jsonDecoder.decode(Sesion.self, from: data)
    APIClient.tokenSesion = sesion.token
}
