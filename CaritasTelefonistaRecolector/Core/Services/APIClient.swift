import Foundation

struct APIClient {
    static let urlBase = "https://losjamones.tc2007b.tec.mx:10206"

    // Lo guarda el Login al iniciar sesión; los servicios lo mandan en el header Authorization.
    // Vive en UserDefaults para que la sesión siga abierta al cerrar la app.
    static var tokenSesion: String? {
        get { UserDefaults.standard.string(forKey: "tokenSesion") }
        set { UserDefaults.standard.set(newValue, forKey: "tokenSesion") }
    }
}
