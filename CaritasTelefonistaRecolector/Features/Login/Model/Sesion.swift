import Foundation

struct Credenciales: Codable {
    var correo: String
    var password: String
}

struct UsuarioSesion: Codable {
    var nombre: String
    var rol: String
}

struct Sesion: Codable {
    var token: String
    var usuario: UsuarioSesion
}

