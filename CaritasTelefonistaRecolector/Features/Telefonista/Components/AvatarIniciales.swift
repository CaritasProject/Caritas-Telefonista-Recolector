import SwiftUI

struct AvatarIniciales: View {
    var iniciales: String

    var body: some View {
        Text(iniciales)
            .font(.subheadline)
            .bold()
            .foregroundColor(.white)
            .frame(width: 44, height: 44)
            .background(Palette.turquesaOscuro)
            .clipShape(.circle)
    }
}

#Preview {
    AvatarIniciales(iniciales: "LC")
}
