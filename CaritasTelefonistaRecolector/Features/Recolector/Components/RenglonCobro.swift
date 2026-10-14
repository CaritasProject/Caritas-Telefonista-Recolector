import SwiftUI

struct RenglonCobro: View {
    var cobro: Cobro

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                Text(String(cobro.hora.prefix(5)))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Palette.turquesa)

                VStack(alignment: .leading, spacing: 6) {
                    Text(cobro.donante)
                        .font(.title3)
                        .foregroundColor(.black)
                    Text(cobro.direccion)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 10) {
                        Text("$\(cobro.importe, format: .number)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Text(cobro.formaPago)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Palette.fondo)
                            .cornerRadius(14)
                    }
                    .padding(.top, 4)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

#Preview {
    RenglonCobro(cobro: Cobro(id: 1, fecha: "2026-10-02", hora: "09:00", donante: "Rosa Elena Garza Treviño", direccion: "Río Guadalquivir 412, Col. Del Valle, San Pedro Garza García", importe: 1500, formaPago: "Efectivo", estatus: "PENDIENTE"))
}
