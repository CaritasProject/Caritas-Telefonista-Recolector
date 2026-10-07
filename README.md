# Cáritas de Monterrey - Telefonista y Recolector

Aplicación iOS (SwiftUI) para los roles operativos de **Telefonista** y **Recolector** de Cáritas de Monterrey, A.B.P. El Administrador usa la app de iPad.

- iPhone, iOS 26.5, solo en vertical.
- Se conecta a la misma API Flask y base de datos de la app de iPad ([IOS-Project-Caritas](https://github.com/CaritasProject/IOS-Project-Caritas)).

---

## 1. Pantallas

| Rol | Pantalla | Qué hace |
|---|---|---|
| Ambos | Login | Correo institucional y contraseña; el rol define la pantalla de entrada. |
| Telefonista | Llamadas del día | Donantes por llamar y contactados hoy. |
| Telefonista | Registrar llamada | Resultado, compromiso, forma de pago y frecuencia. |
| Telefonista | Agendar visita | Fecha, hora y dirección; la zona sale del municipio. Solo para pagos en efectivo o cheque. |
| Recolector | Cobros del día | Ruta por horario con dirección e importe. |
| Recolector | Registrar visita | Cobrado, donante ausente o cancelado. |
| Ambos | Perfil | Hoja desde el avatar con los datos del usuario y cerrar sesión. |

---

## 2. Arquitectura

Se sigue la organización vista en clase (Consumo de servicios REST):

```
   View (SwiftUI)     Solo dibuja la pantalla y responde a lo que toca el usuario.
     │                Llama al servicio dentro de un Task { }.
     ▼
   Service            Funciones async throws con URLSession: arman la petición,
     │                validan el código HTTP y decodifican el JSON.
     ▼
   Model              Structs Codable con los mismos campos que el JSON de la API.
```

Reglas:

- Nunca se usa `URLSession` dentro de una View.
- Nunca se codifica o decodifica JSON dentro de una View.
- GET con `URLSession.shared.data(for:)`; POST con `URLRequest`, `httpMethod = "POST"` y `httpBody` con `JSONEncoder`.

### 2.1 Estructura del proyecto

```text
CaritasTelefonistaRecolector/
├── App/
│   ├── CaritasTelefonistaRecolectorApp.swift
│   └── ContentView.swift
├── Core/                      # Lo que comparten todas las pantallas
│   ├── Services/APIClient.swift   # URL de la API y token de la sesión
│   └── Utils/Palette.swift        # Colores de la app
└── Features/                  # Una carpeta por rol
    ├── Login/
    ├── Telefonista/
    │   ├── Views/
    │   ├── Components/
    │   ├── Services/
    │   └── Model/
    └── Recolector/
Config/Info.plist              # Permite HTTP a la API (NSAllowsLocalNetworking)
```

El proyecto usa carpetas sincronizadas de Xcode: un archivo nuevo dentro de `CaritasTelefonistaRecolector/` se agrega solo al target.

---

## 3. Conexión con la API

- **URL base:** `APIClient.urlBase` (`http://10.14.255.42:10206`).
- **Sesión:** el Login guarda el token en `APIClient.tokenSesion` y cada servicio lo manda en el header `Authorization: Bearer <token>`.

Ejemplo de un servicio:

```swift
func obtenerMunicipios() async throws -> [Municipio] {
    guard let url = URL(string: "\(APIClient.urlBase)/visitas/municipios") else {
        throw URLError(.badURL)
    }

    var request = URLRequest(url: url)
    if let token = APIClient.tokenSesion {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }

    return try JSONDecoder().decode([Municipio].self, from: data)
}
```

### 3.1 Endpoints de Agendar visita

| Método | Ruta | Uso |
|---|---|---|
| GET | `/visitas/municipios` | Municipios con su zona de recolección. |
| POST | `/visitas` | Agenda la visita (solo rol Telefonista). |

Cuerpo del POST:

```json
{
  "idDonativo": 541,
  "fecha": "2026-10-07",
  "hora": "10:30",
  "calle": "Hidalgo 1250 Pte.",
  "colonia": "Obispado",
  "idMunicipio": 9
}
```

Registrar llamada guarda primero la llamada y el compromiso, y después abre Agendar visita con `AgendarVisitaView(compromiso:registrandoLlamada:)`.
