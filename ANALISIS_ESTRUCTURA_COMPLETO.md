# 📱 ANÁLISIS EXHAUSTIVO - ARQUITECTURA DEL PROYECTO FLUTTER "HAPPY RIDE"

---

## 📋 ÍNDICE
1. [Estructura General](#1-estructura-general)
2. [Core - Servicios Compartidos](#2-core--servicios-compartidos)
3. [Features](#3-features)
4. [Inyección de Dependencias](#4-inyección-de-dependencias)
5. [Rutas y Navegación](#5-rutas-y-navegación)
6. [Flujos Principales](#6-flujos-principales)
7. [Modelos de Datos](#7-modelos-de-datos)
8. [Validaciones y Temas](#8-validaciones-y-temas)
9. [Servicios Principales](#9-servicios-principales)

---

## 1. ESTRUCTURA GENERAL

### 📂 Organización de `/lib`
```
lib/
├── main.dart                          # Entry point
├── app/
│   ├── app.dart                      # Widget MaterialApp principal
│   ├── app_dependencies.dart         # MultiBlocProvider (DI en UI)
│   └── routes.dart                   # Sistema de rutas
├── injection/
│   └── service_locator.dart          # Configuración GetIt
├── core/                             # Lógica compartida
│   ├── constants/                    # Constantes globales
│   ├── errors/                       # Manejo de errores
│   ├── network/                      # Cliente HTTP (Dio)
│   ├── storage/                      # Almacenamiento seguro
│   ├── theme/                        # Estilos y colores
│   ├── utils/                        # Utilidades generales
│   └── validators/                   # Validaciones de formularios
└── features/                         # Features del app
    ├── auth/                         # Autenticación
    ├── home/                         # Pantalla inicial
    ├── rides/                        # Crear viajes (driver)
    └── ride_offers/                  # Ver ofertas (rider)
```

### 🎯 Propósito General
**Happy Ride** es una app de carpooling diseñada en dos roles principales:
- **Conductor (Driver)**: Crea viajes y ofrece asientos
- **Pasajero (Rider)**: Busca y se une a viajes disponibles

---

## 2. CORE - SERVICIOS COMPARTIDOS

### 📁 `/core/constants/`
**`api_constants.dart`**
```dart
class ApiConstants {
  static String baseUrl = dotenv.env['BASE_URL'] ?? '';    // URL del servidor
  static String apiKey = dotenv.env['API_KEY'] ?? '';      // API Key de Supabase
}
```
- Lee variables de entorno desde `.env`
- Configuración centralizada para HTTP

### 📁 `/core/errors/`

**`failures.dart`** - Clases de error para BLoC
```dart
abstract class Failure {
  final String message;
}
class ServerFailure extends Failure {}  // Errores de servidor
```

**`exceptions.dart`** - Excepciones internas
```dart
class ServerException implements Exception {
  final String message;
}
```

**`error_handler.dart`** - Extrae mensajes de Dio
```dart
static String getErrorMessage(DioException e)
  // Extrae msg, message, error_description, error del JSON
```

### 📁 `/core/network/`

**`dio_client.dart`** - Cliente HTTP con interceptores
```dart
class DioClient {
  - baseUrl: Supabase
  - Timeout: 30 segundos
  - Headers: Content-Type, apiKey
  - Autenticación: Bearer token inyectado por interceptor
  - Logging en debug
}

// Interceptor de autenticación:
- Lee token de TokenStorage
- Lo agrega al header 'Authorization: Bearer <token>'
```

### 📁 `/core/storage/`

**`token_storage.dart`** - Almacenamiento seguro de tokens
```dart
class TokenStorage {
  - saveSession(accessToken, refreshToken)           // Guardar tokens
  - getAccessToken()                                  // Obtener access token
  - getRefreshToken()                                 // Obtener refresh token
  - clearSession()                                    // Limpiar todo
  - hasSession()                                      // ¿Hay token?
  
  Usa: FlutterSecureStorage (encriptado en device)
}
```

**`session_storage.dart`** - Almacenamiento de sesión extendido
```dart
class SessionStorage extends TokenStorage {
  + getAuthId()         // ID de autenticación de Supabase
  + getEmail()          // Correo del usuario
  + saveSession(accessToken, refreshToken, authId, email)
}
```

### 📁 `/core/theme/`

**`app_colors.dart`** - Paleta de colores
```dart
class AppColors {
  static const Color slate900 = 0xFF0F172A      // Negro oscuro (fondo)
  static const Color slate400 = 0xFF94A3B8      // Gris claro
  static const Color slate800 = 0xFF1e293b      // Gris oscuro
  static const Color blue900 = 0xFF1E3A5F       // Azul oscuro
  static const Color teal600 = 0xFF0D9488       // Verde agua
  static const Color amber700 = 0xFFB45308      // Naranja
  static const Color gray50 = 0xFFF8FAFC        // Blanco grisáceo
  static const Color errorRed = 0xFFB00020      // Rojo error
  static const Color white = 0xFFFFFFFF         // Blanco puro
  static const Color black = 0xFF000000         // Negro puro
}
```

**`app_text_styles.dart`** - Estilos de texto
```dart
class AppTextStyles {
  - primary: TextStyle(fontFamily: 'Roboto', fontWeight: w400)
  - secondary: TextStyle(fontFamily: 'Roboto', fontWeight: w500)
}
```

### 📁 `/core/validators/`

**`form_validators.dart`** - Validadores reutilizables
```dart
String? emptyFieldValidator(String? value, {String fieldName})
  // Valida que el campo no esté vacío

String? uniandesEmailValidator(String? value)
  // Valida correo @uniandes.edu.co (regex: ^[\w-\.]+@uniandes\.edu\.co$)
```

---

## 3. FEATURES

### 🔐 FEATURE: AUTH (Autenticación)

#### 📊 Estructura
```
auth/
├── data/
│   ├── datasources/
│   │   ├── auth_datasource_remote.dart              # Contrato
│   │   └── auth_datasource_remote_supabase.dart     # Implementación
│   ├── models/
│   │   ├── auth_model.dart                          # DTO autenticación
│   │   └── user_model.dart                          # DTO usuario
│   └── repositories/
│       └── auth_repository_remote.dart              # Implementación repositorio
├── domain/
│   ├── entities/
│   │   └── user.dart                                # Entidad Usuario
│   ├── repositories/
│   │   └── auth_repository.dart                     # Contrato repositorio
│   └── usecases/
│       ├── login_user.dart                          # Caso uso: login
│       ├── logout_user.dart                         # Caso uso: logout
│       └── restore_session.dart                     # Caso uso: restaurar sesión
├── presentation/
│   ├── view/
│   │   ├── pages/
│   │   │   └── login_page.dart                      # Pantalla login
│   │   └── widgets/
│   │       ├── auth_gate.dart                       # Guard de autenticación
│   │       ├── auth_session_listener.dart           # Listener de sesión
│   │       ├── login_form.dart                      # Formulario
│   │       ├── login_email_field.dart               # Field email
│   │       ├── login_password_field.dart            # Field password
│   │       └── primary_action_button.dart           # Botón principal
│   └── view_model/
│       ├── auth_cubit.dart                          # Estado y lógica
│       └── auth_state.dart                          # Definición de estados
└── injection/
    └── auth_injection.dart                          # Inyección dependencias
```

#### 📦 Entidades Principales

**`user.dart`** - Entidad Usuario
```dart
class User extends Equatable {
  final int id;                  // ID en DB
  final String firstName;        // Nombre
  final String lastName;         // Apellido
  final int zoneId;             // Zona geográfica
  final String authId;          // ID de Supabase Auth
  final String email;           // Correo
  final int? riderId;           // ID como pasajero
  final int? driverId;          // ID como conductor
}
```

**`user_model.dart`** - DTO Usuario
```dart
class UserModel extends User {
  factory UserModel.fromJson(Map<String, dynamic> json)
    // Mapea snake_case -> camelCase
    // JSON: first_name → firstName, zone_id → zoneId, etc.
}
```

**`auth_model.dart`** - DTO Autenticación
```dart
class AuthModel {
  final String accessToken;     // Bearer token
  final String refreshToken;    // Token para refrescar
  final String authId;          // ID de Supabase Auth
  final String email;           // Correo
  
  factory AuthModel.fromJson(Map<String, dynamic> json)
    // Extrae de response de Supabase auth
}
```

#### 🔄 Casos de Uso

**`login_user.dart`**
```dart
class LoginUser {
  call(email: String, password: String) → Future<Either<Failure, User>>
  
  Flujo:
  1. Llama repository.login(email, password)
  2. Retorna User o Failure
}
```

**`logout_user.dart`**
```dart
class LogoutUser {
  call() → Future<Either<Failure, void>>
  
  Flujo:
  1. Limpia tokens del storage
}
```

**`restore_session.dart`**
```dart
class RestoreSession {
  call() → Future<Either<Failure, User>>
  
  Flujo:
  1. Verifica si hay token guardado
  2. Si sí, obtiene datos del usuario
  3. Si token expirado, lo refresca
}
```

#### 🌐 Data Sources

**`auth_datasource_remote_supabase.dart`** - Implementación Supabase
```dart
Future<UserModel> login(email, password) {
  1. POST /auth/v1/token con credenciales
  2. Recibe: accessToken, refreshToken, authId
  3. Guarda tokens en TokenStorage
  4. Obtiene datos del usuario:
     - /rest/v1/users (con authId)
     - /rest/v1/riders (ID as rider)
     - /rest/v1/drivers (ID as driver)
  5. Retorna UserModel con todos los datos
}

Future<UserModel> restoreSession() {
  1. GET /auth/v1/user con Authorization header
  2. Si 403 (token expirado):
     - Llama refreshSession(refreshToken)
  3. Obtiene datos del usuario como en login
  4. Retorna UserModel
}

Future<AuthModel> refreshSession(refreshToken) {
  1. POST /auth/v1/token con grant_type=refresh_token
  2. Recibe nuevos tokens
  3. Los guarda en TokenStorage
}
```

#### 📋 Repositorio

**`auth_repository_remote.dart`**
```dart
class AuthRepositoryRemote implements AuthRepository {
  Future<Either<Failure, User>> login(email, password) {
    1. Llama dataSourceRemote.login()
    2. Si ServerException → Left(ServerFailure)
    3. Si ok → Right(user)
  }

  Future<Either<Failure, void>> logout() {
    1. tokenStorage.clearSession()
  }

  Future<Either<Failure, User>> restoreSession() {
    1. Verifica tokenStorage.hasSession()
    2. Llama dataSourceRemote.restoreSession()
  }
}
```

#### 🎮 CuBit - Estado y Lógica

**`auth_state.dart`** - Estados
```dart
enum AuthStatus {
  initial,           // Inicial
  loading,           // Cargando
  authenticated,     // Usuario autenticado
  unauthenticated,   // Usuario no autenticado
  error,             // Error
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
}
```

**`auth_cubit.dart`** - Lógica
```dart
class AuthCubit extends Cubit<AuthState> {
  Future<void> restoreUser() {
    1. Emite loading
    2. Llama restoreSession()
    3. Si ok → Emite authenticated con user
    4. Si error → Emite unauthenticated con error
  }

  Future<void> login(email, password) {
    1. Emite loading
    2. Llama loginUser(email, password)
    3. Si ok → Emite authenticated con user
    4. Si error → Emite error con mensaje
  }

  Future<void> logout() {
    1. Emite loading
    2. Llama logoutUser()
    3. Si ok → Emite unauthenticated
    4. Si error → Emite error
  }
}
```

#### 🛡️ Auth Gate

**`auth_gate.dart`** - Guard de autenticación
```dart
class AuthGate extends StatefulWidget {
  initState() {
    context.read<AuthCubit>().restoreUser()  // Restaura sesión al iniciar app
  }

  BlocListener(
    authenticated → Navigator.pushReplacementNamed(testSession)
    unauthenticated → Navigator.pushReplacementNamed(home)
  )

  Render: CircularProgressIndicator durante validación
}
```

---

### 🏠 FEATURE: HOME

#### 📊 Estructura
```
home/
└── presentation/
    └── view/
        ├── pages/
        │   ├── home_page.dart              # Pantalla principal
        │   └── test_session_page.dart      # Test de sesión
        └── widgets/
            ├── brand_header_section.dart   # Encabezado con logo
            ├── hero_section.dart           # Sección destacada
            └── primary_action_button.dart  # Botón principal
```

#### 🎨 Diseño
- **HomePage**: Pantalla de bienvenida (usuario no autenticado)
  - Encabezado con marca "Happy Ride"
  - Sección destacada
  - Botón "Iniciar sesión" → navega a `/login`

- **TestSessionPage**: Validación post-login
  - Muestra datos del usuario autenticado

---

### 🚗 FEATURE: RIDES (Crear Viajes - Conductor)

#### 📊 Estructura
```
rides/
├── data/
│   ├── datasources/         # (vacío - lógica en repositorio)
│   ├── models/              # (DTOs)
│   └── repositories/
│       └── rides_repository_impl.dart    # Implementación
├── domain/
│   ├── entities/
│   │   ├── ride.dart               # Entidad Viaje
│   │   ├── vehicle.dart            # Entidad Vehículo
│   │   └── zone.dart               # Entidad Zona
│   ├── repositories/
│   │   └── rides_repository.dart   # Contrato (vacío)
│   └── usecases/               # (vacío - se usan directamente)
├── presentation/
│   ├── view/
│   │   └── pages/
│   │       └── create_ride_page.dart   # Pantalla crear viaje
│   └── view_model/
│       ├── create_ride_cubit.dart      # Lógica
│       └── create_ride_state.dart      # Estados
└── injection/                          # (vacío - no se registra en DI)
```

#### 📦 Entidades

**`ride.dart`** - Viaje
```dart
class Ride {
  final int? id;                  // (null al crear)
  final int driverId;             // ID del conductor
  final int vehicleId;            // ID del vehículo
  final int zoneId;               // Zona geográfica
  final String source;            // Punto de salida
  final String destination;       // Destino
  final String date;              // Fecha (YYYY-MM-DD)
  final String departureTime;     // Hora (HH:mm)
  final String state;             // Estado (active, cancelled, etc)
  final String type;              // Tipo (compartido, directo, etc)
  final double price;             // Precio por asiento
}
```

**`vehicle.dart`** - Vehículo
```dart
class Vehicle {
  final int id;
  final String brand;             // Marca
  final String model;             // Modelo
  final String color;             // Color
  final String licensePlate;      // Placa
  final int numberSlots;          // Total de asientos
  final int driverId;             // Conductor propietario

  String get infoCarro => '$brand $model · $licensePlate'
  int get puestosDisponibles => numberSlots - 1  // Sin incluir al conductor
}
```

**`zone.dart`** - Zona
```dart
class Zone {
  final int id;
  final String name;              // Nombre de la zona
  final String description;       // Descripción
}
```

#### 🎮 CuBit - Crear Viaje

**`create_ride_state.dart`** - Estados
```dart
abstract class CreateRideState {}

class CreateRideInitial extends CreateRideState {}
  // Estado inicial

class CreateRideLoadingVehicles extends CreateRideState {}
  // Cargando vehículos y zonas

class CreateRideReady extends CreateRideState {
  List<Vehicle> vehicles;        // Vehículos del conductor
  List<Zone> zones;              // Zonas disponibles
  Vehicle? selectedVehicle;      // Vehículo seleccionado
  Zone? selectedZone;            // Zona seleccionada
  bool isSubmitting;             // ¿Enviando?
}

class CreateRideSuccess extends CreateRideState {}
  // Viaje creado exitosamente

class CreateRideError extends CreateRideState {
  String message;                 // Mensaje de error
}
```

**`create_ride_cubit.dart`** - Lógica
```dart
class CreateRideCubit extends Cubit<CreateRideState> {
  Future<void> loadVehicles() {
    1. Emite CreateRideLoadingVehicles
    2. Obtiene driverId usando userId (relación con user)
    3. Parallel requests:
       - repository.getVehiclesByDriver(driverId)
       - repository.getZones()
    4. Si vehículos vacíos → error
    5. Si ok → Emite CreateRideReady(vehicles, zones)
  }

  void selectVehicle(Vehicle v) {
    Actualiza el vehículo seleccionado en estado
  }

  void selectZone(Zone z) {
    Actualiza la zona seleccionada en estado
  }

  Future<void> createRide({
    source, destination, date, departureTime, type, price
  }) {
    1. Valida que vehículo y zona estén seleccionados
    2. Emite isSubmitting = true
    3. Obtiene driverId
    4. Crea objeto Ride
    5. Llama repository.createRide(ride)
    6. Si ok → Emite CreateRideSuccess
    7. Si error → Emite CreateRideError
  }
}
```

#### 📋 Repositorio

**`rides_repository_impl.dart`** - Implementación
```dart
class RidesRepositoryImpl {
  Future<List<Vehicle>> getVehiclesByDriver(int driverId) {
    GET /rest/v1/vehicles?driver_id=eq.{driverId}
  }

  Future<List<Zone>> getZones() {
    GET /rest/v1/zones
  }

  Future<int> getDriverIdByUserId(int userId) {
    GET /rest/v1/drivers?user_id=eq.{userId}
    Retorna drivers[0].id
  }

  Future<void> createRide(Ride ride) {
    POST /rest/v1/rides con datos del viaje
  }
}
```

---

### 🎯 FEATURE: RIDE_OFFERS (Ver Ofertas - Pasajero)

#### 📊 Estructura
```
ride_offers/
├── data/
│   ├── data_sources/
│   │   ├── ride_offers_remote_datasource.dart      # Contrato
│   │   └── ride_offers_remote_datasource_impl.dart # Implementación
│   ├── models/                  # (DTOs)
│   └── repositories/
│       └── ride_offers_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── ride_offer.dart          # Entidad oferta
│   │   ├── ride_offer_filters.dart  # Filtros de búsqueda
│   │   └── zone.dart                # Zona (compartido con Auth)
│   ├── repositories/
│   │   └── ride_offers_repository.dart
│   └── usecases/
│       ├── get_ride_offers.dart     # Obtener ofertas
│       └── get_zones.dart           # Obtener zonas
├── presentation/
│   ├── view/
│   │   ├── models/
│   │   │   └── ride_offer_view_data.dart    # ViewModel para UI
│   │   ├── pages/
│   │   │   └── ride_offers_page.dart        # Pantalla principal
│   │   └── widgets/                         # Componentes UI
│   └── view_model/
│       ├── ride_offers_cubit.dart           # Lógica
│       └── ride_offers_state.dart           # Estados
└── injection/
    └── ride_offers_injection.dart           # Inyección DI
```

#### 📦 Entidades

**`ride_offer.dart`** - Oferta de Viaje
```dart
class RideOffer {
  final String id;                # ID único
  final String driverName;        # Nombre del conductor
  final double driverRating;      # Calificación (0-5)
  final int tripsCount;           # Número de viajes realizados
  final int price;                # Precio por pasajero
  final String source;            # Salida
  final String destination;       # Destino
  final DateTime date;            # Fecha del viaje
  final String departureTime;     # Hora de salida
  final int slots;                # Asientos disponibles
  final String carModel;          # Modelo del auto
  final String zoneName;          # Nombre de la zona
  final String type;              # Tipo de viaje
}
```

**`ride_offer_filters.dart`** - Filtros
```dart
class RideOfferFilters {
  final String? zoneId;           // Zona geográfica
  final DateTime? date;           // Fecha de viaje
  final String? time;             // Hora aproximada
  final String? type;             // Tipo de viaje
  final String? sortBy;           // Ordenamiento (price, rating, etc)
  final List<String> quickFilters; // Filtros rápidos activados
}
```

#### 🎮 CuBit - Ofertas de Viaje

**`ride_offers_state.dart`** - Estados
```dart
enum RideOffersStatus {
  initial,    // Inicial
  loading,    // Cargando ofertas
  success,    // Ofertas obtenidas
  empty,      // Sin ofertas para los filtros
  error,      // Error
}

class RideOffersState {
  final RideOffersStatus status;
  final RideOfferFilters filters;           // Filtros actuales
  final List<RideOfferViewData> offers;     // Ofertas a mostrar
  final List<Zone> zones;                   // Zonas disponibles
  final String? message;                    // Mensaje (success/error)
}
```

**`ride_offers_cubit.dart`** - Lógica
```dart
class RideOffersCubit extends Cubit<RideOffersState> {
  Future<void> loadInitialData({String? preferredZoneId}) {
    1. Si hay preferredZoneId → lo agrega a filtros
    2. Llama _loadZones()
    3. Llama loadRideOffers()
  }

  Future<void> loadRideOffers() {
    1. Emite status=loading
    2. Llama getRideOffers(filters)
    3. Si error → Emite error
    4. Si lista vacía → Emite empty con mensaje
    5. Si ok → mapea a RideOfferViewData, Emite success
  }

  void updateZoneId(String? zoneId) → Actualiza filtro zona
  void updateDate(DateTime? date) → Actualiza filtro fecha
  void updateTime(String? time) → Actualiza filtro hora
  void updateType(String? type) → Actualiza filtro tipo
  void updateSortBy(String? sortBy) → Actualiza ordenamiento

  void toggleQuickFilter(String value) {
    Agrega/quita filtro rápido de la lista
  }

  Future<void> applyFilters() {
    Reload ofertas con filtros actuales
  }

  Future<void> clearFilters() {
    Limpia todos los filtros (mantiene preferredZoneId)
    Recarga ofertas
  }
}
```

#### 📋 Repositorio

**`ride_offers_repository_impl.dart`**
```dart
Future<Either<Failure, List<RideOffer>>> getRideOffers({
  required RideOfferFilters filters
}) {
  1. Construye query string con filtros
  2. GET /rest/v1/ride_offers?filters
  3. Mapea a objetos RideOffer
  4. Retorna Right(offers) o Left(failure)
}

Future<Either<Failure, List<Zone>>> getZones() {
  GET /rest/v1/zones
}
```

#### 🌐 Data Source

**`ride_offers_remote_datasource_impl.dart`**
```dart
Llama a Dio para:
  - Obtener ofertas de viajes con filtros
  - Obtener lista de zonas
```

---

## 4. INYECCIÓN DE DEPENDENCIAS

### 🏗️ Arquitectura GetIt

**`service_locator.dart`** - Configuración Global
```dart
final sl = GetIt.instance;

void setupLocator() {
  // 1. Core services (singleton)
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<DioClient>(() => DioClient(tokenStorage: sl()));

  // 2. Feature injections
  setupAuthInjection();      // Auth feature
  setupRideOffersInjection(); // RideOffers feature
}
```

**`auth_injection.dart`** - Auth Feature
```dart
void setupAuthInjection() {
  // DataSource (singleton)
  sl.registerLazySingleton<AuthDataSourceRemoteSupabase>(
    () => AuthDataSourceRemoteSupabase(
      dio: sl<DioClient>().dio,
      tokenStorage: sl<TokenStorage>(),
    ),
  );

  // Repository (singleton)
  sl.registerLazySingleton<AuthRepositoryRemote>(
    () => AuthRepositoryRemote(
      dataSourceRemote: sl<AuthDataSourceRemoteSupabase>(),
      tokenStorage: sl<TokenStorage>(),
    ),
  );

  // UseCases (factory)
  sl.registerFactory(() => LoginUser(sl<AuthRepositoryRemote>()));
  sl.registerFactory(() => LogoutUser(sl<AuthRepositoryRemote>()));
  sl.registerFactory(() => RestoreSession(sl<AuthRepositoryRemote>()));

  // CuBit (factory)
  sl.registerFactory(() => AuthCubit(
    loginUser: sl<LoginUser>(),
    logoutUser: sl<LogoutUser>(),
    restoreSession: sl<RestoreSession>(),
  ));
}
```

**`ride_offers_injection.dart`** - RideOffers Feature
```dart
void setupRideOffersInjection() {
  sl.registerLazySingleton<RideOffersRemoteDataSource>(
    () => RideOffersRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );

  sl.registerLazySingleton<RideOffersRepositoryImpl>(
    () => RideOffersRepositoryImpl(
      remoteDataSource: sl<RideOffersRemoteDataSource>(),
    ),
  );

  sl.registerFactory(() => GetRideOffers(sl<RideOffersRepositoryImpl>()));
  sl.registerFactory(() => GetZones(sl<RideOffersRepositoryImpl>()));

  sl.registerFactory(
    () => RideOffersCubit(
      getRideOffers: sl<GetRideOffers>(),
      getZones: sl<GetZones>(),
    ),
  );
}
```

### 📱 Proveedores en UI

**`app_dependencies.dart`** - BLoC Providers
```dart
class AppDependencies extends StatelessWidget {
  build(context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
      ],
      child: child,
    );
  }
}
```

---

## 5. RUTAS Y NAVEGACIÓN

### 🗺️ Sistema de Rutas

**`routes.dart`** - Definición de rutas
```dart
class AppRoutes {
  // Constantes de rutas
  static const String home = '/home';               // Bienvenida
  static const String login = '/login';             // Login
  static const String testSession = '/test-session'; // Post-auth test
  static const String createRide = '/create-ride';  // Crear viaje
  static const String rideOffers = '/ride-offers';  // Ver ofertas

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case testSession:
        return MaterialPageRoute(builder: (_) => const TestSessionPage());
      case createRide:
        return MaterialPageRoute(builder: (_) => const CreateRidePage());
      case rideOffers:
        return MaterialPageRoute(builder: (_) => const RideOffersPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const AuthGate(),  // Guard
        );
    }
  }
}
```

### 🔄 Navegación Visual

```
┌─────────────────────────────────────────┐
│          App Inicia                      │
│       AuthGate carga sesión              │
└────────┬────────────────────────────────┘
         │
    ┌────┴────┐
    ▼         ▼
[Token?]   [No token?]
    │         │
    ▼         ▼
[Login OK?]  HomePage
    │        ┌─────────────┐
    ├────────┘             │
    ▼                      ▼
TestSessionPage      LoginPage
    │                (formulario)
    ├──► CreateRidePage (driver)
    │
    └──► RideOffersPage (rider)
```

---

## 6. FLUJOS PRINCIPALES

### 🔐 FLUJO 1: LOGIN → HOME → TEST SESSION

```
1. App inicia (main.dart)
   ↓
2. AuthGate intenta restaurar sesión
   ├─ Si token existe: RestoreSession usecase
   │  ├─ GET /auth/v1/user (Supabase Auth)
   │  ├─ GET /rest/v1/users (datos del usuario)
   │  ├─ GET /rest/v1/riders (info como rider)
   │  ├─ GET /rest/v1/drivers (info como driver)
   │  └─ Emite authenticated → navega a /test-session
   │
   └─ Si token NO existe: Emite unauthenticated → navega a /home

3. HomePage muestra (si no autenticado):
   ├─ BrandHeaderSection (logo)
   ├─ HeroSection (descripción)
   └─ Botón "Iniciar sesión" → navega a /login

4. LoginPage (si sin sesión):
   ├─ LoginForm con email y password
   ├─ Validaciones:
   │  ├─ Email @uniandes.edu.co
   │  └─ Password no vacío
   └─ Botón Submit
       ├─ Emite loading en AuthCubit
       ├─ LoginUser usecase:
       │  ├─ POST /auth/v1/token (credenciales)
       │  ├─ Recibe accessToken, refreshToken, authId
       │  ├─ TokenStorage.saveSession(tokens)
       │  ├─ GET datos del usuario (riders, drivers)
       │  └─ Retorna User
       ├─ Si OK:
       │  ├─ AuthCubit emite authenticated con user
       │  └─ Navigator.pushReplacementNamed(/test-session)
       └─ Si error:
          ├─ AuthCubit emite error con mensaje
          └─ Muestra error en formulario

5. TestSessionPage:
   └─ Muestra datos: usuario, rider ID, driver ID
```

### 🚗 FLUJO 2: CREAR VIAJE (Driver)

```
1. CreateRidePage carga
   ├─ CreateRideCubit.loadVehicles():
   │  ├─ Obtiene driverId del usuario autenticado
   │  ├─ Parallel:
   │  │  ├─ GET /rest/v1/vehicles?driver_id=eq.{driverId}
   │  │  └─ GET /rest/v1/zones
   │  └─ Emite CreateRideReady(vehicles, zones)

2. Usuario llena formulario:
   ├─ Selecciona vehículo (dropdown)
   │  └─ CreateRideCubit.selectVehicle(vehicle)
   ├─ Selecciona zona (dropdown)
   │  └─ CreateRideCubit.selectZone(zone)
   ├─ Ingresa:
   │  ├─ Source (salida)
   │  ├─ Destination (destino)
   │  ├─ Date (fecha)
   │  ├─ DepartureTime (hora)
   │  ├─ Type (compartido/directo)
   │  └─ Price (precio por asiento)

3. Usuario presiona "Crear Viaje"
   ├─ Validaciones:
   │  ├─ Campos no vacíos
   │  └─ Vehículo y zona seleccionados
   ├─ Emite isSubmitting=true
   ├─ CreateRideCubit.createRide():
   │  ├─ Crea objeto Ride con datos
   │  ├─ POST /rest/v1/rides (con datos)
   │  └─ Retorna ID del viaje creado
   ├─ Si OK:
   │  ├─ Emite CreateRideSuccess
   │  └─ Muestra confirmación, vuelve atrás
   └─ Si error:
      ├─ Emite CreateRideError(mensaje)
      └─ Muestra mensaje de error
```

### 🎯 FLUJO 3: VER OFERTAS (Rider)

```
1. RideOffersPage carga
   ├─ RideOffersCubit.loadInitialData():
   │  ├─ Obtiene preferredZoneId del usuario auth
   │  ├─ Agrega a filtros
   │  ├─ Carga zonas:
   │  │  └─ GET /rest/v1/zones
   │  └─ Carga ofertas (con filtro zoneId)

2. RideOffersCubit.loadRideOffers():
   ├─ Emite status=loading
   ├─ GetRideOffers usecase:
   │  ├─ GET /rest/v1/ride_offers (con filtros)
   │  └─ Retorna List<RideOffer>
   ├─ Mapea a RideOfferViewData
   ├─ Si lista vacía: Emite empty con mensaje
   └─ Si ok: Emite success con ofertas

3. Usuario interactúa con filtros:
   ├─ Cambia zona: updateZoneId(zoneId)
   ├─ Cambia fecha: updateDate(date)
   ├─ Cambia hora: updateTime(time)
   ├─ Cambia tipo: updateType(type)
   ├─ Cambia orden: updateSortBy(sortBy)
   └─ Activa filtro rápido: toggleQuickFilter(value)

4. Usuario presiona "Aplicar Filtros"
   ├─ applyFilters() → recargas ofertas

5. Usuario presiona "Limpiar Filtros"
   ├─ clearFilters()
   ├─ Mantiene preferredZoneId
   └─ Recargas ofertas de la zona por defecto
```

---

## 7. MODELOS DE DATOS

### 📊 Relaciones entre Entidades

```
┌─────────────────────────────────────┐
│            User                      │
├─────────────────────────────────────┤
│ id (PK)                              │
│ firstName, lastName                  │
│ email, zoneId                        │
│ authId (Supabase Auth ID)            │
│ riderId (FK → riders.id)             │
│ driverId (FK → drivers.id)           │
└──────┬────────────────────┬──────────┘
       │                    │
       ▼                    ▼
   ┌─────────┐         ┌──────────┐
   │ Rider   │         │ Driver   │
   │ (1:1)   │         │ (1:1)    │
   └─────────┘         └┬─────────┘
                        │
                        ▼
                   ┌──────────┐
                   │ Vehicle  │
                   │ (driver→ │
                   │ vehicle) │
                   └┬─────────┘
                    │
                    ▼
               ┌────────────┐
               │ Ride       │
               │ (driver→   │
               │ ride,      │
               │ vehicle→   │
               │ ride)      │
               └──────┬─────┘
                      │
        ┌─────────────┼──────────────┐
        ▼             ▼              ▼
   ┌────────┐   ┌─────────────┐  ┌──────┐
   │  Zone  │   │ RideOffer   │  │Rider │
   │        │   │ (venta de   │  │(user)│
   │        │   │ asientos)   │  │      │
   └────────┘   └─────────────┘  └──────┘
```

### 📋 Tabla de Entidades

| Entidad | Campos Clave | Relaciones | Feature |
|---------|--------------|-----------|---------|
| **User** | id, firstName, lastName, email, zoneId, authId, riderId, driverId | 1→0/1 Rider, 1→0/1 Driver | Auth |
| **Rider** | id, userId | 1→1 User, Many→Many RideOffer | RideOffers |
| **Driver** | id, userId | 1→1 User, 1→Many Vehicle, 1→Many Ride | Rides |
| **Vehicle** | id, brand, model, color, licensePlate, numberSlots, driverId | Many→1 Driver, 1→Many Ride | Rides |
| **Ride** | id, driverId, vehicleId, zoneId, source, destination, date, departureTime, state, type, price | Many→1 Driver, Many→1 Vehicle, Many→1 Zone | Rides |
| **Zone** | id, name, description | 1→Many Ride, 1→Many RideOffer | Core |
| **RideOffer** | id, driverName, driverRating, tripsCount, price, source, destination, date, departureTime, slots, carModel, zoneName, type | N/A | RideOffers |

---

## 8. VALIDACIONES Y TEMAS

### ✅ Validadores Disponibles

**`form_validators.dart`**
```dart
emptyFieldValidator(value, fieldName)
  └─ Retorna: "$fieldName es obligatorio" si vacío

uniandesEmailValidator(value)
  └─ Regex: ^[\w-\.]+@uniandes\.edu\.co$
  └─ Retorna: "Debes usar un correo @uniandes.edu.co" si no coincide

// Custom en CreateRideCubit:
validateRequired(value, fieldName)
validateVehicleSelected(vehicle)
validateZoneSelected(zone)
```

### 🎨 Tema de Colores

**`app_colors.dart`** - Paleta Tailwind-inspired
```dart
// Fondos oscuros
slate900 (#0F172A)    ← Fondo principal (muy oscuro)
slate800 (#1e293b)    ← Fondos secundarios
blue900  (#1E3A5F)    ← Azul oscuro

// Acentos
teal600  (#0D9488)    ← Primary (Verde agua)
amber700 (#B45308)    ← Success/Warning (Naranja)
errorRed (#B00020)    ← Error (Rojo)

// Texto/Neutral
slate400 (#94A3B8)    ← Texto secundario (gris claro)
gray50   (#F8FAFC)    ← Texto principal (casi blanco)
white    (#FFFFFF)    ← Blanco puro
black    (#000000)    ← Negro puro
```

### 🔤 Estilos de Texto

**`app_text_styles.dart`**
```dart
primary       ← Roboto Regular (w400)
secondary     ← Roboto Medium (w500)
```

---

## 9. SERVICIOS PRINCIPALES

### 🌐 DioClient - Cliente HTTP

**Configuración**
```dart
baseUrl: Supabase API (del .env)
Headers:
  - Content-Type: application/json
  - apikey: API Key de Supabase
Timeout: 30 segundos (connect + receive)

Interceptors:
  1. AuthInterceptor
     - Inyecta Bearer token
     - Lo lee de TokenStorage.getAccessToken()
  2. LogInterceptor (solo debug)
     - Registra request/response body
```

**Uso**
```dart
dio.post('/auth/v1/token', data: credentials)
dio.get('/rest/v1/users', queryParameters: filters)
dio.post('/rest/v1/rides', data: rideData)
```

### 🔐 TokenStorage - Almacenamiento Seguro

**Métodos**
```dart
saveSession(accessToken, refreshToken)
  └─ Guarda en FlutterSecureStorage (encriptado)

getAccessToken()
  └─ Retorna Bearer token para autorización

getRefreshToken()
  └─ Para renovar access token expirado

clearSession()
  └─ Limpia todo al logout

hasSession()
  └─ ¿Hay token válido?
```

### 🛡️ Error Handling

**Flujo de Errores**
```
DioException (del cliente HTTP)
    ↓
ErrorHandler.getErrorMessage()
    ├─ Extrae: msg, message, error_description, error
    └─ Retorna String legible

ServerException (excepción interna)
    ↓
Repository.fold()
    ├─ left: ServerFailure(mensaje)
    └─ right: Resultado OK

BLoC/Cubit
    ├─ Emite estado error
    └─ UI muestra mensaje al usuario
```

---

## 10. FLUJO COMPLETO DE AUTENTICACIÓN

```
┌──────────────────────────────────────────────────────────┐
│                 FLUJO DE AUTENTICACIÓN                    │
└──────────────────────────────────────────────────────────┘

1. Login inicial:
   LoginPage → login(email, password)
   ↓
   AuthCubit → LoginUser usecase
   ↓
   AuthRepositoryRemote → AuthDataSourceRemoteSupabase
   ↓
   POST /auth/v1/token
   Response: {
     access_token,
     refresh_token,
     user: { id (authId), email }
   }
   ↓
   TokenStorage.saveSession(accessToken, refreshToken)
   ↓
   GET /rest/v1/users?auth_id=eq.{authId}
   ↓
   GET /rest/v1/riders?user_id=eq.{userId}
   ↓
   GET /rest/v1/drivers?user_id=eq.{userId}
   ↓
   Retorna User completo
   ↓
   AuthCubit emite authenticated
   ↓
   NavBar → /test-session

2. Token expira:
   Request incluye Bearer token
   ↓
   Servidor retorna 403 (token expired)
   ↓
   AuthDataSourceRemote detecta error
   ↓
   POST /auth/v1/token?grant_type=refresh_token
   ↓
   Supabase devuelve nuevo access_token
   ↓
   TokenStorage.saveSession(nuevo token, refresh token)
   ↓
   Request se reintenta automáticamente

3. Usuario cierra sesión:
   AuthCubit.logout()
   ↓
   TokenStorage.clearSession() (elimina tokens)
   ↓
   AuthCubit emite unauthenticated
   ↓
   NavBar → /login

4. App reinicia:
   AuthGate.initState()
   ↓
   AuthCubit.restoreUser()
   ↓
   ¿TokenStorage.hasSession()?
   ├─ Sí: GET /auth/v1/user (con Bearer token)
   │   ✓ Token ok → Obtiene datos usuario → authenticated
   │   ✗ Token expirado → refresh → authenticated
   │   ✗ No hay token → unauthenticated
   └─ No: unauthenticated → /home
```

---

## 📌 RESUMEN EJECUTIVO

### Arquitectura
- **Clean Architecture** con BLoC/Cubit
- **Separación por capas**: Data, Domain, Presentation
- **GetIt** para inyección de dependencias
- **Supabase** como backend (Auth + API REST)

### Features Principales
1. **Auth**: Login, logout, restauración de sesión
2. **Rides**: Crear viajes (conductor)
3. **RideOffers**: Ver y filtrar ofertas (pasajero)
4. **Home**: Página de bienvenida

### Seguridad
- Tokens guardados encriptados (FlutterSecureStorage)
- Tokens inyectados automáticamente (Dio interceptor)
- Validaciones de email @uniandes.edu.co
- Manejo de tokens expirados (refresh)

### Enfoque Usuario
- Dos flujos: Conductor vs Pasajero
- Filtros avanzados de búsqueda
- Experiencia UI oscura (Tailwind-inspired)
- Validaciones de formularios robustas

