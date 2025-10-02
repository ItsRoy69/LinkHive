// lib/providers/link_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/link.dart';

class LinkProvider with ChangeNotifier {
  List<Link> _links = [];
  bool _isLoading = false;
  String? _error;

  List<Link> get links => _links;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLinks({
    String? search,
    String? type,
    String? status,
    int? categoryId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final linkData = await ApiService.getLinks(
        search: search,
        type: type,
        status: status,
        categoryId: categoryId,
      );
      
      _links = linkData.map((data) => Link.fromJson(data)).toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addLink(Map<String, dynamic> linkData) async {
    try {
      final response = await ApiService.createLink(linkData);
      final newLink = Link.fromJson(response);
      
      _links.insert(0, newLink);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLink(int linkId) async {
    try {
      await ApiService.deleteLink(linkId);
      _links.removeWhere((link) => link.id == linkId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> togglePin(int linkId) async {
    try {
      final response = await ApiService.togglePin(linkId);
      final updatedLink = Link.fromJson(response);
      
      final index = _links.indexWhere((link) => link.id == linkId);
      if (index != -1) {
        _links[index] = updatedLink;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}