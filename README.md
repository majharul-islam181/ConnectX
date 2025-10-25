# ConnectX

A professional Flutter application demonstrating best practices in mobile development with Clean Architecture, BLoC state management, and multi-environment support.

## Overview

ConnectX is a user management application that fetches and displays user information from the ReqRes API. Built with scalability and maintainability in mind, it showcases modern Flutter development practices including Clean Architecture, comprehensive error handling, offline caching, and responsive UI design.

## Features

- **User List Display** - Paginated list with infinite scrolling
- **User Search** - Real-time search with debouncing (500ms)
- **User Details** - Comprehensive user profile with smooth animations
- **Pull-to-Refresh** - Swipe to refresh user data
- **Offline Support** - Local data persistence using SharedPreferences
- **Image Caching** - Optimized avatar loading with cached_network_image
- **Multi-Environment** - Development, Staging, and Production flavors
- **Error Handling** - Comprehensive error states with retry functionality
- **Network Monitoring** - Connectivity detection
- **Custom Splash Screen** - Branded app launch experience

## Architecture

This project implements **Clean Architecture** with three distinct layers:

```
┌─────────────────────────────────────────────────┐
│           Presentation Layer                    │
│  (Pages, Widgets, BLoC State Management)        │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│            Domain Layer                         │
│     (Entities, Use Cases, Repositories)         │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│             Data Layer                          │
│  (Models, Data Sources, Repository Impl)        │
└─────────────────────────────────────────────────┘
```

### Design Patterns

- **Clean Architecture** - Separation of concerns across layers
- **BLoC Pattern** - Business Logic Component for state management
- **Repository Pattern** - Abstract data sources behind interfaces
- **Dependency Injection** - GetIt service locator
- **Either/Result Pattern** - Functional error handling with dartz
- **Factory Pattern** - Model creation and entity conversion

### Project Structure

```
lib/
├── app/                          # Application layer
│   ├── app.dart                 # Main app widget
│   ├── router/                  # Navigation routing (GoRouter)
│   └── theme/                   # Material theme configuration
│
├── core/                        # Shared utilities & infrastructure
│   ├── config/                 # App flavor configuration
│   ├── constants/              # Global constants
│   ├── di/                     # Dependency injection setup
│   ├── errors/                 # Exception and failure types
│   ├── network/                # HTTP client & network utilities
│   ├── usecases/              # Base use case abstraction
│   └── utils/                  # Extensions, validators, logger
│
├── features/                   # Feature modules
│   └── user/                  # User feature
│       ├── data/              # Data layer
│       │   ├── datasources/   # Remote & Local data sources
│       │   ├── models/        # JSON serializable models
│       │   └── repositories/  # Repository implementations
│       │
│       ├── domain/            # Domain layer
│       │   ├── entities/      # Business entities
│       │   ├── repository/    # Repository interfaces
│       │   └── usecases/      # Business use cases
│       │
│       └── presentation/      # Presentation layer
│           ├── bloc/          # BLoC state management
│           ├── pages/         # Full screen pages
│           └── widgets/       # Reusable UI components
│
├── main_development.dart       # Development entry point
├── main_staging.dart           # Staging entry point
├── main_production.dart        # Production entry point
└── environment_config.dart     # Environment variables loader
```

## Tech Stack

### Core Dependencies

- **Flutter SDK** `^3.5.3`
- **Dart SDK** `^3.5.3`

### State Management & Architecture

- **flutter_bloc** `^9.1.1` - BLoC pattern implementation
- **equatable** `^2.0.7` - Value equality
- **dartz** `^0.10.1` - Functional programming (Either)
- **get_it** `^8.2.0` - Dependency injection

### Networking & Data

- **dio** `^5.9.0` - HTTP client
- **connectivity_plus** `^7.0.0` - Network status monitoring
- **shared_preferences** `^2.5.3` - Local storage
- **cached_network_image** `^3.4.1` - Image caching

### Navigation & Routing

- **go_router** `^15.1.2` - Declarative routing

### Configuration

- **flutter_dotenv** `^6.0.0` - Environment variables
- **flutter_flavor** `^3.1.3` - Multi-flavor support

### Serialization

