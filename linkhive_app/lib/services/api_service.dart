import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/link.dart';
import '../models/category.dart';
import '../models/goal.dart';
import '../models/reminder.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api'; // Change for production
  
  String? _token;

  // Get stored token
  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  // Save token
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // AUTH ENDPOINTS
  Future<User> register(String name, String email, String password) async {
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

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<void> logout() async {
    try {
      final headers = await _getHeaders();
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: headers,
      );
    } finally {
      await clearToken();
    }
  }

  Future<User> getCurrentUser() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user');
    }
  }

  // LINK ENDPOINTS
  Future<List<Link>> getLinks({
    String? type,
    String? status,
    int? categoryId,
    bool? pinned,
    String? search,
  }) async {
    final headers = await _getHeaders();
    final queryParams = <String, String>{};
    
    if (type != null) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (pinned != null) queryParams['pinned'] = pinned.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse('$baseUrl/links').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((json) => Link.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load links');
    }
  }

  Future<Link> createLink(Link link) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/links'),
      headers: headers,
      body: jsonEncode(link.toJson()),
    );

    if (response.statusCode == 201) {
      return Link.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to create link: ${response.body}');
    }
  }

  Future<Link> updateLink(int id, Link link) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/links/$id'),
      headers: headers,
      body: jsonEncode(link.toJson()),
    );

    if (response.statusCode == 200) {
      return Link.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to update link');
    }
  }

  Future<void> deleteLink(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/links/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete link');
    }
  }

  Future<void> togglePinLink(int id) async {
    final headers = await _getHeaders();
    await http.post(
      Uri.parse('$baseUrl/links/$id/toggle-pin'),
      headers: headers,
    );
  }

  Future<void> reorderLinks(List<Map<String, dynamic>> order) async {
    final headers = await _getHeaders();
    await http.post(
      Uri.parse('$baseUrl/links/reorder'),
      headers: headers,
      body: jsonEncode({'order': order}),
    );
  }

  // CATEGORY ENDPOINTS
  Future<List<Category>> getCategories() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<Category> createCategory(String name) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: headers,
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 201) {
      return Category.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to create category');
    }
  }

  Future<void> deleteCategory(int id) async {
    final headers = await _getHeaders();
    await http.delete(
      Uri.parse('$baseUrl/categories/$id'),
      headers: headers,
    );
  }

  // GOAL ENDPOINTS
  Future<List<Goal>> getGoals() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/goals'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((json) => Goal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load goals');
    }
  }

  Future<Goal> createGoal(Goal goal) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/goals'),
      headers: headers,
      body: jsonEncode(goal.toJson()),
    );

    if (response.statusCode == 201) {
      return Goal.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to create goal');
    }
  }

  // REMINDER ENDPOINTS
  Future<List<Reminder>> getReminders() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/reminders'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((json) => Reminder.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reminders');
    }
  }

  Future<Reminder> createReminder(Reminder reminder) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/reminders'),
      headers: headers,
      body: jsonEncode(reminder.toJson()),
    );

    if (response.statusCode == 201) {
      return Reminder.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to create reminder');
    }
  }

  Future<void> deleteReminder(int id) async {
    final headers = await _getHeaders();
    await http.delete(
      Uri.parse('$baseUrl/reminders/$id'),
      headers: headers,
    );
  }
}