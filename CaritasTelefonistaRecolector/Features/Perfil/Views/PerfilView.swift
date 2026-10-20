import SwiftUI

struct PerfilView: View {
    var perfil: Perfil?
    @Binding var sesionIniciada: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if let perfil = perfil {
                    Section {
                        HStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 56))
                                .foregroundColor(Palette.turquesa)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(perfil.nombre)
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text(perfil.correo)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    Section {
                        renglon(titulo: "Rol", valor: perfil.rol.capitalized)
                        renglon(titulo: "Área", valor: perfil.area)
                    }
                } else {
                    Text("No se pudo cargar tu perfil.")
                        .foregroundColor(.secondary)
                }

                Section {
                    Button(role: .destructive) {
                        cerrarSesion()
                    } label: {
                        Text("Cerrar sesión")
                    }
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }

    func renglon(titulo: String, valor: String) -> some View {
        HStack {
            Text(titulo)
            Spacer()
            Text(valor)
                .foregroundColor(.secondary)
        }
    }

    func cerrarSesion() {
        dismiss()
        APIClient.tokenSesion = nil
        sesionIniciada = false
    }
}

#Preview {
    PerfilView(perfil: Perfil(nombre: "Laura Ríos Cantú",
                              correo: "laura.rios@caritas.org.mx",
                              rol: "TELEFONISTA",
                              area: "Atención a donantes"),
               sesionIniciada: .constant(true))
}
