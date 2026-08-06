# Ocupa2

Aplicación móvil desarrollada en Flutter para consumir la API REST oficial de Ocupa2, una plataforma de trabajos temporales.

## API

- Base URL: `https://ocupa2.ia3x.com/apix`
- Swagger: `https://ocupa2.ia3x.com/apix/docs`

La mayoría de los endpoints privados requieren:

```http
Authorization: Bearer <token>
```

## Tecnologías y dependencias

El proyecto ya incluye:

- Flutter
- `flutter_riverpod`
- `go_router`
- `dio`
- `flutter_secure_storage`
- `equatable`
- `intl`

Después de actualizar el repositorio, ejecutar:

```bash
flutter pub get
flutter analyze
flutter test
```

No es necesario volver a ejecutar `flutter create`.

## Estructura del proyecto

```text
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   └── theme/
├── core/
│   ├── config/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── home/
│   ├── profile/
│   └── offers/
└── main.dart
```

Cada integrante debe desarrollar su módulo dentro de:

```text
lib/features/nombre_del_modulo/
```

Estructura recomendada para una feature:

```text
nombre_del_modulo/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── repositories/
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

No es obligatorio crear carpetas vacías. Cada módulo debe crear solo los archivos que realmente necesite.

## Cómo empezar a trabajar

### 1. Actualizar el repositorio local

```bash
git checkout develop
git pull origin develop
flutter pub get
```

### 3. Crear la feature

Cada integrante debe trabajar únicamente dentro de su módulo y reutilizar la infraestructura común.

Flujo recomendado:

```text
Pantalla
  ↓
Provider o controlador
  ↓
Repositorio
  ↓
DataSource
  ↓
ApiClient
  ↓
API REST
```

## Infraestructura que ya existe

### Cliente HTTP

Usar el provider existente:

```dart
final apiClient = ref.read(apiClientProvider);
```

Ejemplo:

```dart
final response = await apiClient.get<Map<String, dynamic>>(
  '/news',
);
```

No crear nuevas instancias de `Dio` y no repetir la Base URL.

### Token JWT

El token se guarda con `TokenStorage` y `AuthInterceptor` lo agrega automáticamente a las solicitudes privadas.

```dart
final tokenStorage = ref.read(tokenStorageProvider);
await tokenStorage.saveAccessToken(token);
```

No guardar el JWT en `SharedPreferences`, variables globales ni archivos del proyecto.

### Manejo de errores

El proyecto ya incluye excepciones y mapeo de errores en:

```text
lib/core/errors/
```

Las pantallas deben mostrar mensajes controlados y nunca exponer errores internos de Dio o stack traces.

### Navegación

Las rutas se registran en:

```text
lib/app/router/route_names.dart
lib/app/router/app_router.dart
```

Usar rutas nombradas:

```dart
context.pushNamed(RouteNames.nombreDeRuta);
```

Evitar escribir rutas directamente en varias pantallas.

### Diseño compartido

Usar siempre:

```text
lib/app/theme/
lib/core/widgets/
```

Componentes disponibles:

- `AppButton`
- `AppTextField`
- `AppCard`
- `AppLoading`
- `AppErrorView`
- `AppEmptyState`

No crear otros botones, campos o loaders si los existentes cubren la necesidad.

## Reglas para cada módulo

Cada módulo debe:

- usar `ApiClient` compartido;
- usar Riverpod para estado e inyección;
- crear modelos según Swagger y respuestas reales;
- manejar carga, éxito, vacío y error;
- usar el sistema visual compartido;
- respetar `SafeArea` y pantallas pequeñas;
- agregar pruebas básicas;
- no modificar módulos de otros integrantes;
- no subir tokens ni datos sensibles.

## Archivos que no deben modificarse sin coordinación

```text
lib/main.dart
lib/app/app.dart
lib/app/theme/
lib/core/network/
lib/core/storage/
lib/core/errors/
pubspec.yaml