import SwiftUI

struct RenglonLlamadaRealizada: View {
    var llamada: LlamadaRealizada

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(llamada.donante)
                    .foregroundColor(.primary)
                Text(llamada.telefono)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(llamada.resultado)
                .font(.subheadline)
                .bold()
                .foregroundColor(colorTexto())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(colorFondo())
                .cornerRadius(14)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    func colorTexto() -> Color {
        if llamada.resultado == "Promesa" {
            return .white
        }
        return .primary
    }

    func colorFondo() -> Color {
        if llamada.resultado == "Promesa" {
            return Palette.turquesaOscuro
        }
        return Palette.fondo
    }
}

#Preview {
    RenglonLlamadaRealizada(llamada: LlamadaRealizada(id: 1,
                                                      idDonante: 5,
                                                      donante: "Ana Sofía Villarreal",
                                                      telefono: "81 8456 7781",
                                                      resultado: "Promesa"))
}
