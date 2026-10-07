import Foundation

struct APIClient {
    static let urlBase = "http://10.14.255.42:10206"

    // Lo guarda el Login al iniciar sesión; los servicios lo mandan en el header Authorization.
    static var tokenSesion: String? = nil
}
