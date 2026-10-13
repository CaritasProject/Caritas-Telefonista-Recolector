import SwiftUI

struct TarjetaMonto: View {
    var monto: String
    var detalle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Monto comprometido")
                .font(.headline)
                .foregroundColor(.primary)
            Text(monto)
                .font(.system(size: 40))
                .bold()
                .foregroundColor(Palette.turquesaOscuro)
            Text(detalle)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Palette.turquesaClaro)
        .cornerRadius(12)
    }
}

#Preview {
    TarjetaMonto(monto: "$2,900", detalle: "Efectivo · Permanente · Mensual")
        .padding(20)
}
