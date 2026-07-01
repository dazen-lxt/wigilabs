# Wigilabs

App iOS nativa (SwiftUI) que consume [TheCatAPI](https://thecatapi.com) para votar razas de gatos al estilo Tinder y navegar un listado de fotos con detalle.

## Demo

![Demo de la app](docs/demo.gif)

## Features

### 1. Votar por raza (estilo Tinder)
- Cada raza se muestra como una tarjeta con su foto y nombre.
- Arrastra la tarjeta: rota levemente y se tiñe de **verde** (me gusta) o **rojo** (no me gusta) según la dirección, con la siguiente tarjeta ya precargada detrás.
- Al soltar pasado un umbral (o tocando los botones "Me gusta"/"No me gusta", que hacen lo mismo), el voto se guarda **localmente** con fecha, nombre de la raza y tipo de voto.

### 2. Historial de votos
- Lista de todos los votos guardados: fecha, raza y tipo (Me gusta / No me gusta).
- Tocar un registro busca la foto completa por su id y navega al detalle del gato (misma pantalla que el listado de Gatos).

### 3. Listado y detalle de gatos
- Grid de fotos de gatos.
- Al tocar una, navega al detalle: foto grande y, si la API la trae, información de la raza (origen, temperamento, descripción).

## Arquitectura

**MVVM + Repository**, con `URLSession`/`async-await` nativo y **SwiftData** para persistencia — sin dependencias de terceros.

```
View  →  ViewModel  →  Repository  →  Service (API) / Store (SwiftData)
```

- **View**: SwiftUI puro, sin lógica de negocio.
- **ViewModel**: `@Observable`, expone estado (`isLoading`, `errorMessage`, datos) y acciones. No conoce `URLSession` ni SwiftData directamente.
- **Repository**: combina la fuente remota (API) y local (persistencia) detrás de un protocolo, así los ViewModels son testeables con fakes.
- **Service/Store**: `CatAPIService` (red) y `VoteStore` (SwiftData) son las únicas piezas que tocan `URLSession`/`ModelContext`.

Cada capa depende de **protocolos**, no de implementaciones concretas — es lo que permite que `WigilabsTests` use fakes en vez de red/DB real.

## Organización del proyecto

```
Wigilabs/
  Core/
    Config/        AppConfig.swift            → lee la API key del Info.plist
    Models/         Breed, CatImage, VoteType   → DTOs / value types
    Networking/     APIClient, CatAPIService,   → capa HTTP (URLSession + async/await)
                     Endpoint, NetworkError
    Persistence/     VoteRecord (@Model),        → SwiftData
                     VoteStore
    Repository/      VotingRepository,           → combina red + persistencia
                     CatCatalogRepository
  Features/
    Voting/          VotingView, VotingViewModel,  → pantalla de votación + historial
                      VoteHistoryView, VotingCard
    CatList/         CatListView, CatListViewModel, → listado + detalle de gatos
                      CatDetailView
  RootView.swift      TabView("Votar", "Gatos"), cada tab con su propio NavigationStack
  WigilabsApp.swift   punto de entrada, .modelContainer(for: VoteRecord.self)
  Localizable.xcstrings  todos los strings visibles, sin literales sueltos en el código
  Info.plist          físico (no autogenerado), expone CAT_API_KEY vía sustitución de build setting

WigilabsTests/        unit tests (ViewModels + VoteStore) con fakes/SwiftData en memoria
WigilabsUITests/      UI tests de humo (navegación entre tabs, pantalla de votación, historial)
Config/
  Secrets.xcconfig.example   plantilla commiteada
  Secrets.xcconfig           tu API key real (gitignorado, no se sube)
.github/workflows/ci.yml     build + test en cada push/PR a main
```

## Setup

1. Clona el repo y ábrelo en Xcode 16+ (`Wigilabs.xcodeproj`).
2. (Opcional pero recomendado) Consigue una API key gratuita en [thecatapi.com/signup](https://thecatapi.com/signup) y cópiala en un archivo nuevo `Config/Secrets.xcconfig`:
   ```
   CAT_API_KEY = tu_key_aqui
   ```
   Sin key, la app funciona igual (lectura a un rate-limit más bajo; el guardado local del voto nunca depende de esto), pero **TheCatAPI no devuelve el campo `breeds` en `/images/search` sin key** — así que el detalle de un gato (tab Gatos o desde el Historial) va a mostrar "No hay información de raza disponible" en vez de origen/temperamento/descripción. Con la key configurada, esa info sí aparece.
3. Build & Run (⌘R) en cualquier simulador con iOS 17+.

## Tests

- **11 unit tests** (`WigilabsTests`): `VotingViewModel`, `CatListViewModel` (con repositorios fake) y `VoteStore` (SwiftData en memoria).
- **4 UI tests** (`WigilabsUITests`): navegación entre tabs, pantalla de votación, apertura/cierre del historial.

Correr desde Xcode (⌘U) o por línea de comandos:
```bash
xcodebuild test -project Wigilabs.xcodeproj -scheme Wigilabs \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'
```

## CI

`.github/workflows/ci.yml` compila y corre toda la suite de tests en cada push/PR a `main`. Ver [Actions](../../actions) para el estado de los runs.

## Stack

- Swift 5 / SwiftUI, iOS 17.0+
- Concurrencia: `async/await` nativo (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- Persistencia: SwiftData
- Networking: `URLSession` (sin Alamofire ni otras dependencias)
- Localización: String Catalog (`Localizable.xcstrings`), español
- Tests: XCTest (unit + UI)
