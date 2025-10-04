class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8000/api';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  
  // Link Types
  static const List<String> linkTypes = ['job', 'reel', 'article', 'video', 'other'];
  
  // Link Status
  static const List<String> linkStatuses = [
    'applied',
    'not_applied',
    'read',
    'unread',
    'none'
  ];
  
  // Clipboard check interval (in seconds)
  static const int clipboardCheckInterval = 5;
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Cache duration
  static const Duration cacheDuration = Duration(hours: 24);
}