- **json_annotation** `^4.9.0` - JSON annotations
- **json_serializable** `^6.9.0` - Code generation
- **build_runner** `^2.4.13` - Build system

### UI Components

- **pull_to_refresh** `^2.0.0` - Pull-to-refresh functionality
- **cupertino_icons** `^1.0.8` - iOS-style icons

## Getting Started

### Prerequisites

- Flutter SDK (≥3.5.3)
- Dart SDK (≥3.5.3)
- Android Studio / VS Code with Flutter extensions
- Xcode (for iOS development on macOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ConnectX.git
   cd ConnectX
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code** (for JSON serialization)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Create environment files**

   Create `.env` files in the root directory:

   **`.env.development`**
   ```bash
   # API Configuration
   API_BASE_URL=https://reqres.in/api
   API_KEY=reqres-free-v1
   API_VERSION=v1

   # App Configuration
   APP_NAME=ConnectX Dev
   APP_VERSION=1.0.0
   ENVIRONMENT=development

   # Feature Flags
   ENABLE_LOGGING=true
   ENABLE_ANALYTICS=false
   ENABLE_CRASHLYTICS=false
   SHOW_FLAVOR_BANNER=true

   # Performance
   CACHE_DURATION_HOURS=1
   ITEMS_PER_PAGE=10
   MAX_RETRY_COUNT=3
   CONNECTION_TIMEOUT_SECONDS=30
   ```

   **`.env.staging`**
   ```bash
   # API Configuration
   API_BASE_URL=https://reqres.in/api
   API_KEY=reqres-free-v1
   API_VERSION=v1

   # App Configuration
   APP_NAME=ConnectX Staging
   APP_VERSION=1.0.0
   ENVIRONMENT=staging

   # Feature Flags
   ENABLE_LOGGING=true
   ENABLE_ANALYTICS=true
   ENABLE_CRASHLYTICS=false
   SHOW_FLAVOR_BANNER=true

   # Performance
   CACHE_DURATION_HOURS=1
   ITEMS_PER_PAGE=10
   MAX_RETRY_COUNT=3
   CONNECTION_TIMEOUT_SECONDS=30
   ```

   **`.env.production`**
   ```bash
   # API Configuration
   API_BASE_URL=https://reqres.in/api
   API_KEY=reqres-free-v1
   API_VERSION=v1

   # App Configuration
   APP_NAME=ConnectX
   APP_VERSION=1.0.0
   ENVIRONMENT=production

   # Feature Flags
   ENABLE_LOGGING=false
   ENABLE_ANALYTICS=true
   ENABLE_CRASHLYTICS=true
   SHOW_FLAVOR_BANNER=false

   # Performance
   CACHE_DURATION_HOURS=24
   ITEMS_PER_PAGE=10
   MAX_RETRY_COUNT=3
   CONNECTION_TIMEOUT_SECONDS=30
   ```

5. **Run the app**

   **Development:**
   ```bash
   flutter run -t lib/main_development.dart --flavor development
   ```

   **Staging:**
   ```bash
   flutter run -t lib/main_staging.dart --flavor staging
   ```

   **Production:**
   ```bash
   flutter run -t lib/main_production.dart --flavor production
   ```

## Development

### Code Generation

When you modify model classes with `@JsonSerializable()` annotation:

```bash
# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch

# One-time build
flutter pub run build_runner build --delete-conflicting-outputs
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/

# Run tests
flutter test
```

### Adding New Features

1. **Create feature directory** under `lib/features/`
2. **Implement data layer** (models, data sources, repository)
3. **Implement domain layer** (entities, use cases, repository interface)
4. **Implement presentation layer** (BLoC, pages, widgets)
5. **Register dependencies** in `core/di/dependency_injection.dart`
6. **Add routes** in `app/router/app_router.dart`

## BLoC State Management

### Events

- `LoadUsersEvent` - Load initial users
- `LoadMoreUsersEvent` - Load next page (pagination)
- `SearchUsersEvent` - Search users with debouncing
- `ClearSearchEvent` - Clear search and restore list
- `LoadUserDetailEvent` - Load single user details
- `RefreshUsersEvent` - Pull-to-refresh
- `RetryEvent` - Retry failed operation
- `ResetUserDetailEvent` - Navigate back from detail

### States

- `UserInitialState` - Initial state
- `UserLoadingState` - Loading indicator
- `UsersLoadedState` - Users loaded successfully
- `UserDetailLoadingState` - Loading user detail
- `UserDetailLoadedState` - User detail loaded
- `UserSearchResultsState` - Search results
- `UserEmptyState` - No results found
- `UserErrorState` - Error with retry option

## API Integration

The app uses the [ReqRes API](https://reqres.in/) for demonstration purposes.

**Endpoints used:**
- `GET /users?page={page}&per_page={perPage}` - Get paginated users
- `GET /users/{id}` - Get user details

## Error Handling

### Failure Types

- **Network Failures**: `NetworkFailure`, `ConnectionFailure`, `TimeoutFailure`
- **Server Failures**: `ServerFailure`, `UnauthorizedFailure`, `NotFoundFailure`
- **Cache Failures**: `CacheFailure`, `CacheExpiredFailure`
- **Parse Failures**: `JsonParseFailure`, `DataParseFailure`
- **User Failures**: `UserNotFoundFailure`, `UsersLoadFailure`

### Retry Logic

- Automatic retry with exponential backoff
- Max 3 retry attempts (configurable)
- Manual retry button on error state
- Preserves last event for intelligent retry

## Configuration

### App Flavors

Three flavors are configured:

| Flavor | Purpose | Logging | Analytics | Banner |
|--------|---------|---------|-----------|--------|
| Development | Local development | Enabled | Disabled | Shown |
| Staging | QA/Testing | Enabled | Enabled | Shown |
| Production | Release | Disabled | Enabled | Hidden |

### Environment Variables

Key environment variables:

- `API_BASE_URL` - Base URL for API
- `API_KEY` - API authentication key
- `ENVIRONMENT` - Current environment
- `ENABLE_LOGGING` - Enable/disable logging
- `CACHE_DURATION_HOURS` - Cache expiry duration
- `ITEMS_PER_PAGE` - Pagination size
- `CONNECTION_TIMEOUT_SECONDS` - HTTP timeout

## Build & Release

### Android

```bash
# Development APK
flutter build apk -t lib/main_development.dart --flavor development

# Staging APK
flutter build apk -t lib/main_staging.dart --flavor staging

# Production APK
flutter build apk -t lib/main_production.dart --flavor production --release

# Production App Bundle
flutter build appbundle -t lib/main_production.dart --flavor production --release
```

### iOS

```bash
# Development
flutter build ios -t lib/main_development.dart --flavor development

# Production
flutter build ios -t lib/main_production.dart --flavor production --release
```

## Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Performance Optimization

- **Image Caching**: All user avatars are cached using `cached_network_image`
- **Lazy Loading**: Infinite scroll with pagination
- **Debouncing**: Search queries debounced to 500ms
- **Memory Management**: Efficient state updates using `copyWith`
- **HTTP Caching**: Response caching with expiry
- **Connection Pooling**: Reusable HTTP connections via Dio

## Logging

Custom logging system with multiple levels:

```dart
AppLogger.debug('Debug message');
AppLogger.info('Info message');
AppLogger.warning('Warning message');
AppLogger.error('Error message', error: e, stackTrace: st);
```

Log levels controlled via `ENABLE_LOGGING` environment variable.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Coding Standards

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Write comments for complex logic
- Maintain consistent formatting (use `dart format`)
- Write unit tests for business logic

## Troubleshooting

### Common Issues

**Issue: Build runner fails**
```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Issue: Environment variables not loading**
```bash
# Solution: Ensure .env files exist in root directory
# Check file names match: .env.development, .env.staging, .env.production
```

**Issue: DI registration error**
```bash
# Solution: Ensure all dependencies are registered in dependency_injection.dart
# Check initialization order (external -> core -> data -> domain -> presentation)
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [ReqRes API](https://reqres.in/) - Free API for testing
- [Flutter](https://flutter.dev/) - UI framework
- [BLoC Library](https://bloclibrary.dev/) - State management
- Clean Architecture principles by Robert C. Martin

## Contact

For questions or support, please open an issue on GitHub.

---

**Built with Flutter 💙**
