import Foundation

func obtenerMunicipios() async throws -> [Municipio] {
    guard let url = URL(string: "\(APIClient.urlBase)/visitas/municipios") else {
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
    let listaMunicipios = try jsonDecoder.decode([Municipio].self, from: data)
    return listaMunicipios
}

func agendarVisita(nuevaVisita: NuevaVisita) async throws -> Visita {
    guard let url = URL(string: "\(APIClient.urlBase)/visitas") else {
        print("URL incorrecto")
        throw URLError(.badURL)
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let token = APIClient.tokenSesion {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    request.httpBody = try JSONEncoder().encode(nuevaVisita)

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
    let visitaAgendada = try jsonDecoder.decode(Visita.self, from: data)
    return visitaAgendada
}
