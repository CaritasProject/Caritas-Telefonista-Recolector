import SwiftUI

struct AvatarPerfil: View {
    @Binding var sesionIniciada: Bool

    @State private var perfil: Perfil? = nil
    @State private var mostrandoPerfil = false

    var body: some View {
        Button {
            mostrandoPerfil.toggle()
        } label: {
            AvatarIniciales(iniciales: iniciales())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $mostrandoPerfil) {
            PerfilView(perfil: perfil, sesionIniciada: $sesionIniciada)
        }
        .task {
            do {
                perfil = try await obtenerPerfil()
            } catch {
                print("No se pudo cargar el perfil")
            }
        }
    }

    func iniciales() -> String {
        if let perfil = perfil {
            let palabras = perfil.nombre.split(separator: " ").prefix(2)
            var letras = ""
            for palabra in palabras {
                if let primera = palabra.first {
                    letras += String(primera)
                }
            }
            return letras.uppercased()
        }
        return ""
    }
}

#Preview {
    AvatarPerfil(sesionIniciada: .constant(true))
}
