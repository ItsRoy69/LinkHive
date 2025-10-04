import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/link.dart';
import '../../models/category.dart';
import '../../providers/link_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';

class AddLinkScreen extends StatefulWidget {
  final Link? linkToEdit;
  
  const AddLinkScreen({super.key, this.linkToEdit});

  @override
  State<AddLinkScreen> createState() => _AddLinkScreenState();
}

class _AddLinkScreenState extends State<AddLinkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  
  LinkType _selectedType = LinkType.other;
  LinkStatus _selectedStatus = LinkStatus.none;
  Category? _selectedCategory;
  bool _isPinned = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.linkToEdit != null) {
      _urlController.text = widget.linkToEdit!.url;
      _titleController.text = widget.linkToEdit!.title ?? '';
      _selectedType = widget.linkToEdit!.type;
      _selectedStatus = widget.linkToEdit!.status;
      _isPinned = widget.linkToEdit!.pinnedFlag;
    } else {
      _checkClipboard();
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _checkClipboard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null && clipboardData.text != null) {
      final text = clipboardData.text!;
      if (Uri.tryParse(text)?.hasAbsolutePath ?? false) {
        _urlController.text = text;
        _selectedType = _detectLinkType(text);
        setState(() {});
      }
    }
  }

  LinkType _detectLinkType(String url) {
    final urlLower = url.toLowerCase();
    
    if (urlLower.contains('linkedin.com/jobs') ||
        urlLower.contains('indeed.com') ||
        urlLower.contains('naukri.com')) {
      return LinkType.job;
    }
    
    if (urlLower.contains('instagram.com/reel') ||
        urlLower.contains('tiktok.com')) {
      return LinkType.reel;
    }
    
    if (urlLower.contains('youtube.com') ||
        urlLower.contains('youtu.be') ||
        urlLower.contains('vimeo.com')) {
      return LinkType.video;
    }
    
    if (urlLower.contains('medium.com') ||
        urlLower.contains('dev.to') ||
        urlLower.contains('/article') ||
        urlLower.contains('/blog')) {
      return LinkType.article;
    }
    
    return LinkType.other;
  }

  Future<void> _saveLink() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final linkProvider = Provider.of<LinkProvider>(context, listen: false);
      
      final link = Link(
        id: widget.linkToEdit?.id,
        userId: authProvider.user!.id,
        url: _urlController.text.trim(),
        title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        categoryId: _selectedCategory?.id,
        pinnedFlag: _isPinned,
      );

      try {
        if (widget.linkToEdit != null) {
          await linkProvider.updateLink(widget.linkToEdit!.id!, link);
        } else {
          await linkProvider.addLink(link);
        }
        
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.linkToEdit != null 
                  ? 'Link updated successfully' 
                  : 'Link added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.linkToEdit != null ? 'Edit Link' : 'Add Link'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveLink,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'URL *',
                hintText: 'https://example.com',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste),
                  onPressed: () async {
                    final clipboardData = await Clipboard.getData('text/plain');
                    if (clipboardData != null && clipboardData.text != null) {
                      _urlController.text = clipboardData.text!;
                      _selectedType = _detectLinkType(clipboardData.text!);
                      setState(() {});
                    }
                  },
                ),
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a URL';
                }
                if (!Uri.tryParse(value)!.hasAbsolutePath) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _selectedType = _detectLinkType(value);
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title (optional)',
                hintText: 'Add a custom title',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<LinkType>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Type',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: LinkType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<LinkStatus>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                prefixIcon: const Icon(Icons.check_circle),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: LinkStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusLabel(status)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Category?>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: const Icon(Icons.folder),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('None'),
                ),
                ...categoryProvider.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Pin to top'),
              subtitle: const Text('Show this link at the top of your list'),
              value: _isPinned,
              onChanged: (value) {
                setState(() {
                  _isPinned = value;
                });
              },
              secondary: const Icon(Icons.push_pin),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveLink,
              icon: const Icon(Icons.save),
              label: Text(widget.linkToEdit != null ? 'Update Link' : 'Save Link'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(LinkStatus status) {
    switch (status) {
      case LinkStatus.applied:
        return 'Applied';
      case LinkStatus.notApplied:
        return 'Not Applied';
      case LinkStatus.read:
        return 'Read';
      case LinkStatus.unread:
        return 'Unread';
      case LinkStatus.none:
        return 'None';
    }
  }
}