# Environment Variables Configuration

This document describes the environment variables used in the ConnectX application and how to configure them for different environments.

## 📁 Environment Files

The application uses different environment files for each flavor:

- `.env` - Default environment variables
- `.env.development` - Development environment
- `.env.staging` - Staging environment  
- `.env.production` - Production environment

## 🔑 Required Variables

### API Configuration
```bash
API_BASE_URL=https://reqres.in/api    # Base URL for the API
API_KEY=reqres-free-v1               # Required API key for ReqRes API
API_VERSION=v1                       # API version
```

### App Configuration
```bash
APP_NAME=ConnectX                    # Application name
APP_VERSION=1.0.0                    # Application version
ENVIRONMENT=development              # Current environment (development/staging/production)
```

### Feature Flags
```bash
ENABLE_LOGGING=true                  # Enable/disable logging
ENABLE_ANALYTICS=false               # Enable/disable analytics
ENABLE_CRASHLYTICS=false             # Enable/disable crash reporting
SHOW_FLAVOR_BANNER=true              # Show/hide flavor banner
```

### Cache Configuration
```bash
CACHE_DURATION_HOURS=1               # Cache validity duration in hours
CACHE_MAX_SIZE=50                    # Maximum cache size
```

### Pagination Configuration
```bash
ITEMS_PER_PAGE=10                    # Number of items per page
MAX_RETRY_COUNT=3                    # Maximum retry attempts for failed requests
```

### Network Configuration
```bash
CONNECTION_TIMEOUT_SECONDS=30        # Connection timeout in seconds
RECEIVE_TIMEOUT_SECONDS=30           # Receive timeout in seconds
SEND_TIMEOUT_SECONDS=30              # Send timeout in seconds
```

### Debug Configuration
```bash
ENABLE_NETWORK_LOGS=true             # Enable network request/response logging
ENABLE_BLOC_LOGS=true                # Enable Bloc state transition logging
ENABLE_PERFORMANCE_LOGS=true         # Enable performance monitoring logs
```

## 🌍 Environment-Specific Settings

### Development (.env.development)
- **Purpose**: Local development and testing
- **Features**: 
  - Verbose logging enabled
  - Green flavor banner
  - Shorter cache duration (30 minutes)
  - Smaller pagination (5 items per page)
  - Extended timeouts for debugging

### Staging (.env.staging)
- **Purpose**: Pre-production testing
- **Features**:
  - Moderate logging enabled
  - Orange flavor banner
  - Analytics and crashlytics enabled
  - Medium pagination (8 items per page)
  - Production-like settings with debugging

### Production (.env.production)
- **Purpose**: Live production environment
- **Features**:
  - Logging disabled for performance
  - No flavor banner
  - Analytics and crashlytics enabled
  - Standard pagination (10 items per page)
  - Optimized timeouts

## 🔧 Usage in Code

### Accessing Environment Variables

```dart
// Import the environment config
import 'package:connectx_app/core/config/environment_config.dart';

// Access configuration values
final apiKey = EnvironmentConfig.instance.apiKey;
final baseUrl = EnvironmentConfig.instance.apiBaseUrl;
final enableLogging = EnvironmentConfig.instance.enableLogging;
```

### Initialize Environment Config

```dart
// In main.dart files
await EnvironmentConfig.instance.initialize();
```

### Using in API Calls

```dart
// Dio client automatically includes API key
final response = await dioClient.get('/users');

// Manual access if needed
final headers = {
  'X-API-Key': EnvironmentConfig.instance.apiKey,
};
```

## 🚀 Running with Different Environments

### Development
```bash
flutter run -t main_development.dart --flavor development
```

### Staging
```bash
flutter run -t main_staging.dart --flavor staging
```

### Production
```bash
flutter run -t main_production.dart --flavor production
```

### Building
```bash
# Development APK
flutter build apk --debug -t main_development.dart --flavor development

# Staging APK  
flutter build apk --profile -t main_staging.dart --flavor staging

# Production APK
flutter build apk --release -t main_production.dart --flavor production
```

## 🔒 Security Considerations

### API Key Management
- **Development**: Use the demo API key `reqres-free-v1`
- **Production**: Replace with your actual API key
- **Security**: Consider using more secure methods for production API keys

### Environment Files
- Keep sensitive data out of version control
- Use different API keys for different environments
- Regularly rotate API keys

### Best Practices
1. Never commit real API keys to version control
2. Use environment-specific API keys
3. Implement proper key rotation policies
4. Monitor API key usage and access

## 🛠️ Troubleshooting

### Common Issues

1. **API Key Missing**
   ```
   Error: API_KEY not found in environment configuration
   ```
   **Solution**: Ensure the API_KEY is set in your environment file

2. **Environment File Not Found**
   ```
   Error: Failed to load environment configuration
   ```
   **Solution**: Check that the environment file exists and is properly formatted

3. **Invalid Environment Values**
   ```
   Error: Could not parse environment variable
   ```
   **Solution**: Verify that boolean and numeric values are properly formatted

### Debugging Environment Issues

```dart
// Print all environment configuration
EnvironmentConfig.instance.printConfiguration();

// Check if environment is initialized
if (EnvironmentConfig.instance._isInitialized) {
  print('Environment loaded successfully');
}

// Access individual values for debugging
print('API Key length: ${EnvironmentConfig.instance.apiKey.length}');
print('Base URL: ${EnvironmentConfig.instance.apiBaseUrl}');
```

## 📝 Adding New Environment Variables

1. Add the variable to all environment files (.env, .env.development, .env.staging, .env.production)
2. Add a getter method in `EnvironmentConfig` class
3. Update this documentation
4. Test across all environments

Example:
```dart
// In environment_config.dart
String get newFeatureFlag {
  _ensureInitialized();
  return dotenv.env['NEW_FEATURE_FLAG'] ?? 'false';
}
```

## 🔄 Environment Variable Validation

The `EnvironmentConfig` class includes validation for required variables:

- Throws `StateError` if required variables are missing
- Provides fallback values for optional variables
- Logs warnings for missing optional variables

This ensures the application fails fast if critical configuration is missing.