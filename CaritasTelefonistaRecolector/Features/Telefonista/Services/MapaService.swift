import MapKit

func buscarDireccion(direccion: String) async throws -> CLLocationCoordinate2D {
    guard let request = MKGeocodingRequest(addressString: direccion) else {
        print("Dirección vacía")
        throw URLError(.badURL)
    }

    let lugares = try await request.mapItems

    guard let lugar = lugares.first else {
        print("No se encontró la dirección")
        throw URLError(.cannotFindHost)
    }

    return lugar.location.coordinate
}
