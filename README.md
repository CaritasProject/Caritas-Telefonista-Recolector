# Cáritas de Monterrey - Telefonista y Recolector

Aplicación iOS (SwiftUI) para los roles operativos de **Telefonista** y **Recolector** de Cáritas de Monterrey, A.B.P.

---

## 1. Arquitectura

La aplicación sigue el mismo patrón modular y desacoplado del ecosistema del proyecto:

```
   View (SwiftUI)          Presentación e interacción de usuario.
     │
     ▼
   Service (ObservableObject, @MainActor)
     │                     Maneja estado reactivo (@Published) por Feature.
     ▼
   APIClient (Core/Services)
     │                     Gestión de peticiones HTTP a la API REST.
     ▼
   Model (Core/Model)      Structs Decodable/Encodable.
```

### 1.1 Estructura del Proyecto

```text
CaritasTelefonistaRecolector/
├── App/                       # Ciclo de vida de la app, delegados y configuración
│   ├── CaritasApp.swift
│   └── Info.plist
├── Core/                      # Componentes transversales
│   ├── Components/            # Botones, tarjetas y vistas reutilizables
│   ├── Model/                 # Modelos globales (Usuario, Donante, Recolección)
│   ├── Services/              # APIClient, SesionService
│   └── Utils/                 # Extensiones, formateadores y paleta de colores
└── Features/                  # Módulos por función/rol
    ├── Login/                 # Autenticación
    ├── Telefonista/           # Búsqueda de donantes, llamadas, agendado de recolecciones
    └── Recolector/            # Rutas del día, confirmación y estatus de recolección
```

---

## 2. Conexión con el Backend

Esta aplicación se conecta a la API central de Cáritas:
- **API URL Base:** Definida en `Info.plist` (`API_BASE_URL`).
- **Autenticación:** Tokens o cookies de sesión administrados vía `APIClient`.
