import SwiftUI

struct RenglonLlamadaPendiente: View {
    var llamada: LlamadaPendiente

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(llamada.donante)
                .foregroundColor(.primary)
            Text(llamada.telefono)
                .foregroundColor(.secondary)
            Text(llamada.motivo)
                .font(.subheadline)
                .bold()
                .foregroundColor(Palette.turquesaOscuro)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    RenglonLlamadaPendiente(llamada: LlamadaPendiente(id: 1,
                                                      idDonante: 3,
                                                      donante: "Jorge Alberto Sandoval",
                                                      telefono: "81 1234 5678",
                                                      motivo: "Confirmar cobro"))
}
