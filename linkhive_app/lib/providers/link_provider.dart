import 'package:flutter/material.dart';
import '../models/link.dart';
import '../services/api_service.dart';
import '../services/local_db_service.dart';

class LinkProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalDbService _localDb = LocalDbService();
  
  List<Link> _links = [];
  bool _isLoading = false;
  String? _error;

  List<Link> get links => _links;
  List<Link> get pinnedLinks => _links.where((l) => l.pinnedFlag).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLinks({
    String? type,
    String? status,
    int? categoryId,
    bool? pinned,
    String? search,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _links = await _apiService.getLinks(
        type: type,
        status: status,
        categoryId: categoryId,
        pinned: pinned,
        search: search,
      );
      
      // Save to local DB
      for (var link in _links) {
        await _localDb.saveLink(link);
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      // Load from local DB if API fails
      _links = await _localDb.getLinks();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addLink(Link link) async {
    try {
      final newLink = await _apiService.createLink(link);
      _links.insert(0, newLink);
      await _localDb.saveLink(newLink);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateLink(int id, Link link) async {
    try {
      final updatedLink = await _apiService.updateLink(id, link);
      final index = _links.indexWhere((l) => l.id == id);
      if (index != -1) {
        _links[index] = updatedLink;
        await _localDb.saveLink(updatedLink);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteLink(int id) async {
    try {
      await _apiService.deleteLink(id);
      _links.removeWhere((l) => l.id == id);
      await _localDb.deleteLink(id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> togglePin(int id) async {
    try {
      await _apiService.togglePinLink(id);
      final index = _links.indexWhere((l) => l.id == id);
      if (index != -1) {
        _links[index] = _links[index].copyWith(
          pinnedFlag: !_links[index].pinnedFlag,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<Link> getLinksByType(LinkType type) {
    return _links.where((l) => l.type == type).toList();
  }

  List<Link> getLinksByCategory(int categoryId) {
    return _links.where((l) => l.categoryId == categoryId).toList();
  }
}