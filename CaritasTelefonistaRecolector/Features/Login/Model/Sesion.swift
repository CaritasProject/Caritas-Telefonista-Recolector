import Foundation

struct Credenciales: Codable {
    var correo: String
    var password: String
}

struct Sesion: Codable {
    var token: String
}
