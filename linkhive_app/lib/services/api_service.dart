// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api'; // Change this to your API URL
  static String? _authToken;

  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getAuthToken() async {
    if (_authToken != null) return _authToken;
    
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    return _authToken;
  }

  // Login method
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await setAuthToken(data['access_token']);
      return data;
    } else {
      throw Exception('Login failed');
    }
  }

  // Register method (was missing)
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await setAuthToken(data['access_token']);
      return data;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Registration failed');
    }
  }

  // Logout method (was missing)
  static Future<void> logout() async {
    final token = await getAuthToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      } catch (e) {
        // Even if logout fails on server, we'll clear local token
        print('Logout API call failed: $e');
      }
    }
    
    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _authToken = null;
  }

  // Get links method
  static Future<List<Map<String, dynamic>>> getLinks({
    String? search,
    String? type,
    String? status,
    int? categoryId,
  }) async {
    final token = await getAuthToken();
    if (token == null) throw Exception('No auth token');

    final queryParams = <String, String>{};
    
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();

    final uri = Uri.parse('$baseUrl/links').replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } else {
      throw Exception('Failed to load links: ${response.body}');
    }
  }

  // Create link method
  static Future<Map<String, dynamic>> createLink(Map<String, dynamic> linkData) async {
    final token = await getAuthToken();
    if (token == null) throw Exception('No auth token');
    
    final response = await http.post(
      Uri.parse('$baseUrl/links'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(linkData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to create link');
    }
  }

  // Delete link method (was missing)
  static Future<void> deleteLink(int linkId) async {
    final token = await getAuthToken();
    if (token == null) throw Exception('No auth token');
    
    final response = await http.delete(
      Uri.parse('$baseUrl/links/$linkId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to delete link');
    }
  }

  // Toggle pin method (was missing)
  static Future<Map<String, dynamic>> togglePin(int linkId) async {
    final token = await getAuthToken();
    if (token == null) throw Exception('No auth token');
    
    final response = await http.post(
      Uri.parse('$baseUrl/links/$linkId/toggle-pin'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to toggle pin');
    }
  }

  // Update link method
  static Future<Map<String, dynamic>> updateLink(int linkId, Map<String, dynamic> linkData) async {
    final token = await getAuthToken();
    if (token == null) throw Exception('No auth token');
    
    final response = await http.put(
      Uri.parse('$baseUrl/links/$linkId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(linkData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update link');
    }
  }

  // Get categories
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final token = await getAuthToken();
    if (token == null) throw Exception('No auth token');
    
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load categories');
    }
  }
}