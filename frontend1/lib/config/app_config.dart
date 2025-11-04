class AppConfig {
  // Base URL for API calls
  // Change this to switch between development and production environments
  static const String baseUrl = 'http://192.168.29.152:5000';
  
  // Alternative URLs for different environments
  static const String localhostUrl = 'http://localhost:5000';
  static const String productionUrl = 'https://your-production-server.com';
  
  // Environment detection
  static bool get isDevelopment => baseUrl.contains('localhost') || baseUrl.contains('192.168');
  static bool get isProduction => !isDevelopment;
  
  // API endpoints
  static const String pricesEndpoint = '/api/prices';
  static const String fetchPricesEndpoint = '/api/prices/fetch';
  
  // Full API URLs
  static String get pricesUrl => '$baseUrl$pricesEndpoint';
  static String get fetchPricesUrl => '$baseUrl$fetchPricesEndpoint';
}
