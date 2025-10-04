import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/link_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/link.dart';
import '../auth/login_screen.dart';
import 'add_link_screen.dart';
import '../../widgets/link_card.dart';
import '../../widgets/pinned_links_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final linkProvider = Provider.of<LinkProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    
    await Future.wait([
      linkProvider.loadLinks(),
      categoryProvider.loadCategories(),
    ]);
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Widget _buildBody() {
    final linkProvider = Provider.of<LinkProvider>(context);
    
    List<Link> filteredLinks = _searchQuery.isEmpty
        ? linkProvider.links
        : linkProvider.links.where((link) {
            return link.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false ||
                   link.url.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    switch (_selectedIndex) {
      case 0:
        return _buildAllLinks(filteredLinks, linkProvider);
      case 1:
        return _buildLinksByType(filteredLinks, LinkType.job);
      case 2:
        return _buildLinksByType(filteredLinks, LinkType.article);
      case 3:
        return _buildLinksByType(filteredLinks, LinkType.reel);
      case 4:
        return _buildLinksByType(filteredLinks, LinkType.video);
      default:
        return _buildAllLinks(filteredLinks, linkProvider);
    }
  }

  Widget _buildAllLinks(List<Link> links, LinkProvider linkProvider) {
    if (linkProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (links.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link_off,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'No links yet',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap + to add your first link',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (linkProvider.pinnedLinks.isNotEmpty) ...[
            PinnedLinksSection(links: linkProvider.pinnedLinks),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
          ],
          ...links.where((l) => !l.pinnedFlag).map((link) => LinkCard(link: link)),
        ],
      ),
    );
  }

  Widget _buildLinksByType(List<Link> allLinks, LinkType type) {
    final links = allLinks.where((l) => l.type == type).toList();
    
    if (links.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForType(type),
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'No ${type.toString().split('.').last}s yet',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: links.map((link) => LinkCard(link: link)).toList(),
      ),
    );
  }

  IconData _getIconForType(LinkType type) {
    switch (type) {
      case LinkType.job:
        return Icons.work;
      case LinkType.article:
        return Icons.article;
      case LinkType.reel:
        return Icons.video_library;
      case LinkType.video:
        return Icons.play_circle;
      default:
        return Icons.link;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LinkHive'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: LinkSearchDelegate(),
              );
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Categories'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to categories screen
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Goals'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to goals screen
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(authProvider.user?.name ?? 'Profile'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to profile screen
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    _logout();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'All',
          ),
          NavigationDestination(
            icon: Icon(Icons.work),
            label: 'Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.article),
            label: 'Articles',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library),
            label: 'Reels',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle),
            label: 'Videos',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddLinkScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Link'),
      ),
    );
  }
}

// Search Delegate
class LinkSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final linkProvider = Provider.of<LinkProvider>(context);
    
    linkProvider.loadLinks(search: query);
    
    return Consumer<LinkProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.links.isEmpty) {
          return const Center(child: Text('No results found'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: provider.links.map((link) => LinkCard(link: link)).toList(),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text('Search for links...'));
  }
}