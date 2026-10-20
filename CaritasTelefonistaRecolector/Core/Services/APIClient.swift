import Foundation

struct APIClient {
    static let urlBase = "https://losjamones.tc2007b.tec.mx:10206"

    // Lo guarda el Login al iniciar sesión; los servicios lo mandan en el header Authorization.
    static var tokenSesion: String? = nil
}
