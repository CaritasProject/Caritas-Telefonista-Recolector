import Foundation

struct APIClient {
    static let urlBase = "https://losjamones.tc2007b.tec.mx:10206"

    static var tokenSesion: String? {
        get { KeychainService().read(for: "tokenSesion") }
        set {
            if let token = newValue {
                KeychainService().save(token, for: "tokenSesion")
            } else {
                KeychainService().delete(for: "tokenSesion")
            }
        }
    }
}
