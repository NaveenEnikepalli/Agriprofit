# App Configuration

This directory contains the centralized configuration for the Smart Farming App.

## Configuration File: `app_config.dart`

The `AppConfig` class centralizes all API endpoints and environment settings.

### Current Configuration

- **Base URL**: `http://192.168.29.152:5000` (Network IP for mobile device access)
- **Environment**: Development (detected automatically)

### Switching Environments

To switch between different environments, simply change the `baseUrl` in `app_config.dart`:

```dart
// For local development (desktop/web only)
static const String baseUrl = 'http://localhost:5000';

// For mobile device testing (same network)
static const String baseUrl = 'http://192.168.29.152:5000';

// For production
static const String baseUrl = 'https://your-production-server.com';
```

### Available URLs

- `AppConfig.baseUrl` - Main API base URL
- `AppConfig.pricesUrl` - Full URL for prices endpoint
- `AppConfig.fetchPricesUrl` - Full URL for fetch prices endpoint

### Environment Detection

- `AppConfig.isDevelopment` - Returns true for localhost or 192.168.x.x URLs
- `AppConfig.isProduction` - Returns true for production URLs

### Usage in Code

```dart
import '../config/app_config.dart';

// Use the base URL
final url = AppConfig.baseUrl;

// Use specific endpoints
final pricesUrl = AppConfig.pricesUrl;
```

This centralized approach makes it easy to switch between development, testing, and production environments without searching through multiple files.
