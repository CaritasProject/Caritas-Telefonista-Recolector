import SwiftUI

struct RenglonDato: View {
    var etiqueta: String
    var valor: String

    var body: some View {
        HStack(spacing: 12) {
            Text(etiqueta)
                .foregroundColor(.primary)
            Spacer()
            Text(valor)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    RenglonDato(etiqueta: "Monto", valor: "$1,500")
}
