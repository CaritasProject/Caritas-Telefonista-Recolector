import SwiftUI

struct LoginView: View {
    @Binding var sesionIniciada: Bool
    @Binding var rol: String

    @State private var correo = ""
    @State private var password = ""
    @State private var cargando = false
    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image("LogoCaritas")
                    .resizable(resizingMode: .stretch)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 196)

                Text("Telefonista y Recolector")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextField("Correo", text: $correo)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)

                SecureField("Contraseña", text: $password)
                    .textFieldStyle(.roundedBorder)

                Button {
                    entrar()
                } label: {
                    Text(cargando ? "Entrando…" : "Iniciar sesión")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(Palette.turquesa)
                .controlSize(.large)
            }
            .padding(20)
            .padding(.top, 60)
        }
        .background(Palette.fondo)
        .alert(mensajeAlerta, isPresented: $mostrarAlerta) {
            Button("OK") {}
        }
    }

    func entrar() {
        if correo == "" {
            mensajeAlerta = "Escribe tu correo."
            mostrarAlerta.toggle()
        } else if password == "" {
            mensajeAlerta = "Escribe tu contraseña."
            mostrarAlerta.toggle()
        } else {
            cargando = true
            Task {
                do {
                    rol = try await iniciarSesion(correo: correo, password: password)
                    sesionIniciada = true
                } catch {
                    mensajeAlerta = "No se pudo iniciar sesión. Revisa tu correo y contraseña."
                    mostrarAlerta.toggle()
                }
                cargando = false
            }
        }
    }
}

#Preview {
    LoginView(sesionIniciada: .constant(false), rol: .constant(""))
}
